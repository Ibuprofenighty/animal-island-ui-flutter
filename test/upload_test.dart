import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

IslandUploadSource source(String name) => IslandUploadSource(
  name: name,
  size: 3,
  mimeType: name.endsWith('.png') ? 'image/png' : 'text/plain',
  openRead: () => Stream.value([1, 2, 3]),
);
Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 500, child: child)),
);
Future<void> frames(WidgetTester t, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await t.pump(const Duration(milliseconds: 1));
  }
}

Future<void> pick(WidgetTester t) async {
  await t.tap(find.text('点击上传'));
  await frames(t);
}

void main() {
  registerStaleSelectionErrors();
  testWidgets('progress bursts coalesce without delaying terminal success', (
    t,
  ) async {
    final done = Completer<Object?>();
    late IslandUploadTransfer transfer;
    var events = 0;
    List<IslandUploadFile> files = [];
    await t.pumpWidget(
      host(
        IslandUpload.uncontrolled(
          pickFiles: ({required multiple, required accept}) async => [
            source('burst.txt'),
          ],
          request: (v) {
            transfer = v;
            return done.future;
          },
          onChanged: (change) {
            files = change.files;
            events++;
          },
        ),
      ),
    );
    await pick(t);
    for (var i = 0; i < 1000; i++) transfer.onProgress(i / 10);
    await frames(t, 12);
    expect(files.single.percent, 100);
    expect(events, lessThan(8));
    transfer.onProgress(50);
    done.complete('accepted');
    await frames(t, 12);
    expect(files.single.status, IslandUploadStatus.done);
    expect(files.single.percent, 100);
    expect(events, lessThan(12));
  });

  testWidgets(
    'controlled rejection never starts transport or commits locally',
    (t) async {
      var started = 0, proposals = 0;
      await t.pumpWidget(
        host(
          IslandUpload(
            files: const [],
            onChanged: (_) => proposals++,
            pickFiles: ({required multiple, required accept}) async => [
              source('a.txt'),
            ],
            request: (_) async {
              started++;
              return null;
            },
          ),
        ),
      );
      await pick(t);
      expect(proposals, 1);
      expect(started, 0);
      expect(find.text('a.txt'), findsNothing);
    },
  );
  testWidgets(
    'concurrent controlled progress merges after each parent acknowledgement',
    (t) async {
      var files = <IslandUploadFile>[];
      final transfers = <IslandUploadTransfer>[], done = <Completer<Object?>>[];
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) => IslandUpload(
              files: files,
              onChanged: (change) => set(() => files = change.files),
              multiple: true,
              pickFiles: ({required multiple, required accept}) async => [
                source('a.txt'),
                source('b.txt'),
              ],
              request: (transfer) {
                transfers.add(transfer);
                final c = Completer<Object?>();
                done.add(c);
                return c.future;
              },
            ),
          ),
        ),
      );
      await pick(t);
      expect(transfers, hasLength(2));
      transfers[0].onProgress(25);
      transfers[1].onProgress(75);
      await frames(t);
      expect(files.map((f) => f.percent), [25, 75]);
      done[0].complete('a');
      done[1].complete('b');
      await frames(t);
      expect(files.map((f) => f.status), everyElement(IslandUploadStatus.done));
      expect(files.map((f) => f.response), ['a', 'b']);
    },
  );
  testWidgets(
    'accepted removal aborts its request and late callbacks cannot revive it',
    (t) async {
      late IslandUploadTransfer transfer;
      final done = Completer<Object?>();
      var cancelled = 0;
      await t.pumpWidget(
        host(
          IslandUpload.uncontrolled(
            pickFiles: ({required multiple, required accept}) async => [
              source('remove.txt'),
            ],
            request: (v) {
              transfer = v;
              v.cancellation.addListener(() => cancelled++);
              return done.future;
            },
          ),
        ),
      );
      await pick(t);
      await t.tap(find.bySemanticsLabel('删除 remove.txt'));
      await frames(t);
      expect(cancelled, 1);
      expect(transfer.cancellation.isCancelled, isTrue);
      transfer.onProgress(80);
      done.complete('late');
      await frames(t);
      expect(find.text('remove.txt'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'parent rejection and asynchronous veto retain the active transfer',
    (t) async {
      var files = <IslandUploadFile>[];
      var veto = false;
      final pending = Completer<bool>(), done = Completer<Object?>();
      late IslandUploadTransfer transfer;
      late StateSetter rebuild;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) {
              rebuild = set;
              return IslandUpload(
                files: files,
                onChanged: (change) {
                  if (change.file.status != IslandUploadStatus.removed)
                    set(() => files = change.files);
                },
                onRemove: (_) => veto ? pending.future : true,
                pickFiles: ({required multiple, required accept}) async => [
                  source('keep.txt'),
                ],
                request: (v) {
                  transfer = v;
                  return done.future;
                },
              );
            },
          ),
        ),
      );
      await pick(t);
      await t.tap(find.bySemanticsLabel('删除 keep.txt'));
      await frames(t);
      expect(transfer.cancellation.isCancelled, isFalse);
      rebuild(() => veto = true);
      await t.pump();
      await t.tap(find.bySemanticsLabel('删除 keep.txt'));
      await frames(t);
      pending.complete(false);
      await frames(t);
      expect(find.text('keep.txt'), findsOneWidget);
      expect(transfer.cancellation.isCancelled, isFalse);
      done.complete(null);
      await frames(t);
    },
  );
  testWidgets(
    'maxCount one replaces and cancels; accept is shared by drop and picker',
    (t) async {
      var selected = [source('first.png')];
      final transfers = <IslandUploadTransfer>[], done = <Completer<Object?>>[];
      ValueChanged<List<IslandUploadSource>>? drop;
      await t.pumpWidget(
        host(
          IslandUpload.uncontrolled(
            maxCount: 1,
            accept: 'image/*',
            drag: true,
            dropBuilder: (context, child, enabled, onDrop, onHover) {
              drop = onDrop;
              return child;
            },
            pickFiles: ({required multiple, required accept}) async => selected,
            request: (v) {
              transfers.add(v);
              final c = Completer<Object?>();
              done.add(c);
              return c.future;
            },
          ),
        ),
      );
      await t.tap(find.text('点击或拖拽文件到这里'));
      await frames(t);
      drop!([source('bad.txt')]);
      await frames(t);
      expect(transfers, hasLength(1));
      selected = [source('second.png')];
      drop!(selected);
      await frames(t);
      expect(transfers, hasLength(2));
      expect(transfers.first.cancellation.isCancelled, isTrue);
      expect(find.text('first.png'), findsNothing);
      expect(find.text('second.png'), findsOneWidget);
      for (final c in done) c.complete(null);
      await frames(t);
    },
  );
  testWidgets(
    'serialized preflight respects capacity and retains transformed bytes',
    (t) async {
      final first = Completer<IslandUploadSource?>();
      final requests = <IslandUploadSource>[];
      var rejected = <IslandUploadSource>[];
      final converted = source('converted.txt');
      await t.pumpWidget(
        host(
          IslandUpload.uncontrolled(
            multiple: true,
            maxCount: 2,
            pickFiles: ({required multiple, required accept}) async => [
              source('a.txt'),
              source('b.txt'),
              source('c.txt'),
            ],
            beforeUpload: (file, batch) =>
                file.name == 'a.txt' ? first.future : file,
            onExceed: (files, _) => rejected = files,
            request: (v) async {
              requests.add(v.file);
              return null;
            },
          ),
        ),
      );
      await pick(t);
      expect(requests, isEmpty);
      first.complete(converted);
      await frames(t, 20);
      expect(requests, hasLength(2));
      expect(identical(requests.first, converted), isTrue);
      expect(find.text('a.txt'), findsOneWidget);
      expect(rejected.single.name, 'c.txt');
    },
  );
  testWidgets('disabling during async selection invalidates the result', (
    t,
  ) async {
    final selection = Completer<List<IslandUploadSource>>();
    var disabled = false, started = 0;
    late StateSetter set;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return IslandUpload.uncontrolled(
              disabled: disabled,
              pickFiles: ({required multiple, required accept}) =>
                  selection.future,
              request: (_) async {
                started++;
                return null;
              },
            );
          },
        ),
      ),
    );
    await pick(t);
    set(() => disabled = true);
    await t.pump();
    selection.complete([source('late.txt')]);
    await frames(t);
    expect(started, 0);
    expect(find.text('late.txt'), findsNothing);
  });
  testWidgets('dispose cancels all jobs and ignores delayed preflight', (
    t,
  ) async {
    final preflight = Completer<IslandUploadSource?>(),
        done = Completer<Object?>();
    IslandUploadTransfer? transfer;
    await t.pumpWidget(
      host(
        IslandUpload.uncontrolled(
          multiple: true,
          pickFiles: ({required multiple, required accept}) async => [
            source('a.txt'),
            source('b.txt'),
          ],
          beforeUpload: (file, _) =>
              file.name == 'b.txt' ? preflight.future : file,
          request: (v) {
            transfer = v;
            return done.future;
          },
        ),
      ),
    );
    await pick(t);
    expect(transfer, isNotNull);
    await t.pumpWidget(const SizedBox());
    expect(transfer!.cancellation.isCancelled, isTrue);
    preflight.complete(source('b.txt'));
    done.complete(null);
    await frames(t);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'request errors become error state and a second batch still works',
    (t) async {
      var calls = 0;
      List<IslandUploadFile> files = [];
      await t.pumpWidget(
        host(
          IslandUpload.uncontrolled(
            pickFiles: ({required multiple, required accept}) async => [
              source('file-${calls++}.txt'),
            ],
            request: (_) async => throw StateError('network'),
            onChanged: (change) => files = change.files,
          ),
        ),
      );
      await pick(t);
      await frames(t);
      expect(files.single.status, IslandUploadStatus.error);
      await pick(t);
      await frames(t);
      expect(files, hasLength(2));
      expect(
        files.map((f) => f.status),
        everyElement(IslandUploadStatus.error),
      );
    },
  );
}

void registerStaleSelectionErrors() {
  for (final operation in ['pick', 'preflight', 'remove']) {
    for (final cancellation in ['disable', 'disable-reenable', 'unmount']) {
      testWidgets(
        'Upload $operation error from invalidated $cancellation intent is ignored',
        (t) async {
          final selected = Completer<List<IslandUploadSource>>(),
              prepared = Completer<IslandUploadSource?>(),
              removed = Completer<bool>();
          final errors = <Object>[];
          var disabled = false, requests = 0;
          late StateSetter update;
          await t.pumpWidget(
            host(
              StatefulBuilder(
                builder: (_, set) {
                  update = set;
                  return IslandUpload.uncontrolled(
                    disabled: disabled,
                    initialFiles: operation == 'remove'
                        ? [
                            const IslandUploadFile(
                              id: 'kept',
                              name: 'kept.txt',
                              status: IslandUploadStatus.done,
                            ),
                          ]
                        : const [],
                    pickFiles: ({required multiple, required accept}) =>
                        operation == 'pick'
                        ? selected.future
                        : Future.value([source('pending.txt')]),
                    beforeUpload: operation == 'preflight'
                        ? (_, __) => prepared.future
                        : null,
                    onRemove: operation == 'remove'
                        ? (_) => removed.future
                        : null,
                    request: (_) async {
                      requests++;
                      return null;
                    },
                    onSelectionError: (error, _) => errors.add(error),
                  );
                },
              ),
            ),
          );
          if (operation == 'remove') {
            await t.tap(find.bySemanticsLabel('删除 kept.txt'));
            await frames(t);
          } else {
            await pick(t);
          }
          if (cancellation == 'unmount') {
            await t.pumpWidget(const SizedBox());
          } else {
            update(() => disabled = true);
            await t.pump();
            if (cancellation == 'disable-reenable') {
              update(() => disabled = false);
              await t.pump();
            }
          }
          final error = StateError('late $operation');
          switch (operation) {
            case 'pick':
              selected.completeError(error, StackTrace.current);
            case 'preflight':
              prepared.completeError(error, StackTrace.current);
            case 'remove':
              removed.completeError(error, StackTrace.current);
          }
          await frames(t, 12);
          expect(
            errors,
            isEmpty,
            reason:
                'A cancelled generation must not report a late $operation error to the current host',
          );
          expect(requests, 0);
          expect(t.takeException(), isNull);
          await t.pumpWidget(const SizedBox());
        },
      );
    }
    testWidgets(
      'Upload current $operation error is delivered once without losing its exception',
      (t) async {
        final error = StateError('current $operation'), errors = <Object>[];
        var requests = 0;
        await t.pumpWidget(
          host(
            IslandUpload.uncontrolled(
              initialFiles: operation == 'remove'
                  ? [
                      const IslandUploadFile(
                        id: 'kept',
                        name: 'kept.txt',
                        status: IslandUploadStatus.done,
                      ),
                    ]
                  : const [],
              pickFiles: ({required multiple, required accept}) =>
                  operation == 'pick'
                  ? Future.error(error)
                  : Future.value([source('pending.txt')]),
              beforeUpload: operation == 'preflight'
                  ? (_, __) => Future.error(error)
                  : null,
              onRemove: operation == 'remove'
                  ? (_) => Future.error(error)
                  : null,
              request: (_) async {
                requests++;
                return null;
              },
              onSelectionError: (value, _) => errors.add(value),
            ),
          ),
        );
        if (operation == 'remove') {
          await t.tap(find.bySemanticsLabel('删除 kept.txt'));
        } else {
          await pick(t);
        }
        await frames(t, 12);
        expect(errors, [same(error)]);
        expect(requests, 0);
        if (operation == 'remove')
          expect(find.text('kept.txt'), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      },
    );
  }
  for (final mutation in ['clear', 'replace-source']) {
    testWidgets('Upload old removal error is ignored after parent $mutation', (
      t,
    ) async {
      final pending = Completer<bool>(), errors = <Object>[];
      late StateSetter update;
      var files = [
        IslandUploadFile(
          id: 'kept',
          name: 'kept.txt',
          status: IslandUploadStatus.done,
          source: source('old.txt'),
        ),
      ];
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandUpload(
                files: files,
                onChanged: (_) {},
                pickFiles: ({required multiple, required accept}) async => [],
                request: (_) async => null,
                onRemove: (_) => pending.future,
                onSelectionError: (error, _) => errors.add(error),
              );
            },
          ),
        ),
      );
      await t.tap(find.bySemanticsLabel('删除 kept.txt'));
      await frames(t);
      update(
        () => files = mutation == 'clear'
            ? []
            : [
                IslandUploadFile(
                  id: 'kept',
                  name: 'new.txt',
                  status: IslandUploadStatus.done,
                  source: source('new.txt'),
                ),
              ],
      );
      await t.pump();
      pending.completeError(StateError('old removal'), StackTrace.current);
      await frames(t, 12);
      expect(errors, isEmpty);
      if (mutation == 'replace-source')
        expect(find.text('new.txt'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
}

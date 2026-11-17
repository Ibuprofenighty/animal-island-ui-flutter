import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  theme: IslandTheme.create(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 600, child: child),
        ),
      ),
    ),
  ),
);

Widget upload({
  IslandUploadProgress? progress,
  IslandUploadListType listType = IslandUploadListType.text,
  double percent = 46,
  IslandUploadStatus status = IslandUploadStatus.uploading,
}) => IslandUpload.uncontrolled(
  // Initial files apply on mount only; every scenario mounts afresh.
  key: UniqueKey(),
  pickFiles: ({required multiple, required accept}) async => const [],
  request: (_) async => null,
  listType: listType,
  progress: progress,
  initialFiles: [
    IslandUploadFile(
      id: 'a',
      name: '海岛游记.png',
      size: 2048,
      status: status,
      percent: percent,
    ),
  ],
);

const name = '海岛游记.png 上传进度';
const mint = Color(0xff19c8b9);
const peach = Color(0xffe59266);

int get ticking => SchedulerBinding.instance.transientCallbackCount;

Finder text(String value) =>
    find.descendant(of: find.byType(IslandUpload), matching: find.text(value));

void main() {
  testWidgets('without progress the spinner and percentage stay', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(host(upload()));
      await t.pump();
      expect(find.bySemanticsLabel(RegExp('^上传中 46%')), findsOneWidget);
      expect(find.byType(IslandProgress), findsNothing);
      expect(find.bySemanticsLabel(name), findsNothing);
    } finally {
      h.dispose();
    }
  });

  testWidgets('the file size sits beside the status at the row end', (t) async {
    await t.pumpWidget(
      host(upload(status: IslandUploadStatus.done, percent: 100)),
    );
    final size = t.getRect(text('2.0 KB'));
    final check = t.getRect(
      find.descendant(
        of: find.bySemanticsLabel('上传完成'),
        matching: find.byType(IslandIcon),
      ),
    );
    expect(check.left - size.right, 8);
    expect(
      size.left - t.getRect(text('海岛游记.png')).right,
      greaterThan(8),
      reason: 'the name column takes the free space',
    );
  });

  testWidgets('bar progress sits below the file name with an 11px value', (
    t,
  ) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          upload(
            progress: const IslandUploadProgress(color: peach, wave: true),
          ),
        ),
      );
      await t.pump();
      final bar = find.byType(IslandProgress);
      expect(bar, findsOneWidget);
      final widget = t.widget<IslandProgress>(bar);
      expect(widget.color, peach);
      expect(widget.wave, isTrue);
      expect(widget.size, IslandSize.small);
      expect(t.getRect(bar).top - t.getRect(text('海岛游记.png')).bottom, 6);
      final node = t.getSemantics(bar);
      expect(node.label, name);
      expect(node.value, '46%');
      final value = text('46%');
      expect(t.widget<Text>(value).style!.fontSize, 11);
      expect(find.bySemanticsLabel(RegExp('^上传中')), findsNothing);
      expect(ticking, greaterThan(0), reason: 'wave plays at 46%');

      await t.pumpWidget(
        host(upload(progress: const IslandUploadProgress(showInfo: false))),
      );
      expect(find.byType(IslandProgress), findsOneWidget);
      expect(text('46%'), findsNothing);
    } finally {
      h.dispose();
    }
  });

  testWidgets('background progress fills the row behind its content', (
    t,
  ) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          upload(
            progress: const IslandUploadProgress(
              type: IslandUploadProgressType.background,
              wave: true,
            ),
          ),
        ),
      );
      await t.pump();
      expect(find.byType(IslandProgress), findsNothing);
      final fill = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == mint,
      );
      final area = t.getRect(
        find.ancestor(of: fill, matching: find.byType(ClipRRect)).first,
      );
      expect(t.getRect(fill).width, closeTo(area.width * .46, .01));
      expect(t.getRect(fill).left, area.left);
      final row = t.getRect(
        find.ancestor(of: text('海岛游记.png'), matching: find.byType(Row)).last,
      );
      expect(area.height, greaterThanOrEqualTo(row.height));

      final node = t.getSemantics(find.bySemanticsLabel(name));
      expect(node.value, '46%');
      expect(find.bySemanticsLabel('删除 海岛游记.png'), findsOneWidget);
      expect(find.bySemanticsLabel('46%'), findsNothing);
      final percent = t.widget<Text>(text('46%'));
      expect(percent.style!.color, const Color(0xff794f27));
      expect(percent.style!.fontSize, 11);
      expect(ticking, greaterThan(0));

      await t.pumpWidget(
        host(
          upload(
            percent: 0,
            progress: const IslandUploadProgress(
              type: IslandUploadProgressType.background,
              wave: true,
            ),
          ),
        ),
      );
      await t.pump(const Duration(seconds: 1));
      expect(ticking, 0, reason: 'still at 0%');
    } finally {
      h.dispose();
    }
  });

  testWidgets('finished files keep their status icons', (t) async {
    final h = t.ensureSemantics();
    try {
      for (final status in [
        IslandUploadStatus.done,
        IslandUploadStatus.error,
      ]) {
        for (final type in IslandUploadProgressType.values) {
          await t.pumpWidget(
            host(
              upload(
                status: status,
                progress: IslandUploadProgress(type: type),
              ),
            ),
          );
          expect(
            find.bySemanticsLabel(
              RegExp(status == IslandUploadStatus.done ? '^上传完成' : '^上传失败'),
            ),
            findsOneWidget,
          );
          expect(find.bySemanticsLabel(name), findsNothing);
        }
      }
    } finally {
      h.dispose();
    }
  });

  testWidgets('unknown progress reads as 0%', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(host(upload(percent: double.nan)));
      expect(find.bySemanticsLabel(RegExp('^上传中 0%')), findsOneWidget);
      await t.pumpWidget(
        host(
          upload(
            percent: double.nan,
            progress: const IslandUploadProgress(
              type: IslandUploadProgressType.background,
            ),
          ),
        ),
      );
      expect(t.getSemantics(find.bySemanticsLabel(name)).value, '0%');
      expect(t.takeException(), isNull);
    } finally {
      h.dispose();
    }
  });

  testWidgets('picture cards show bar or background progress inside the card', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        upload(
          listType: IslandUploadListType.pictureCard,
          progress: const IslandUploadProgress(),
        ),
      ),
    );
    final card = t.getRect(
      find
          .byWidgetPredicate(
            (w) =>
                w is Container &&
                w.constraints ==
                    const BoxConstraints.tightFor(width: 84, height: 84),
          )
          .first,
    );
    final bar = find.byType(IslandProgress);
    expect(t.widget<IslandProgress>(bar).showInfo, isFalse);
    expect(card.contains(t.getRect(bar).topLeft), isTrue);
    expect(card.contains(t.getRect(bar).bottomRight), isTrue);
    expect(t.getRect(bar).top - t.getRect(text('46%')).bottom, closeTo(6, 1));
    expect(t.widget<Text>(text('46%')).style!.color, Colors.white);

    await t.pumpWidget(
      host(
        upload(
          listType: IslandUploadListType.pictureCard,
          progress: const IslandUploadProgress(
            type: IslandUploadProgressType.background,
          ),
        ),
      ),
    );
    expect(find.byType(IslandProgress), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == const Color(0xe0fffdf7),
      ),
      findsOneWidget,
    );
    expect(t.widget<Text>(text('46%')).style!.color, const Color(0xff794f27));
    expect(t.takeException(), isNull);
  });
}

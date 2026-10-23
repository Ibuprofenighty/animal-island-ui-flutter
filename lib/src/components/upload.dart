import '../foundation/dialog_route.dart';
import '../foundation/theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/icon.dart';
import '../internal/action_surface.dart';
import '../foundation/dashed_border.dart';
import '../internal/hover_surface.dart';
import '../internal/owned_route.dart';
part 'upload_types.dart';

class IslandUpload extends StatefulWidget {
  const IslandUpload({
    super.key,
    required this.files,
    required this.onChanged,
    required this.pickFiles,
    required this.request,
    this.dropBuilder,
    this.accept = '',
    this.multiple = false,
    this.maxCount,
    this.disabled = false,
    this.drag = false,
    this.listType = IslandUploadListType.text,
    this.showList = true,
    this.showPreview = true,
    this.showRemove = true,
    this.tip,
    this.child,
    this.beforeUpload,
    this.onRemove,
    this.onPreview,
    this.onExceed,
    this.onSelectionError,
    this.label = '上传文件',
  }) : initialFiles = const [],
       controlled = true,
       assert(maxCount == null || maxCount > 0);
  const IslandUpload.uncontrolled({
    super.key,
    this.initialFiles = const [],
    this.onChanged,
    required this.pickFiles,
    required this.request,
    this.dropBuilder,
    this.accept = '',
    this.multiple = false,
    this.maxCount,
    this.disabled = false,
    this.drag = false,
    this.listType = IslandUploadListType.text,
    this.showList = true,
    this.showPreview = true,
    this.showRemove = true,
    this.tip,
    this.child,
    this.beforeUpload,
    this.onRemove,
    this.onPreview,
    this.onExceed,
    this.onSelectionError,
    this.label = '上传文件',
  }) : files = const [],
       controlled = false,
       assert(maxCount == null || maxCount > 0);
  final List<IslandUploadFile> files, initialFiles;
  final ValueChanged<IslandUploadChange>? onChanged;
  final IslandUploadPicker pickFiles;
  final IslandUploadRequest request;
  final IslandUploadDropBuilder? dropBuilder;
  final String accept, label;
  final bool multiple,
      disabled,
      drag,
      controlled,
      showList,
      showPreview,
      showRemove;
  final int? maxCount;
  final IslandUploadListType listType;
  final Widget? tip, child;
  final IslandUploadBefore? beforeUpload;
  final FutureOr<bool> Function(IslandUploadFile)? onRemove;
  final ValueChanged<IslandUploadFile>? onPreview;
  final void Function(
    List<IslandUploadSource> rejected,
    List<IslandUploadFile> files,
  )?
  onExceed;
  final void Function(Object error, StackTrace stack)? onSelectionError;
  @override
  State<IslandUpload> createState() => _IslandUploadState();
}

class _IslandUploadState extends State<IslandUpload> {
  late List<IslandUploadFile> inner = List.of(widget.initialFiles);
  final jobs = <String, _UploadJob>{}, removing = <String>{};
  final focus = FocusNode();
  Future<void> queue = Future.value();
  Future<void> changes = Future.value();
  int serial = 0, generation = 0;
  bool picking = false, dragging = false;
  IslandDialogRoute<void>? previewRoute;
  List<IslandUploadFile> get files => widget.controlled ? widget.files : inner;
  @override
  void initState() {
    super.initState();
    checkIds();
  }

  void checkIds() {
    if (files.map((f) => f.id).toSet().length != files.length)
      throw ArgumentError('Upload file IDs must be unique.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    previewRoute?.updateReducedMotion(MediaQuery.disableAnimationsOf(context));
  }

  @override
  void didUpdateWidget(IslandUpload old) {
    super.didUpdateWidget(old);
    checkIds();
    if (!old.disabled && widget.disabled) {
      generation++;
      picking = false;
      dragging = false;
    }
    reconcile();
  }

  void reconcile() {
    for (final e in jobs.entries.toList()) {
      final current = files.where((f) => f.id == e.key).firstOrNull;
      if (current == null || !identical(current.source, e.value.file.source)) {
        jobs.remove(e.key);
        e.value.cancellation._cancel();
      }
    }
  }

  void emit(IslandUploadFile file, List<IslandUploadFile> next) {
    if (!mounted) return;
    final snapshot = List<IslandUploadFile>.unmodifiable(next);
    if (!widget.controlled) setState(() => inner = snapshot);
    widget.onChanged?.call(IslandUploadChange(file, snapshot));
  }

  bool accepts(IslandUploadSource file) {
    final patterns = widget.accept
        .toLowerCase()
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
    if (patterns.isEmpty) return true;
    return patterns.any(
      (p) => p.startsWith('.')
          ? file.name.toLowerCase().endsWith(p)
          : p.endsWith('/*')
          ? file.mimeType.toLowerCase().startsWith(p.substring(0, p.length - 1))
          : file.mimeType.toLowerCase() == p,
    );
  }

  Future<void> frame() async {
    final done = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      done.complete();
    });
    WidgetsBinding.instance.scheduleFrame();
    await done.future;
  }

  Future<void> pick() async {
    if (widget.disabled || picking) return;
    final ticket = generation;
    setState(() => picking = true);
    try {
      final selected = await widget.pickFiles(
        multiple: widget.multiple,
        accept: widget.accept,
      );
      if (mounted && ticket == generation && !widget.disabled) ingest(selected);
    } catch (error, stack) {
      if (mounted && ticket == generation)
        widget.onSelectionError?.call(error, stack);
    } finally {
      if (mounted && ticket == generation) setState(() => picking = false);
    }
  }

  void ingest(List<IslandUploadSource> batch) {
    if (!mounted || widget.disabled) return;
    final ticket = generation;
    final selected = List<IslandUploadSource>.of(
      widget.multiple ? batch : batch.take(1),
    );
    queue = queue
        .then((_) async {
          final rejected = <IslandUploadSource>[];
          for (final source in selected) {
            if (!mounted || ticket != generation || widget.disabled) return;
            if (!accepts(source)) continue;
            IslandUploadSource? prepared = source;
            try {
              if (widget.beforeUpload != null)
                prepared = await widget.beforeUpload!(
                  source,
                  List.unmodifiable(selected),
                );
            } catch (error, stack) {
              if (mounted && ticket == generation) {
                widget.onSelectionError?.call(error, stack);
              }
              continue;
            }
            if (!mounted || ticket != generation || widget.disabled) return;
            if (prepared == null) continue;
            if (widget.maxCount != null &&
                widget.maxCount! > 1 &&
                files.length >= widget.maxCount!) {
              rejected.add(source);
              continue;
            }
            final item = IslandUploadFile(
              id: 'upload-${identityHashCode(this)}-${serial++}',
              name: source.name,
              size: source.size,
              mimeType: source.mimeType,
              source: prepared,
              thumbnail: source.thumbnail,
              thumbnailBuilder: source.thumbnailBuilder,
            );
            final job = _UploadJob(item, widget.request);
            jobs[item.id] = job;
            emit(item, widget.maxCount == 1 ? [item] : [...files, item]);
            await frame();
            if (!mounted || ticket != generation || widget.disabled) {
              if (jobs.remove(item.id) case final abandoned?)
                abandoned.cancellation._cancel();
              return;
            }
            reconcile();
            if (jobs[item.id] == job) {
              unawaited(transfer(job));
            }
          }
          if (mounted && ticket == generation && rejected.isNotEmpty)
            widget.onExceed?.call(
              List.unmodifiable(rejected),
              List.unmodifiable(files),
            );
        })
        .catchError((Object error, StackTrace stack) {
          if (mounted) widget.onSelectionError?.call(error, stack);
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'animal_island_ui Upload',
            ),
          );
        });
  }

  bool owns(_UploadJob job) =>
      mounted &&
      !job.cancellation.isCancelled &&
      jobs[job.file.id] == job &&
      files.any(
        (f) => f.id == job.file.id && identical(f.source, job.file.source),
      );
  Future<void> update(
    _UploadJob job, {
    double? progress,
    IslandUploadStatus? status,
    Object? response,
    Object? error,
  }) => changes = changes
      .then((_) async {
        if (!owns(job)) return;
        final current = files.firstWhere((f) => f.id == job.file.id);
        final next = current.copyWith(
          percent: progress,
          status: status,
          response: response,
          error: error,
        );
        emit(next, [
          for (final f in files)
            if (f.id == next.id) next else f,
        ]);
        await frame();
      })
      .catchError((Object error, StackTrace stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'animal_island_ui Upload',
          ),
        );
      });

  void progress(_UploadJob job, double value) {
    if (!owns(job) || job.finishing || !value.isFinite) return;
    job.pendingProgress = value.clamp(0, 100).roundToDouble();
    if (job.flushingProgress) return;
    job.flushingProgress = true;
    unawaited(() async {
      try {
        while (owns(job) && !job.finishing && job.pendingProgress != null) {
          final latest = job.pendingProgress!;
          job.pendingProgress = null;
          await update(job, progress: latest);
        }
      } finally {
        job.flushingProgress = false;
      }
    }());
  }

  Future<void> transfer(_UploadJob job) async {
    try {
      final response = await job.request(
        IslandUploadTransfer(
          file: job.file.source!,
          cancellation: job.cancellation,
          onProgress: (p) => progress(job, p),
        ),
      );
      job.finishing = true;
      await update(
        job,
        progress: 100,
        status: IslandUploadStatus.done,
        response: response,
      );
    } catch (error) {
      job.finishing = true;
      await update(job, status: IslandUploadStatus.error, error: error);
    } finally {
      if (jobs[job.file.id] == job) jobs.remove(job.file.id);
    }
  }

  bool ownsRemoval(IslandUploadFile file, int ticket) =>
      mounted &&
      ticket == generation &&
      !widget.disabled &&
      files.any((f) => f.id == file.id && identical(f.source, file.source));

  Future<void> remove(IslandUploadFile file) async {
    if (widget.disabled || !removing.add(file.id)) return;
    final ticket = generation;
    try {
      if (widget.onRemove != null && !await widget.onRemove!(file)) return;
      if (!ownsRemoval(file, ticket)) return;
      emit(
        file.copyWith(status: IslandUploadStatus.removed),
        files.where((f) => f.id != file.id).toList(),
      );
      await frame();
      if (mounted) reconcile();
    } catch (error, stack) {
      if (ownsRemoval(file, ticket)) {
        widget.onSelectionError?.call(error, stack);
      }
    } finally {
      removing.remove(file.id);
    }
  }

  void preview(IslandUploadFile file) {
    if (widget.disabled) return;
    if (widget.onPreview != null) {
      widget.onPreview!(file);
      return;
    }
    final image = file.thumbnail;
    if ((image == null && file.thumbnailBuilder == null) ||
        previewRoute != null)
      return;
    final navigator = Navigator.of(context, rootNavigator: true);
    late final IslandDialogRoute<void> route;
    route = IslandDialogRoute<void>(
      context: context,
      barrierColor: const Color(0xd10f0c08),
      barrierLabel: '关闭预览',
      builder: (context) => Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * .9,
                maxHeight: MediaQuery.sizeOf(context).height * .88,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: file.thumbnailBuilder != null
                    ? Builder(
                        builder: (context) =>
                            file.thumbnailBuilder!(context, BoxFit.contain),
                      )
                    : Image(
                        image: image!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Text(file.name),
                      ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: ActionSurface(
              label: '关闭预览',
              autofocus: true,
              onActivate: () => navigator.removeRoute(route),
              builder: (_, states) => Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: IslandTokens.light.inputSurface,
                  border: Border.all(
                    color: states.contains(WidgetState.focused)
                        ? IslandTokens.light.focus
                        : Colors.transparent,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: IslandIcon(IslandGlyph.close, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    previewRoute = route;
    navigator.push(route).whenComplete(() {
      if (previewRoute == route) previewRoute = null;
      if (mounted && ModalRoute.of(context)?.isCurrent == true)
        focus.requestFocus();
    });
  }

  @override
  void dispose() {
    generation++;
    for (final job in jobs.values.toList()) {
      job.cancellation._cancel();
    }
    jobs.clear();
    if (previewRoute case final route?) dismissOwnedRouteAfterFrame(route);
    previewRoute = null;
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.listType == IslandUploadListType.pictureCard;
    Widget trigger = ActionSurface(
      focusNode: focus,
      label: widget.label,
      onActivate: widget.disabled ? null : pick,
      builder: (context, states) {
        final hover = states.contains(WidgetState.hovered),
            pressed = states.contains(WidgetState.pressed);
        final highlight = states.contains(WidgetState.focused);
        if (widget.drag || cards) {
          final active = (hover || dragging) && !widget.disabled;
          final radius = cards ? 16.0 : 20.0;
          return CustomPaint(
            foregroundPainter: IslandDashedBorderPainter(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              color: highlight
                  ? IslandTokens.light.focus
                  : active
                  ? IslandTokens.light.link
                  : IslandTokens.light.muted,
              strokeWidth: cards ? IslandTheme.borderWidth(context, 1.5) : 2,
              dash: 6,
              gap: 4,
            ),
            child: Container(
              width: cards ? 84 : double.infinity,
              height: cards ? 84 : null,
              padding: cards
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
              decoration: BoxDecoration(
                color: dragging
                    ? const Color(0xffe6f9f6)
                    : const Color(0xfffffdf7),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Center(
                child:
                    widget.child ??
                    (cards
                        ? const IslandIcon(IslandGlyph.upload, size: 28)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 1.5,
                                child: const IslandIcon(
                                  IslandGlyph.upload,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '点击或拖拽文件到这里',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? IslandTokens.light.link
                                      : IslandTokens.light.muted,
                                ),
                              ),
                            ],
                          )),
              ),
            ),
          );
        }
        if (widget.child != null) return widget.child!;
        return Transform.translate(
          offset: Offset(
            0,
            pressed
                ? 2
                : hover
                ? -1
                : 0,
          ),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xfff8f8f0),
              borderRadius: BorderRadius.circular(50),
              border: highlight
                  ? Border.all(color: IslandTokens.light.focus, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Color(widget.disabled ? 0xffd5c8b8 : 0xffbdaea0),
                  offset: Offset(
                    0,
                    pressed
                        ? 1
                        : hover
                        ? 6
                        : 5,
                  ),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IslandIcon(IslandGlyph.upload, size: 18),
                SizedBox(width: 8),
                Text(
                  '点击上传',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff794f27),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (widget.drag && widget.dropBuilder != null)
      trigger = widget.dropBuilder!(
        context,
        trigger,
        !widget.disabled && ModalRoute.of(context)?.isCurrent != false,
        ingest,
        (active) {
          if (mounted) setState(() => dragging = active);
        },
      );
    return Opacity(
      opacity: widget.disabled ? .55 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cards && widget.showList)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final file in files) card(file), trigger],
            )
          else
            trigger,
          if (widget.tip != null) ...[
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: IslandTheme.of(context).muted,
              ),
              child: widget.tip!,
            ),
          ],
          if (!cards && widget.showList && files.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < files.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  row(files[i]),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String size(int bytes) => bytes >= 1048576
      ? '${(bytes / 1048576).toStringAsFixed(1)} MB'
      : bytes >= 1024
      ? '${(bytes / 1024).toStringAsFixed(1)} KB'
      : '${bytes} B';
  Widget iconAction(
    String label,
    IslandGlyph icon,
    VoidCallback action, {
    double dimension = 22,
  }) => ActionSurface(
    label: label,
    onActivate: widget.disabled ? null : action,
    builder: (_, states) => Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: states.contains(WidgetState.hovered)
            ? const Color(0xffe6f9f6)
            : IslandTokens.light.inputSurface,
        shape: BoxShape.circle,
        border: states.contains(WidgetState.focused)
            ? Border.all(color: IslandTokens.light.focus, width: 2)
            : null,
      ),
      child: IslandIcon(icon, size: 16),
    ),
  );
  Widget thumb(IslandUploadFile file, {bool card = false}) =>
      file.thumbnailBuilder != null
      ? Builder(
          builder: (context) => file.thumbnailBuilder!(context, BoxFit.cover),
        )
      : file.thumbnail == null
      ? IslandIcon(IslandGlyph.file, size: card ? 25.6 : 14)
      : Image(
          image: file.thumbnail!,
          fit: BoxFit.cover,
          width: card ? 84 : 30,
          height: card ? 84 : 30,
          errorBuilder: (_, _, _) =>
              IslandIcon(IslandGlyph.file, size: card ? 25.6 : 14),
        );
  Widget row(IslandUploadFile file) => HoverSurface(
    key: ValueKey(file.id),
    enabled: !widget.disabled,
    cursor: MouseCursor.defer,
    builder: (states) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: file.status == IslandUploadStatus.error
            ? const Color(0xfffdeeee)
            : states.contains(WidgetState.hovered)
            ? const Color(0xffe6f9f6)
            : const Color(0xfffffdf7),
        border: Border.all(
          color: file.status == IslandUploadStatus.error
              ? IslandTokens.light.dangerText
              : const Color(0xffe8dcc8),
          width: IslandTheme.borderWidth(context, 1.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (widget.listType == IslandUploadListType.picture)
            Container(
              width: 30,
              height: 30,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffe8dcc8),
                  width: IslandTheme.borderWidth(context, 1.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: thumb(file),
            )
          else
            const IslandIcon(IslandGlyph.file, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff794f27),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  size(file.size),
                  style: TextStyle(
                    fontSize: 11,
                    color: IslandTokens.light.muted,
                  ),
                ),
              ],
            ),
          ),
          status(file),
          if (widget.showPreview &&
              (file.thumbnail != null || file.thumbnailBuilder != null)) ...[
            const SizedBox(width: 4),
            iconAction('预览 ${file.name}', IslandGlyph.eye, () => preview(file)),
          ],
          if (widget.showRemove) ...[
            const SizedBox(width: 4),
            iconAction(
              '删除 ${file.name}',
              IslandGlyph.close,
              () => remove(file),
            ),
          ],
        ],
      ),
    ),
  );
  Widget status(IslandUploadFile file) =>
      file.status == IslandUploadStatus.removed
      ? const SizedBox.shrink()
      : Semantics(
          label: switch (file.status) {
            IslandUploadStatus.done => '上传完成',
            IslandUploadStatus.error => '上传失败',
            _ => '上传中 ${file.percent.round()}%',
          },
          child: file.status == IslandUploadStatus.uploading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _UploadSpinner(),
                    const SizedBox(width: 4),
                    Text(
                      '${file.percent.round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: IslandTokens.light.link,
                      ),
                    ),
                  ],
                )
              : IslandIcon(
                  file.status == IslandUploadStatus.done
                      ? IslandGlyph.check
                      : IslandGlyph.close,
                  size: 16,
                ),
        );
  Widget card(IslandUploadFile file) => _UploadCard(
    key: ValueKey(file.id),
    builder: (hover) => Container(
      width: 84,
      height: 84,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xfffffdf7),
        border: Border.all(
          width: IslandTheme.borderWidth(context, 1.5),
          color: file.status == IslandUploadStatus.error
              ? IslandTokens.light.dangerText
              : file.status == IslandUploadStatus.done
              ? IslandTokens.light.muted
              : const Color(0xffe8dcc8),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: GestureDetector(
              onTap:
                  !widget.disabled &&
                      widget.showPreview &&
                      (file.thumbnail != null || file.thumbnailBuilder != null)
                  ? () => preview(file)
                  : null,
              child: thumb(file, card: true),
            ),
          ),
          if (file.status == IslandUploadStatus.uploading ||
              file.status == IslandUploadStatus.error)
            ColoredBox(
              color: const Color(0x8c0f0c08),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: IslandTokens.light.inputSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: status(file),
                ),
              ),
            ),
          if (widget.showPreview &&
              (file.thumbnail != null || file.thumbnailBuilder != null))
            Positioned(
              top: 4,
              left: 4,
              child: IgnorePointer(
                ignoring: !hover,
                child: Opacity(
                  opacity: hover ? 1 : 0,
                  child: iconAction(
                    '预览 ${file.name}',
                    IslandGlyph.eye,
                    () => preview(file),
                    dimension: 18,
                  ),
                ),
              ),
            ),
          if (widget.showRemove)
            Positioned(
              top: 4,
              right: 4,
              child: IgnorePointer(
                ignoring: !hover,
                child: Opacity(
                  opacity: hover ? 1 : 0,
                  child: iconAction(
                    '删除 ${file.name}',
                    IslandGlyph.close,
                    () => remove(file),
                    dimension: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _UploadCard extends StatefulWidget {
  const _UploadCard({super.key, required this.builder});
  final Widget Function(bool hover) builder;
  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hover = true),
    onExit: (_) => setState(() => hover = false),
    child: Focus(
      canRequestFocus: false,
      onFocusChange: (v) => setState(() => focus = v),
      child: widget.builder(hover || focus),
    ),
  );
}

class _UploadSpinner extends StatefulWidget {
  const _UploadSpinner();
  @override
  State<_UploadSpinner> createState() => _UploadSpinnerState();
}

class _UploadSpinnerState extends State<_UploadSpinner>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.stop();
    } else {
      motion.repeat();
    }
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: motion,
    child: const SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(painter: _UploadSpinnerPaint()),
    ),
  );
}

class _UploadSpinnerPaint extends CustomPainter {
  const _UploadSpinnerPaint();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    canvas.drawOval(
      rect,
      Paint()
        ..color = const Color(0xffe6f9f6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawArc(
      rect,
      -2.356194490192345,
      1.5707963267948966,
      false,
      Paint()
        ..color = IslandTokens.light.link
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_UploadSpinnerPaint old) => false;
}

import '../foundation/dialog_route.dart';
import '../internal/focus_outline.dart';
import '../foundation/theme.dart';
import '../internal/owned_route.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/colorway.dart';
import '../foundation/icon.dart';
import '../foundation/localizations.dart';
import '../internal/action_surface.dart';
import '../internal/managed_image.dart';
import '../internal/viewport_deferred.dart';

enum IslandImageVariant { normal, bordered, stamp }

class IslandImage extends StatefulWidget {
  const IslandImage({
    super.key,
    required this.image,
    this.alt = '',
    this.width,
    this.height,
    this.colorway,
    this.variant = IslandImageVariant.normal,
    this.stampYear,
    this.lazy = false,
    this.preview = true,
    this.fit = BoxFit.fill,
    this.onLoaded,
    this.onError,
  }) : assert(width == null || width > 0),
       assert(height == null || height > 0);
  final ImageProvider image;
  final String alt;
  final double? width, height;
  final IslandColorway? colorway;
  final IslandImageVariant variant;
  final String? stampYear;
  final bool lazy, preview;
  final BoxFit fit;
  final VoidCallback? onLoaded;
  final void Function(Object, StackTrace?)? onError;
  @override
  State<IslandImage> createState() => _IslandImageState();
}

class _IslandImageState extends State<IslandImage> {
  bool failed = false, reportedLoad = false;
  final trigger = FocusNode();
  IslandDialogRoute<void>? route;
  NavigatorState? navigator;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    route?.updateReducedMotion(MediaQuery.disableAnimationsOf(context));
  }

  @override
  void didUpdateWidget(IslandImage old) {
    super.didUpdateWidget(old);
    if (old.image != widget.image) {
      failed = false;
      reportedLoad = false;
      removePreview();
    }
    if (!widget.preview) removePreview();
  }

  void removePreview() {
    final old = route, owner = navigator;
    route = null;
    navigator = null;
    if (old == null || owner == null) return;
    dismissOwnedRouteAfterFrame(old);
  }

  @override
  void dispose() {
    removePreview();
    trigger.dispose();
    super.dispose();
  }

  Future<void> openPreview() async {
    if (route != null || failed) return;
    final owner = Navigator.of(context, rootNavigator: true);
    final strings = IslandLocalizations.of(context);
    final source = widget.image, alt = widget.alt;
    final next = IslandDialogRoute<void>(
      context: context,
      barrierColor: const Color(0x8c000000),
      barrierDismissible: true,
      barrierLabel: strings.closePreview,
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      builder: (context) {
        final viewport = MediaQuery.sizeOf(context);
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              namesRoute: true,
              label: alt.isEmpty
                  ? strings.imagePreview
                  : strings.viewImage(alt),
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minWidth: math.min(viewport.width * .88, 64),
                      minHeight: math.min(viewport.height * .86, 64),
                      maxWidth: math.min(viewport.width * .88, 1100),
                      maxHeight: viewport.height * .86,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x8c2b2118),
                          offset: Offset(0, 12),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                        image: source,
                        fit: BoxFit.contain,
                        semanticLabel: alt,
                        errorBuilder: (_, error, stack) => Container(
                          color: IslandTokens.light.inputSurface,
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            strings.imageFailed,
                            style: TextStyle(color: IslandTokens.light.ink),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ActionSurface(
                      autofocus: true,
                      label: strings.closePreview,
                      onActivate: () => Navigator.of(context).pop(),
                      builder: (_, states) => AnimatedScale(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 150),
                        curve: Curves.ease,
                        scale: states.contains(WidgetState.hovered) ? 1.06 : 1,
                        child: Container(
                          width: 40,
                          height: 40,
                          foregroundDecoration: FocusOutline(
                            const CircleBorder(),
                            states.contains(WidgetState.focused)
                                ? IslandTokens.light.focus
                                : Colors.transparent,
                            width: 2,
                            offset: 2,
                            backingColor: states.contains(WidgetState.focused)
                                ? const Color(0xffd8dce2)
                                : null,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: states.contains(WidgetState.hovered)
                                ? const Color(0xffc4c9d0)
                                : const Color(0xffd8dce2),
                            border: Border.all(
                              color: const Color(0xbfffffff),
                              width: IslandTheme.borderWidth(context, 1.5),
                            ),
                          ),
                          child: const Center(
                            child: CustomPaint(
                              size: Size.square(16),
                              painter: _PreviewCloseMark(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    route = next;
    navigator = owner;
    await owner.push(next);
    if (route == next) {
      route = null;
      navigator = null;
    }
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? true))
      trigger.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final strings = IslandLocalizations.of(context);
    final stamp = widget.variant == IslandImageVariant.stamp && !failed;
    final normal = widget.variant == IslandImageVariant.normal && !failed;
    final padding = normal
        ? 0.0
        : stamp
        ? 14.0
        : 12.0;
    final color = stamp
        ? const Color(0xfffbfaf5)
        : normal
        ? Colors.transparent
        : widget.colorway == null
        ? Colors.white
        : paperPalette(widget.colorway!).$1;
    final radius = normal
        ? 12.0
        : stamp
        ? 0.0
        : 8.0;
    final imageWidth = widget.width == null
        ? null
        : math.max(0.0, widget.width! - padding * 2);
    final imageHeight = widget.height == null
        ? null
        : math.max(0.0, widget.height! - padding * 2);
    Widget error() => Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            IslandIcon(
              IslandGlyph.image,
              size: 32,
              color: IslandTokens.light.muted,
            ),
            Text(
              strings.imageFailed,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: IslandTokens.light.muted,
              ),
            ),
          ],
        ),
      ),
    );
    Widget photo = photoResolved(stamp, imageWidth, imageHeight, error);
    if (widget.lazy && !failed)
      photo = ViewportDeferred(
        builder: (_) => photoResolved(stamp, imageWidth, imageHeight, error),
        placeholder: SizedBox(
          width: imageWidth ?? 64,
          height: imageHeight ?? 64,
        ),
      );
    Widget content = Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(padding),
          child: failed
              ? SizedBox(width: imageWidth, height: imageHeight, child: error())
              : photo,
        ),
        if (stamp)
          const Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: IgnorePointer(
                child: CustomPaint(painter: const _Halftone()),
              ),
            ),
          ),
        if (stamp && widget.stampYear != null)
          Positioned(
            top: 18,
            right: 19,
            child: ExcludeSemantics(
              child: Text(
                widget.stampYear!,
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.44,
                  color: Colors.white,
                  backgroundColor: Color(0xff2b2118),
                  shadows: [
                    Shadow(
                      color: Color(0x8c000000),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
    content = SizedBox(
      width: widget.width,
      height: widget.height,
      child: ColoredBox(color: color, child: content),
    );
    if (stamp) {
      // The reference applies its mask after filtering. Its opaque paper
      // covers inner filter output and the final mask clips outside shadows.
      content = ClipPath(clipper: const _StampClip(), child: content);
    } else {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: normal
              ? const [
                  BoxShadow(
                    color: Color(0x4032325d),
                    offset: Offset(0, 13),
                    blurRadius: 27,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Color(0x4d000000),
                    offset: Offset(0, 8),
                    blurRadius: 16,
                    spreadRadius: -8,
                  ),
                  BoxShadow(
                    color: Color(0x08000000),
                    offset: Offset(0, -6),
                    blurRadius: 16,
                    spreadRadius: -6,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 8),
                    blurRadius: 14,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }
    if (widget.preview && !failed) {
      final visual = content;
      return ActionSurface(
        focusNode: trigger,
        label: widget.alt.isEmpty ? strings.imagePreview : widget.alt,
        onActivate: openPreview,
        builder: (_, states) => MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: Container(
            foregroundDecoration: states.contains(WidgetState.focused)
                ? FocusOutline(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    IslandTokens.light.onLeaf,
                    width: 2,
                    offset: -3,
                    backingColor: IslandTokens.light.paper,
                  )
                : const BoxDecoration(),
            child: ExcludeSemantics(child: visual),
          ),
        ),
      );
    }
    return Semantics(
      image: widget.alt.isNotEmpty || failed,
      label: widget.alt.isEmpty
          ? (failed ? strings.imageFailed : null)
          : widget.alt,
      child: ExcludeSemantics(child: content),
    );
  }

  Widget photoResolved(
    bool stamp,
    double? width,
    double? height,
    Widget Function() error,
  ) {
    Widget photo = ManagedImage(
      image: widget.image,
      width: width,
      height: height,
      fit: widget.fit,
      onLoaded: () {
        if (reportedLoad) return;
        reportedLoad = true;
        widget.onLoaded?.call();
      },
      onError: (e, s) {
        setState(() => failed = true);
        widget.onError?.call(e, s);
        return true;
      },
      errorBuilder: (_, e, s, a) => error(),
    );
    if (stamp)
      photo = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          .973228,
          .051564,
          .005208,
          0,
          -3.825,
          .015328,
          1.009464,
          .005208,
          0,
          -3.825,
          .015328,
          .051564,
          .963108,
          0,
          -3.825,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: photo,
      );
    return photo;
  }
}

Path _stampPath(Size size) {
  var path = Path()..addRect(Offset.zero & size);
  // Centered CSS repeat tiles can put partial holes beyond a corner.
  double firstCenter(double extent) =>
      ((-5 - extent / 2) / 16).ceil() * 16 + extent / 2;
  for (double x = firstCenter(size.width); x <= size.width + 5; x += 16) {
    for (final y in [0.0, size.height])
      path = Path.combine(
        PathOperation.difference,
        path,
        Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: 5)),
      );
  }
  for (double y = firstCenter(size.height); y <= size.height + 5; y += 16) {
    for (final x in [0.0, size.width])
      path = Path.combine(
        PathOperation.difference,
        path,
        Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: 5)),
      );
  }
  return path;
}

class _StampClip extends CustomClipper<Path> {
  const _StampClip();
  @override
  Path getClip(Size size) => _stampPath(size);
  @override
  bool shouldReclip(_StampClip old) => false;
}

class _Halftone extends CustomPainter {
  const _Halftone();
  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()..color = const Color(0x1412121c);
    for (double x = 2; x < s.width; x += 4)
      for (double y = 2; y < s.height; y += 4)
        c.drawCircle(Offset(x, y), .6, paint);
  }

  @override
  bool shouldRepaint(_Halftone old) => false;
}

/// Pinned preview mark: two 16 x 2 rounded bars centered and rotated +/-45deg.
class _PreviewCloseMark extends CustomPainter {
  const _PreviewCloseMark();
  @override
  void paint(Canvas canvas, Size size) {
    final bar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 2),
      const Radius.circular(2),
    );
    final pen = Paint()..color = IslandTokens.light.ink;
    for (final angle in [-math.pi / 4, math.pi / 4]) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(angle);
      canvas.drawRRect(bar, pen);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PreviewCloseMark old) => false;
}

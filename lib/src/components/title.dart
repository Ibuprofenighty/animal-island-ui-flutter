import '../internal/content_scope.dart';
import '../internal/light_surface_scope.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../foundation/size.dart';
import '../foundation/colorway.dart';

enum IslandTitleVariant { ribbon, layer, tab }

enum IslandPalette {
  green,
  pink,
  purple,
  blue,
  yellow,
  orange,
  teal,
  softGreen,
  red,
  lime,
  yellowGreen,
  brown,
  peach,
}

class IslandTitle extends StatefulWidget {
  const IslandTitle({
    super.key,
    required this.child,
    this.variant = IslandTitleVariant.ribbon,
    this.palette = IslandPalette.green,
    this.size = IslandSize.middle,
  });
  final Widget child;
  final IslandTitleVariant variant;
  final IslandPalette palette;
  final IslandSize size;
  @override
  State<IslandTitle> createState() => _IslandTitleState();
}

class _IslandTitleState extends State<IslandTitle> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final font = switch (widget.size) {
      IslandSize.small => 14.0,
      IslandSize.middle => 20.0,
      IslandSize.large => 28.0,
    };
    final c = titlePalette[widget.palette.index];
    final variant = widget.variant;
    final ribbon = variant == IslandTitleVariant.ribbon;
    final tab = variant == IslandTitleVariant.tab;
    final padding =
        font *
        (ribbon
            ? 1.6
            : tab
            ? 1.5
            : 1.55);
    return Semantics(
      header: true,
      child: OverflowBox(
        alignment: AlignmentDirectional.centerStart,
        minWidth: 0,
        maxWidth: double.infinity,
        fit: OverflowBoxFit.deferToChild,
        child: MouseRegion(
          onEnter: (_) => setState(() => hovered = true),
          onExit: (_) => setState(() => hovered = false),
          child: AnimatedScale(
            scale: hovered && !ribbon ? 1.06 : 1,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.ease,
            child: CustomPaint(
              painter: _TitlePaint(variant, c, font),
              child: Padding(
                padding: EdgeInsets.only(
                  left: padding + (tab ? font * .4 : 0),
                  right: padding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        font * (variant == IslandTitleVariant.layer ? 2.1 : 2),
                  ),
                  child: LightSurfaceScope(
                    onSurface: Color(c.$4),
                    child: ContentScope(
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      textStyle: TextStyle(
                        fontSize: font,
                        fontWeight: FontWeight.w900,
                        letterSpacing: font * .04,
                        height: 1,
                        color: Color(c.$4),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: ribbon ? font * .11 : 0),
                        child: Align(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitlePaint extends CustomPainter {
  const _TitlePaint(this.variant, this.colors, this.font);
  final IslandTitleVariant variant;
  final (int, int, int, int) colors;
  final double font;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, f = font;
    final front = Paint()..color = Color(colors.$1),
        back = Paint()..color = Color(colors.$2),
        fold = Paint()..color = Color(colors.$3);
    if (variant == IslandTitleVariant.ribbon) {
      final left = Path()
        ..moveTo(-.6 * f, h - 1.3 * f)
        ..lineTo(1.1 * f, h - 1.3 * f)
        ..lineTo(1.1 * f, h + .4 * f)
        ..lineTo(-.6 * f, h + .4 * f)
        ..lineTo(-.09 * f, h - .45 * f)
        ..close();
      canvas.drawPath(left, back);
      canvas.save();
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
      canvas.drawPath(left, back);
      canvas.restore();
      canvas.drawPath(
        Path()
          ..moveTo(.15 * f, h - .05 * f)
          ..lineTo(1.1 * f, h - .05 * f)
          ..lineTo(1.1 * f, h + .4 * f)
          ..close(),
        fold,
      );
      canvas.drawPath(
        Path()
          ..moveTo(w - .16 * f, h - .05 * f)
          ..lineTo(w - 1.11 * f, h - .05 * f)
          ..lineTo(w - 1.11 * f, h + .4 * f)
          ..close(),
        fold,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(.1 * f, 0, w - .1 * f, h),
          Radius.circular(.2 * f),
        ),
        front,
      );
    } else if (variant == IslandTitleVariant.layer) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-.26 * f, -.3 * f, w - .65 * f, h),
          Radius.circular(.35 * f),
        ),
        back,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(.35 * f)),
        front,
      );
    } else {
      // A 135-degree gradient's .9em stop intersects each edge at
      // .9 * sqrt(2)em. The fold overlays the intact bottom-right corner.
      final cut = .9 * math.sqrt2 * f;
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(.32 * f)),
      );
      canvas.drawPath(
        Path()
          ..moveTo(cut, 0)
          ..lineTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..lineTo(0, cut)
          ..close(),
        front,
      );
      canvas.restore();
      canvas.drawPath(
        Path()
          ..moveTo(w, h - .9 * f)
          ..lineTo(w, h)
          ..lineTo(w - .9 * f, h)
          ..close(),
        fold,
      );
    }
  }

  @override
  bool shouldRepaint(_TitlePaint old) =>
      old.variant != variant || old.colors != colors || old.font != font;
}

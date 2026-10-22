import 'package:flutter/material.dart';

enum IslandDividerVariant { dashedBrown, thin, hairline, waveYellow, squiggle }

class IslandDivider extends StatelessWidget {
  const IslandDivider({
    super.key,
    this.variant = IslandDividerVariant.dashedBrown,
    this.iconBuilder,
    this.iconSize = 24,
    this.iconGap = 8,
  }) : assert(iconSize > 0),
       assert(iconGap >= 0);
  final IslandDividerVariant variant;

  /// A builder gives each repeated decorative slot its own widget identity.
  final WidgetBuilder? iconBuilder;
  final double iconSize, iconGap;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: iconBuilder == null
        ? SizedBox(
            width: double.infinity,
            height: switch (variant) {
              IslandDividerVariant.thin || IslandDividerVariant.hairline => 1,
              IslandDividerVariant.waveYellow => 14,
              IslandDividerVariant.squiggle => 10,
              IslandDividerVariant.dashedBrown => 12,
            },
            child: CustomPaint(painter: _DividerPainter(variant)),
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final count = (constraints.maxWidth / (iconSize + iconGap))
                  .floor()
                  .clamp(1, 1 << 30);
              return ClipRect(
                child: SizedBox(
                  height: iconSize,
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 0,
                    maxWidth: count * iconSize + (count - 1) * iconGap,
                    child: Row(
                      children: [
                        for (var i = 0; i < count; i++) ...[
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: iconBuilder!(context),
                          ),
                          if (i < count - 1)
                            SizedBox(
                              width: iconGap,
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 2,
                                  color: const Color(0xffc4b89e),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
  );
}

class _DividerPainter extends CustomPainter {
  const _DividerPainter(this.variant);
  final IslandDividerVariant variant;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final path = Path();
    switch (variant) {
      case IslandDividerVariant.thin:
        paint
          ..color = const Color(0xffe8dec7)
          ..strokeWidth = 1;
        path
          ..moveTo(0, .5)
          ..lineTo(size.width, .5);
      case IslandDividerVariant.hairline:
      case IslandDividerVariant.dashedBrown:
        final thin = variant == IslandDividerVariant.hairline;
        paint
          ..color = Color(thin ? 0xffd5c3a2 : 0xffc4b89e)
          ..strokeWidth = thin ? 1 : 2;
        final step = thin ? 6.0 : 12.0;
        for (double x = 0; x < size.width; x += step) {
          path
            ..moveTo(x, size.height / 2)
            ..lineTo((x + step / 2).clamp(0, size.width), size.height / 2);
        }
      case IslandDividerVariant.waveYellow:
        paint
          ..color = const Color(0xfff5d04a)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final start = ((size.width - 40) / 2) % 40 - 40;
        path.moveTo(start, 7);
        for (double x = start; x < size.width; x += 40) {
          path
            ..quadraticBezierTo(x + 10, 0, x + 20, 7)
            ..quadraticBezierTo(x + 30, 14, x + 40, 7);
        }
      case IslandDividerVariant.squiggle:
        paint
          ..color = const Color(0xff19c8b9)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;
        final start = ((size.width - 120) / 2) % 120 - 120;
        path.moveTo(start, 2.5);
        for (double x = start; x < size.width; x += 120) {
          path
            ..cubicTo(x + 30, 2.5, x + 30, 7.5, x + 60, 7.5)
            ..cubicTo(x + 90, 7.5, x + 90, 2.5, x + 120, 2.5);
        }
    }
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DividerPainter old) => old.variant != variant;
}

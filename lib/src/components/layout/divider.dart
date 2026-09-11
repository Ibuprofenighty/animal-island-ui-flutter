import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/theme.dart';
import '../../icons/icon_widget.dart';

/// Style types for [AnimalDivider].
enum AnimalDividerType {
  /// Solid continuous line.
  solid,

  /// Dashed line with rounded pill segments.
  dashed,

  /// Fine dotted line.
  dotted,

  /// Playful sinusoidal wavy line.
  wavy,
}

enum _PresetType { none, leaf, star, flower }

/// Animal Island stylized divider with optional leaf/flower ornament or text.
///
/// If [icon] and [child] are null, renders a continuous line.
/// If [icon] or [child] is provided, renders the ornament/text in the center.
class AnimalDivider extends StatelessWidget {
  final AnimalDividerType type;
  final Color? color;
  final double thickness;
  final Widget? icon;
  final Widget? child;
  final double indent;
  final double endIndent;
  final _PresetType _preset;

  const AnimalDivider({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.icon,
    this.child,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : _preset = _PresetType.none;

  /// Preset for a clean divider line without ornaments.
  const AnimalDivider.plain({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  })  : icon = null,
        child = null,
        _preset = _PresetType.none;

  /// Preset divider featuring a cute center Leaf icon adapting to [AnimalIslandTheme.primary].
  const AnimalDivider.leaf({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  })  : icon = null,
        child = null,
        _preset = _PresetType.leaf;

  /// Preset divider featuring a cute center Star icon.
  const AnimalDivider.star({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  })  : icon = null,
        child = null,
        _preset = _PresetType.star;

  /// Preset divider featuring a cute center Flower icon.
  const AnimalDivider.flower({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  })  : icon = null,
        child = null,
        _preset = _PresetType.flower;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveColor = color ??
        (theme.isDark ? theme.border.withValues(alpha: 0.5) : AnimalColors.borderLight);

    Widget? ornament = icon ?? child;
    if (ornament == null) {
      if (_preset == _PresetType.leaf) {
        ornament = LeafIcon(size: 18, color: theme.primary);
      } else if (_preset == _PresetType.star) {
        ornament = StarIcon(size: 18, color: theme.warning);
      } else if (_preset == _PresetType.flower) {
        ornament = FlowerIcon(size: 18, color: theme.error);
      }
    }

    if (ornament == null) {
      return Semantics(
        container: true,
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: endIndent, top: 12, bottom: 12),
          child: _buildLine(effectiveColor),
        ),
      );
    }

    return Semantics(
      container: true,
      child: Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent, top: 12, bottom: 12),
        child: Row(
          children: [
            Expanded(child: _buildLine(effectiveColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ornament,
            ),
            Expanded(child: _buildLine(effectiveColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(Color lineColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (type == AnimalDividerType.solid) {
          return Container(
            height: thickness,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(thickness),
            ),
          );
        }

        final height = type == AnimalDividerType.wavy ? 10.0 : thickness;

        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _IslandLinePainter(
            color: lineColor,
            thickness: thickness,
            type: type,
          ),
        );
      },
    );
  }
}

class _IslandLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final AnimalDividerType type;

  _IslandLinePainter({
    required this.color,
    required this.thickness,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (type == AnimalDividerType.wavy) {
      final path = Path();
      const waveLength = 14.0;
      final waveHeight = size.height / 2;
      path.moveTo(0, waveHeight);

      for (double x = 0; x < size.width; x += waveLength) {
        final midX = x + waveLength / 2;
        final endX = math.min(x + waveLength, size.width);
        path.quadraticBezierTo(
          midX,
          (x ~/ waveLength).isEven ? 0 : size.height,
          endX,
          waveHeight,
        );
      }
      canvas.drawPath(path, paint);
      return;
    }

    final isDotted = type == AnimalDividerType.dotted;
    final dashWidth = isDotted ? thickness : 6.0;
    final dashSpace = isDotted ? 4.0 : 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(math.min(startX + dashWidth, size.width), size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _IslandLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.thickness != thickness ||
      oldDelegate.type != type;
}


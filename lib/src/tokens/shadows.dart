import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'colors.dart';

/// BoxShadow and depth tokens for Animal Island UI.
///
/// Strictly adheres to the canonical design rules:
/// - 3D stacked shadow is used ONLY on Primary / Danger-Primary buttons and Input (when enabled).
/// - Default buttons and cards use soft elevation shadows.
abstract final class AnimalShadows {
  /// 3D stacked bottom depth shadow for primary buttons (default 5px, 0 blur)
  static const BoxShadow button3d = BoxShadow(
    color: AnimalColors.shadowBtn,
    offset: Offset(0, 5),
    blurRadius: 0,
    spreadRadius: 0,
  );

  /// 3D stacked bottom depth shadow for input when shadow is enabled (3px, 0 blur)
  static const BoxShadow input3d = BoxShadow(
    color: AnimalColors.shadowInput,
    offset: Offset(0, 3),
    blurRadius: 0,
    spreadRadius: 0,
  );

  /// Soft elevation shadow for default/subtle controls
  static const BoxShadow softElevation = BoxShadow(
    color: Color.fromRGBO(61, 52, 40, 0.06),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  /// Floating overlay shadow for tooltips and modals
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color.fromRGBO(61, 52, 40, 0.12),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(61, 52, 40, 0.06),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
}

/// Motion and easing tokens for Animal Island UI.
abstract final class AnimalMotion {
  /// Smooth, playful cubic-bezier curve from design tokens
  static const Curve ease = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Springy bounce curve for modal and popups
  static const Curve spring = Curves.easeOutBack;

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}

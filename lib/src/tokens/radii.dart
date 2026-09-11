import 'package:flutter/painting.dart';

/// Border radius tokens for Animal Island UI.
///
/// Strictly adheres to the canonical design rules:
/// - 12px minimum on any interactive element
/// - 50px pill shape on buttons and inputs
/// - 20px on cards
/// - 16px on tooltips and dialog components
abstract final class AnimalRadii {
  static const double pill = 50.0;
  static const double card = 20.0;
  static const double tooltip = 16.0;
  static const double sm = 12.0;

  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius tooltipBorder = BorderRadius.all(Radius.circular(tooltip));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
}

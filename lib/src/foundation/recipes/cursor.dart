import 'dart:ui';

import '../palette.dart';

/// Software cursor artwork colours.
abstract final class CursorColors {
  static const arrowFill = Primitive.sand978;
  static const arrowStroke = Primitive.brown466;
  static const raindropFill = Primitive.blue810;
  static const raindropStroke = Primitive.blue585;
  static const raindropHighlight = Primitive.blue955;

  /// Text selection highlight inside an arrow cursor scope, by host
  /// brightness. Light keeps the reference #e9c46a (the muted ink #736857
  /// reads 3.27:1 on it, an owner-accepted difference). Dark moves the same
  /// OKLCH hue down only until the dark ink and muted roles reach 4.5:1
  /// (#654c01: ink 7.2:1, muted 4.5:1; 1.5:1 from the dark paper, 1.8:1
  /// from the dark canvas).
  static Color selection(Brightness brightness) =>
      brightness == Brightness.dark ? Primitive.yellow431 : Primitive.yellow834;
}

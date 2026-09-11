import 'package:flutter/painting.dart';

/// Design tokens for the Animal Island UI color system.
///
/// Strictly adheres to the canonical design rules:
/// - Earth-brown text (never pure black `#000`)
/// - Mint-teal primary accent
/// - Warm cream parchment backgrounds (never cold gray `#f5f5f5`)
/// - Warm yellow focus highlights (never cold blue `#0066ff`)
abstract final class AnimalColors {
  // --- Primary Color (Mint Teal) ---
  static const Color primary = Color(0xFF19C8B9);
  static const Color primaryHover = Color(0xFF3DD4C6);
  static const Color primaryActive = Color(0xFF11A89B);
  static const Color primaryBg = Color(0xFFE6F9F6);

  // --- Text (Warm Brown Family) ---
  static const Color text = Color(0xFF794F27); // Primary text (header/sidebar)
  static const Color textBody = Color(0xFF725D42); // Body text inside components
  static const Color textSecondary = Color(0xFF9F927D); // Secondary text
  static const Color textMuted = Color(0xFF8A7B66); // Light brown (modal body)
  static const Color textDisabled = Color(0xFFC4B89E); // Disabled text

  // --- Borders ---
  static const Color border = Color(0xFF9F927D);
  static const Color borderLight = Color(0xFFC4B89E); // Input border
  static const Color borderHover = Color(0xFFA89878); // Input hover border

  // --- Backgrounds (Cream Parchment) ---
  static const Color bg = Color(0xFFF8F8F0); // Main background
  static const Color bgContent = Color(0xFFF7F3DF); // Content area (Card, Modal)
  static const Color bgSecondary = Color(0xFFF0E8D8);
  static const Color bgDisabled = Color(0xFFF0ECE2);
  static const Color bgInput = Color(0xFFFFFBE7); // Input background
  static const Color bgInputDisabled = Color(0xFFECE8DC);

  // --- Status Colors ---
  static const Color success = Color(0xFF6FBA2C);
  static const Color successActive = Color(0xFF5A9E1E);
  static const Color warning = Color(0xFFF5C31C);
  static const Color warningActive = Color(0xFFDBA90E);
  static const Color error = Color(0xFFE05A5A);
  static const Color errorActive = Color(0xFFC94444);

  // --- Focus & Game Highlights ---
  static const Color focusYellow = Color(0xFFFFCC00); // Focus highlight (never blue)


  // --- 3D Shadow Colors ---
  static const Color shadowBtn = Color(0xFFBDAEA0); // Button 3D bottom depth
  static const Color shadowInput = Color(0xFFD4C9B4); // Input 3D bottom depth
  static const Color shadowSwitchOn = Color(0xFF5A9E1E); // Switch ON 3D shadow
}

/// Color specification for Animal Island app tiles (Cards).
enum AnimalTileColor {
  def(Color(0xFFF7F3DF), Color(0xFF725D42)),
  appPink(Color(0xFFF8A6B2), Color(0xFFFFFFFF)),
  purple(Color(0xFFB77DEE), Color(0xFFFFFFFF)),
  appBlue(Color(0xFF889DF0), Color(0xFFFFFFFF)),
  appYellow(Color(0xFFF7CD67), Color(0xFF725D42)),
  appOrange(Color(0xFFE59266), Color(0xFFFFFFFF)),
  appTeal(Color(0xFF82D5BB), Color(0xFFFFFFFF)),
  appGreen(Color(0xFF8AC68A), Color(0xFFFFFFFF)),
  appRed(Color(0xFFFC736D), Color(0xFFFFFFFF)),
  limeGreen(Color(0xFFD1DA49), Color(0xFF3D5A1A)),
  yellowGreen(Color(0xFFECDF52), Color(0xFF725D42)),
  brown(Color(0xFF9A835A), Color(0xFFFFFFFF)),
  warmPeachPink(Color(0xFFE18C6F), Color(0xFFFFFFFF));

  final Color background;
  final Color text;

  const AnimalTileColor(this.background, this.text);
}

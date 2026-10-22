import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One product color system. Brand fills and readable information have distinct
/// roles; light/dark values are explicit, never inferred from opaque children.
@immutable
class IslandTokens extends ThemeExtension<IslandTokens> {
  const IslandTokens({
    required this.canvas,
    required this.paper,
    required this.ink,
    required this.muted,
    required this.leaf,
    required this.onLeaf,
    required this.outline,
    required this.sun,
    required this.danger,
    required this.link,
    required this.linkHover,
    required this.linkPressed,
    required this.focus,
    required this.onCanvas,
    required this.onSun,
    required this.dangerText,
    required this.onDanger,
    required this.dangerHover,
    required this.dangerPressed,
    required this.leafHover,
    required this.leafPressed,
    required this.warning,
    required this.inputSurface,
  });
  final Color canvas;
  final Color paper;
  final Color ink;
  final Color muted;
  final Color leaf;
  final Color onLeaf;
  final Color outline;
  final Color sun;
  final Color danger;
  final Color link;
  final Color linkHover;
  final Color linkPressed;
  final Color focus;
  final Color onCanvas;
  final Color onSun;
  final Color dangerText;
  final Color onDanger;
  final Color dangerHover;
  final Color dangerPressed;
  final Color leafHover;
  final Color leafPressed;
  final Color warning;
  final Color inputSurface;

  static const light = IslandTokens(
    canvas: Color(0xFF88C9A1),
    paper: Color(0xFFF8F8F0),
    ink: Color(0xFF714821),
    muted: Color(0xFF736857),
    leaf: Color(0xFF19C8B9),
    onLeaf: Color(0xFF173A27),
    outline: Color(0xFF8F8474),
    sun: Color(0xFFF5C31C),
    danger: Color(0xFFE05A5A),
    link: Color(0xFF006B62),
    linkHover: Color(0xFF005E56),
    linkPressed: Color(0xFF005249),
    focus: Color(0xFF00564F),
    onCanvas: Color(0xFF573719),
    onSun: Color(0xFF603D1C),
    dangerText: Color(0xFFB03038),
    onDanger: Color(0xFF2A1010),
    dangerHover: Color(0xFFE87878),
    dangerPressed: Color(0xFFD85555),
    leafHover: Color(0xFF3DD4C6),
    leafPressed: Color(0xFF50B9AB),
    warning: Color(0xFF886300),
    inputSurface: Color(0xFFFFFDF7),
  );

  static const dark = IslandTokens(
    canvas: Color(0xFF172B26),
    paper: Color(0xFF243C33),
    ink: Color(0xFFF5F1DC),
    muted: Color(0xFFB7C6B5),
    leaf: Color(0xFFABD2AC),
    onLeaf: Color(0xFF173A27),
    outline: Color(0xFF9BAE98),
    sun: Color(0xFFF5C31C),
    danger: Color(0xFFFFB4A9),
    link: Color(0xFFABD2AC),
    linkHover: Color(0xFFC5E1C6),
    linkPressed: Color(0xFF92C294),
    focus: Color(0xFFC5E1C6),
    onCanvas: Color(0xFFF5F1DC),
    onSun: Color(0xFF603D1C),
    dangerText: Color(0xFFFFB4A9),
    onDanger: Color(0xFF2A1010),
    dangerHover: Color(0xFFFFC5BC),
    dangerPressed: Color(0xFFF29D91),
    leafHover: Color(0xFFC5E1C6),
    leafPressed: Color(0xFF92C294),
    warning: Color(0xFFF5C31C),
    inputSurface: Color(0xFF243C33),
  );

  @override
  IslandTokens copyWith({
    Color? canvas,
    Color? paper,
    Color? ink,
    Color? muted,
    Color? leaf,
    Color? onLeaf,
    Color? outline,
    Color? sun,
    Color? danger,
    Color? link,
    Color? linkHover,
    Color? linkPressed,
    Color? focus,
    Color? onCanvas,
    Color? onSun,
    Color? dangerText,
    Color? onDanger,
    Color? dangerHover,
    Color? dangerPressed,
    Color? leafHover,
    Color? leafPressed,
    Color? warning,
    Color? inputSurface,
  }) => IslandTokens(
    canvas: canvas ?? this.canvas,
    paper: paper ?? this.paper,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    leaf: leaf ?? this.leaf,
    onLeaf: onLeaf ?? this.onLeaf,
    outline: outline ?? this.outline,
    sun: sun ?? this.sun,
    danger: danger ?? this.danger,
    link: link ?? this.link,
    linkHover: linkHover ?? this.linkHover,
    linkPressed: linkPressed ?? this.linkPressed,
    focus: focus ?? this.focus,
    onCanvas: onCanvas ?? this.onCanvas,
    onSun: onSun ?? this.onSun,
    dangerText: dangerText ?? this.dangerText,
    onDanger: onDanger ?? this.onDanger,
    dangerHover: dangerHover ?? this.dangerHover,
    dangerPressed: dangerPressed ?? this.dangerPressed,
    leafHover: leafHover ?? this.leafHover,
    leafPressed: leafPressed ?? this.leafPressed,
    warning: warning ?? this.warning,
    inputSurface: inputSurface ?? this.inputSurface,
  );

  @override
  IslandTokens lerp(covariant IslandTokens? other, double t) {
    if (other == null) return this;
    return t < .5 ? this : other;
  }
}

/// Explicit semantic recipe for controls on a caller-owned surface.
/// Brightness is declared, never inferred from a color or opaque descendant.
@immutable
class IslandSurfaceTheme {
  const IslandSurfaceTheme({required this.brightness, required this.tokens});
  final Brightness brightness;
  final IslandTokens tokens;
}

/// Installs the complete visual theme while retaining Flutter's platform behavior.
abstract final class IslandTheme {
  /// Packaged OFL monospace face for code, independent of host system fonts.
  static const codeFontFamily = 'packages/animal_island_ui/IslandCodeMono';

  /// Resolves a finite logical border width to the reference physical grid.
  /// Nonpositive widths are absent; positive widths occupy at least one
  /// physical pixel. Rebuilds when the nearest MediaQuery DPR changes.
  /// This metric applies to borders, not glyph line boxes or layout spacing.
  static double borderWidth(BuildContext context, double width) {
    assert(width.isFinite, 'Border width must be finite');
    if (width <= 0) return 0;
    final scale = MediaQuery.devicePixelRatioOf(context);
    return math.max(1, (width * scale).floor()) / scale;
  }

  static IslandTokens of(BuildContext context) =>
      Theme.of(context).extension<IslandTokens>() ??
      (Theme.of(context).brightness == Brightness.dark
          ? IslandTokens.dark
          : IslandTokens.light);

  static ThemeData create({
    Brightness brightness = Brightness.light,
    IslandTokens? tokens,
    String? fontFamily,
  }) {
    final t =
        tokens ??
        (brightness == Brightness.dark
            ? IslandTokens.dark
            : IslandTokens.light);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: t.leaf,
          brightness: brightness,
        ).copyWith(
          primary: t.link,
          onPrimary: t.paper,
          surface: t.paper,
          onSurface: t.ink,
          onSurfaceVariant: t.muted,
          outline: t.outline,
          error: t.dangerText,
          onError: t.paper,
          secondaryContainer: t.sun,
          onSecondaryContainer: t.onSun,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: t.outline, width: 1.5),
    );
    return base.copyWith(
      extensions: [t],
      iconTheme: base.iconTheme.copyWith(
        color: brightness == Brightness.dark ? t.ink : const Color(0xff2a2a2a),
      ),
      scaffoldBackgroundColor: t.canvas,
      textTheme: base.textTheme
          .apply(bodyColor: t.ink, displayColor: t.ink)
          .copyWith(
            headlineLarge: base.textTheme.headlineLarge?.copyWith(
              color: t.ink,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
            headlineMedium: base.textTheme.headlineMedium?.copyWith(
              color: t.ink,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: t.ink,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: base.textTheme.bodyLarge?.copyWith(
              color: t.ink,
              height: 1.55,
            ),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: t.ink,
              height: 1.5,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.paper,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: t.focus, width: 2.5),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: t.dangerText, width: 2),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: t.dangerText, width: 2.5),
        ),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
      ),
      dividerTheme: DividerThemeData(
        color: t.outline.withValues(alpha: 0.45),
        space: 32,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(color: t.paper, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.ink,
        contentTextStyle: TextStyle(color: t.paper),
      ),
    );
  }
}

/// An owned readable paper region inside the host's Scaffold/Material body.
/// Pass the resolved target ThemeData, never an upstream interpolated Theme.of.
/// Nested caller-owned painting boundaries and explicit styles remain opaque.
class IslandThemeHost extends StatelessWidget {
  const IslandThemeHost({super.key, required this.data, required this.child});
  final ThemeData data;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final tokens =
        data.extension<IslandTokens>() ??
        (data.brightness == Brightness.dark
            ? IslandTokens.dark
            : IslandTokens.light);
    return Theme(
      data: data,
      child: ColoredBox(
        color: tokens.paper,
        child: DefaultTextStyle(
          style: data.textTheme.bodyMedium!.copyWith(color: tokens.ink),
          child: IconTheme(
            data: data.iconTheme.copyWith(color: tokens.ink),
            child: child,
          ),
        ),
      ),
    );
  }
}

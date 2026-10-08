import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Shadow values owned by one Animal Island theme.
@immutable
class AnimalThemeShadows {
  /// Hard, unblurred depth shadow beneath tactile buttons and tabs.
  final BoxShadow button3d;

  /// Hard, unblurred depth shadow beneath inputs and digit tiles.
  final BoxShadow input3d;

  /// Soft, blurred shadow for slightly raised surfaces.
  final BoxShadow softElevation;

  /// Layered shadows for modals and drawers; unmodifiable.
  final List<BoxShadow> modal;

  /// Creates a shadow configuration.
  ///
  /// The [modal] list is copied into an unmodifiable list.
  AnimalThemeShadows({
    required this.button3d,
    required this.input3d,
    required this.softElevation,
    required List<BoxShadow> modal,
  }) : modal = List<BoxShadow>.unmodifiable(modal);

  /// Default shadows for light palettes.
  static final AnimalThemeShadows light = AnimalThemeShadows(
    button3d: const BoxShadow(
      color: Color(0xFFBDAEA0),
      offset: Offset(0, 5),
      blurRadius: 0,
    ),
    input3d: const BoxShadow(
      color: Color(0xFFD4C9B4),
      offset: Offset(0, 3),
      blurRadius: 0,
    ),
    softElevation: const BoxShadow(
      color: Color.fromRGBO(61, 52, 40, 0.06),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
    modal: const <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(61, 52, 40, 0.12),
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
      BoxShadow(
        color: Color.fromRGBO(61, 52, 40, 0.06),
        offset: Offset(0, 2),
        blurRadius: 6,
      ),
    ],
  );

  /// Default shadows for dark palettes.
  static final AnimalThemeShadows dark = AnimalThemeShadows(
    button3d: const BoxShadow(
      color: Color(0xFF16120E),
      offset: Offset(0, 5),
      blurRadius: 0,
    ),
    input3d: const BoxShadow(
      color: Color(0xFF16120E),
      offset: Offset(0, 3),
      blurRadius: 0,
    ),
    softElevation: const BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.28),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
    modal: const <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.42),
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.22),
        offset: Offset(0, 2),
        blurRadius: 6,
      ),
    ],
  );

  /// Returns a copy of these shadows with the given fields replaced.
  AnimalThemeShadows copyWith({
    BoxShadow? button3d,
    BoxShadow? input3d,
    BoxShadow? softElevation,
    List<BoxShadow>? modal,
  }) => AnimalThemeShadows(
    button3d: button3d ?? this.button3d,
    input3d: input3d ?? this.input3d,
    softElevation: softElevation ?? this.softElevation,
    modal: modal ?? this.modal,
  );

  /// Linearly interpolates between these shadows and [other].
  AnimalThemeShadows lerp(AnimalThemeShadows other, double t) => t == 0
      ? this
      : t == 1
      ? other
      : AnimalThemeShadows(
          button3d: BoxShadow.lerp(button3d, other.button3d, t)!,
          input3d: BoxShadow.lerp(input3d, other.input3d, t)!,
          softElevation: BoxShadow.lerp(softElevation, other.softElevation, t)!,
          modal: BoxShadow.lerpList(modal, other.modal, t)!,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalThemeShadows &&
          button3d == other.button3d &&
          input3d == other.input3d &&
          softElevation == other.softElevation &&
          _sameList(modal, other.modal);

  static bool _sameList(List<BoxShadow> a, List<BoxShadow> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(button3d, input3d, softElevation, Object.hashAll(modal));
}

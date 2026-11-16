import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

import 'palette.dart';

/// Fixed product color pairs. Pastel fills retain the reference; information
/// colors incorporate the approved accessibility differences.
enum IslandColorway {
  neutral('default', 0xffd4c4a8, 0xfff5f0e6, 0xff7e6546, 0xff634f37),
  pink('app-pink', 0xfff8a6b2, 0xfffce4ec, 0xffc2185b, 0xff891140),
  purple('purple', 0xffb77dee, 0xfff3e5f5, 0xff7b1fa2, 0xff4c1364),
  blue('app-blue', 0xff889df0, 0xffe6f0ff, 0xff1565c0, 0xff0c386b),
  yellow('app-yellow', 0xfff7cd67, 0xfffff8e1, 0xff8f6015, 0xff704b11),
  orange('app-orange', 0xffe59266, 0xfffff3e0, 0xffba4100, 0xff632300),
  teal('app-teal', 0xff82d5bb, 0xffe0f2f1, 0xff00695c, 0xff00564b),
  green('app-green', 0xff8ac68a, 0xffe8f5e9, 0xff2e7d32, 0xff1d4c1e),
  red('app-red', 0xfffc736d, 0xffffebee, 0xffc62828, 0xff621313),
  lime('lime-green', 0xffd1da49, 0xfff1f8e9, 0xff487528, 0xff3d5a1a),
  yellowGreen('yellow-green', 0xffecdf52, 0xfff9fbe7, 0xff746a15, 0xff625a11),
  brown('brown', 0xff9a835a, 0xffefebe9, 0xff4e342e, 0xff2a1c19),
  peach('warm-peach-pink', 0xffe18c6f, 0xfffbe9e7, 0xffbf360c, 0xff621c06);

  const IslandColorway(
    this.referenceName,
    this._accent,
    this._soft,
    this._ink,
    this._onAccent,
  );
  final String referenceName;
  final int _accent, _soft, _ink, _onAccent;
  Color get accent => Color(_accent);
  Color get soft => Color(_soft);
  Color get ink => Color(_ink);
  Color get onAccent => Color(_onAccent);
}

// Transparent (outlined/dashed) Tag text on the product paper surfaces, in
// enum order. Each is the reference `.color-<c>-outlined` hue (the accent;
// neutral #8f734f) moved along OKLCH lightness only until it reaches 4.5:1 on
// every light paper (white, paper, input surface, card and pattern papers) or
// the dark paper; reference values that already pass are kept unchanged.
const _outlineInkLight = <int>[
  0xff816541,
  0xff9d5461,
  0xff884ebb,
  0xff5364b2,
  0xff856500,
  0xffa25529,
  0xff1d7761,
  0xff3d763e,
  0xffbe3a3a,
  0xff696e02,
  0xff736b02,
  0xff7c663e,
  0xffa25338,
];
const _outlineInkDark = <int>[
  0xffb89b75,
  0xfff8a6b2,
  0xffc086f8,
  0xff889df0,
  0xfff7cd67,
  0xffe59266,
  0xff82d5bb,
  0xff8ac68a,
  0xfffe756f,
  0xffd1da49,
  0xffecdf52,
  0xffb49d73,
  0xffe18c6f,
];

/// Text color of a transparent Tag for the declared surface [brightness].
Color outlineInk(IslandColorway value, Brightness brightness) => Color(
  (brightness == Brightness.dark
      ? _outlineInkDark
      : _outlineInkLight)[value.index],
);

/// Reference outlined/dashed Tag border: the accent itself (neutral #c4b89e).
/// The text, not this decorative contour, identifies the tag.
Color outlineBorder(IslandColorway value) =>
    value == IslandColorway.neutral ? Primitive.sand786 : value.accent;

// Badge dot fill: the accent moved along OKLCH lightness only until it keeps
// 3:1 against the cream ring and the light/dark papers (brown already does).
const _dotFill = <int>[
  0xff998a70,
  0xffc37682,
  0xffac72e2,
  0xff7488d9,
  0xffae8609,
  0xffc9784d,
  0xff479a82,
  0xff5f9a60,
  0xffe7605c,
  0xff8c9202,
  0xff998e03,
  0xff9a835a,
  0xffc9775a,
];

/// The status-dot graphic for [value]; a necessary graphic at 3:1.
Color dotFill(IslandColorway value) => Color(_dotFill[value.index]);

// Shared paper colors used by Card patterns and Image frames.
(Color, Color, Color) paperPalette(IslandColorway value) => switch (value) {
  IslandColorway.neutral => (
    const Color(0xfff7f3df),
    const Color(0xff725d42),
    const Color(0xffc4b89e),
  ),
  IslandColorway.pink => (
    const Color(0xfffde4e8),
    const Color(0xff8b4654),
    const Color(0xffffc8d2),
  ),
  IslandColorway.purple => (
    const Color(0xfff0e8ff),
    const Color(0xff6a3a9a),
    const Color(0xffdcb4ff),
  ),
  IslandColorway.blue => (
    const Color(0xffe8edff),
    const Color(0xff4a5a8a),
    const Color(0xffb4c3ff),
  ),
  IslandColorway.yellow => (
    const Color(0xfffff8e0),
    const Color(0xff705d25),
    const Color(0xffffe6a0),
  ),
  IslandColorway.orange => (
    const Color(0xfffff0e8),
    const Color(0xff8a4a2a),
    const Color(0xffffbe96),
  ),
  IslandColorway.teal => (
    const Color(0xffe8faf5),
    const Color(0xff2a6b5a),
    const Color(0xffaaebd2),
  ),
  IslandColorway.green => (
    const Color(0xffe8f5e8),
    const Color(0xff3a6b3a),
    const Color(0xffb4dcb4),
  ),
  IslandColorway.red => (
    const Color(0xffffe8e8),
    const Color(0xff9a3a3a),
    const Color(0xffffa09b),
  ),
  IslandColorway.lime => (
    const Color(0xfff5f8e0),
    const Color(0xff536225),
    const Color(0xffe6f082),
  ),
  IslandColorway.yellowGreen => (
    const Color(0xfffffde8),
    const Color(0xff6a5a28),
    const Color(0xfffff58c),
  ),
  IslandColorway.brown => (
    const Color(0xfff5f0e0),
    const Color(0xff5a4a2a),
    const Color(0xffbea578),
  ),
  IslandColorway.peach => (
    const Color(0xfffff0e8),
    const Color(0xff8a4a2a),
    const Color(0xffffb9a0),
  ),
};

// Title fronts, backs, folds and their readable default foreground.
const titlePalette = <(Color, Color, Color, Color)>[
  (Color(0xff27d039), Color(0xff20992a), Color(0xff115017), Color(0xff115017)),
  (Color(0xfff8a6b2), Color(0xffe06880), Color(0xffa03060), Color(0xff7c254b)),
  (Color(0xffb77dee), Color(0xff9050d0), Color(0xff5a1a9a), Color(0xff431373)),
  (Color(0xff889df0), Color(0xff5068d8), Color(0xff2030a0), Color(0xff1d2b90)),
  (Color(0xfff7cd67), Color(0xffd4a030), Color(0xff8a6010), Color(0xff625039)),
  (Color(0xffe59266), Color(0xffc06a30), Color(0xff7a3a10), Color(0xff5a2a0c)),
  (Color(0xff82d5bb), Color(0xff40a880), Color(0xff186048), Color(0xff155640)),
  (Color(0xff8ac68a), Color(0xff509050), Color(0xff205020), Color(0xff205020)),
  (Color(0xfffc736d), Color(0xffd43030), Color(0xff900010), Color(0xff6a000c)),
  (Color(0xffd1da49), Color(0xff90a010), Color(0xff485800), Color(0xff3d5a1a)),
  (Color(0xffecdf52), Color(0xffc0b010), Color(0xff706800), Color(0xff69563d)),
  (Color(0xff9a835a), Color(0xff705830), Color(0xff3a2810), Color(0xff2a1d0c)),
  (Color(0xffe18c6f), Color(0xffb85a30), Color(0xff6a2a10), Color(0xff5a240e)),
];

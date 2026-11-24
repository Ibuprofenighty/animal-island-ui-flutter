import '../palette.dart';

/// Upload colour recipe (fixed light surfaces over arbitrary thumbnails).
abstract final class UploadColors {
  static const previewBarrier = Primitive.neutral157A82;

  /// Drop zone, list rows, cards and the action discs share one paper and
  /// one hover/active tint. Card drop zones fade from a transparent tint.
  static const surface = Primitive.neutral994;
  static const hoverFill = Primitive.teal967;
  static const cardZoneRest = Primitive.teal967A0;
  static const border = Primitive.sand899;
  static const errorRowFill = Primitive.red961;
  static const fileName = Primitive.brown466;

  /// Status backing over a card thumbnail: the reference rgba(15,12,8,.55)
  /// at the least alpha (.565) that keeps white text 4.5:1 over any pixel.
  static const cardOverlay = Primitive.neutral157A56;

  /// Reference white bar-mode card percentage on [cardOverlay].
  static const cardPercent = Primitive.neutral1000;

  // Raised upload button.
  static const button = Primitive.neutral977;
  static const buttonLabel = Primitive.brown466;
  static const buttonDepth = Primitive.brown760;
  static const buttonDepthDisabled = Primitive.brown839;

  static const progressTrack = Primitive.teal967;

  /// Background progress: the default fill (painted at .28 opacity), its
  /// wave, the percent label, and the pale card mask that replaces the dark
  /// overlay.
  static const backgroundFill = Primitive.teal750;
  static const backgroundWave = Primitive.neutral1000;
  static const backgroundPercent = Primitive.brown466;
  static const backgroundCardMask = Primitive.neutral994A88;

  /// Row file size over the background fill: the muted size ink (4.1–4.3:1
  /// on the .28 fill) deepened in hue to 4.5:1.
  static const backgroundSizeText = Primitive.sand501;

  /// Same-hue 2px end edge of the default background fill when it is the
  /// only progress cue (no percentage): the fill is 1.2:1 against the
  /// unfilled surface; the edge is 3:1 on the row, its hover tint and the
  /// card mask over any thumbnail pixel.
  static const backgroundFillEdge = Primitive.teal581;

  /// Row preview/remove buttons: transparent at rest; hover adds the
  /// reference rgba(0,0,0,.08) and tints the icon. The reference teal
  /// #19c8b9 and red #e05a5a icons (1.3-3.0:1 over the hovered row, the
  /// error row and the background fill) deepen in their own hue to 3:1.
  static const actionHover = Primitive.neutral0A8;
  static const previewHoverIcon = Primitive.teal533;
  static const removeHoverIcon = Primitive.red567;

  /// Picture-card overlay buttons: the reference preview disc
  /// rgba(0,0,0,.45) (.65 on hover) under a white icon, 3.4:1 or more over
  /// any thumbnail pixel. The reference remove icon is white on a
  /// transparent ground (1:1 over a white pixel), so it takes the same disc.
  static const cardAction = Primitive.neutral0A45;
  static const cardActionHover = Primitive.neutral0A65;
  static const cardActionIcon = Primitive.neutral1000;

  /// Failed card mark: reference CloseIcon 22 in #e05a5a (3.6:1 on the
  /// status backing).
  static const cardErrorIcon = Primitive.red641;

  /// Finished card border (reference `.cardDone` #c4b89e, decorative like
  /// the rest [border]).
  static const doneBorder = Primitive.sand786;
}

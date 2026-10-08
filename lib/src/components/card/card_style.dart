/// Card style types matching animal-island-ui.
enum AnimalCardType {
  /// Solid 1.5 logical-pixel border.
  defaultCard,

  /// Dashed border painted over the card.
  dashed,
}

/// Organic background pattern types for [AnimalCard].
enum AnimalCardPattern {
  /// No pattern.
  none,

  /// Staggered dots on a 20 logical-pixel step.
  dots,

  /// Short rotated strokes on a 28 logical-pixel step.
  sprinkles,

  /// Diagonal stripes on a 24 logical-pixel step.
  stripes,
}

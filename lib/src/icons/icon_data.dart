import 'package:flutter/foundation.dart';

/// Immutable descriptor for an Animal Island vector icon.
///
/// An [AnimalIconData] contains the canonical name, the raw SVG XML string,
/// and an optional default accessibility label.
@immutable
class AnimalIconData {
  /// Canonical identifier of the icon (e.g. 'leaf', 'apple').
  final String name;

  /// Raw SVG XML markup.
  final String svg;

  /// Optional accessibility label for screen readers.
  final String? semanticLabel;

  /// Creates an immutable canonical icon descriptor.
  const AnimalIconData({
    required this.name,
    required this.svg,
    this.semanticLabel,
  });

  /// Creates a custom icon descriptor from raw SVG markup.
  const AnimalIconData.svg(
    this.svg, {
    this.name = 'custom',
    this.semanticLabel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalIconData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          svg == other.svg &&
          semanticLabel == other.semanticLabel;

  @override
  int get hashCode => Object.hash(name, svg, semanticLabel);

  @override
  String toString() => 'AnimalIconData(name: $name, label: $semanticLabel)';
}

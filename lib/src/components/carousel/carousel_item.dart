import 'package:flutter/widgets.dart';

/// A slide with stable identity independent of its position or content.
@immutable
final class AnimalCarouselItem {
  /// Nonempty identity, unique within one carousel.
  final String id;

  /// Caller-owned slide content, retained by identity when reordered.
  final Widget child;

  /// Creates a slide; an empty ID throws ArgumentError.
  AnimalCarouselItem({required this.id, required this.child}) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must be nonempty');
  }
}

import 'package:animal_island_ui/animal_island_ui.dart';

import 'gallery_cartesian.dart';
import 'gallery_polar.dart';
import 'gallery_specialty.dart';
import 'spec.dart';

/// Reference `ChartGalleryExample`: one titled style example whose single
/// configuration is both drawn and shown as copyable code.
class ChartExample {
  ChartExample(this.id, this.title, this.description, ChartSpec spec)
    : spec = spec.height == null ? spec.copyWith(height: 240) : spec;

  /// Stable within its type.
  final String id;
  final String title, description;
  final ChartSpec spec;

  IslandChart chart() => spec.chart(title: title, description: description);

  String get code => spec.code(title: title, description: description);
}

/// Every type has its own four examples; the map is checked against
/// [IslandChartType.values] by the story test.
final chartExamples = <IslandChartType, List<ChartExample>>{
  ...cartesianExamples,
  ...polarExamples,
  ...specialtyExamples,
};

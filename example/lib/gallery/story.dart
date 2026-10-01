import 'package:flutter/material.dart';

/// Interactive showcase definition for an Animal Island UI component or feature.
class StoryDefinition {
  /// Unique URL slug and route segment, e.g. 'button'.
  final String slug;

  /// Human-readable title, e.g. 'Button 按钮'.
  final String name;

  /// The primary capability ID mapped in catalog/components.yaml (C01–C36, or C101).
  final String capabilityId;

  /// List of MUST scenario codes demonstrated by this story (e.g. ['BTN01', 'BTN02']).
  final List<String> scenarioIds;

  /// Functional category for sidebar navigation.
  final String category;

  /// Builder that instantiates the story widget tree.
  final WidgetBuilder builder;

  /// Brief description of the component functionality and tactile characteristics.
  final String description;

  const StoryDefinition({
    required this.slug,
    required this.name,
    required this.capabilityId,
    required this.scenarioIds,
    required this.category,
    required this.builder,
    required this.description,
  });
}

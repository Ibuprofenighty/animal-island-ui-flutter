import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TagStory extends StatelessWidget {
  const TagStory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimalTitle(
            size: AnimalTitleSize.large,
            child: const Text('Tag (C34)'),
          ),
          const SizedBox(height: 8),
          Text(
            '13 island pastel colors with decoupled close hit target and accessible semantics',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Tag Palette Showcase',
            capabilityIds: const ['C34-TAG', 'TAG01'],
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AnimalTag(
                  color: AnimalTileColor.appTeal,
                  child: const Text('Teal'),
                ),
                AnimalTag(
                  color: AnimalTileColor.appOrange,
                  child: const Text('Orange'),
                ),
                AnimalTag(
                  color: AnimalTileColor.appBlue,
                  child: const Text('Blue'),
                ),
                AnimalTag(
                  color: AnimalTileColor.purple,
                  child: const Text('Purple'),
                ),
                AnimalTag(
                  color: AnimalTileColor.warmPeachPink,
                  child: const Text('Peach'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

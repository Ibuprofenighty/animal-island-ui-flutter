import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class FooterStory extends StatelessWidget {
  const FooterStory({super.key});

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
            child: const Text('Footer (C36)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Island shoreline wave or forest tree silhouette footer with localized default copy',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Shoreline Wave Silhouette',
            capabilityIds: const ['C36-FOT'],
            child: const AnimalFooter(type: AnimalFooterType.sea),
          ),
          const SizedBox(height: 16),
          StoryCard(
            title: 'Forest Tree Silhouette',
            capabilityIds: const ['C36-FOT'],
            child: const AnimalFooter(type: AnimalFooterType.tree),
          ),
        ],
      ),
    );
  }
}

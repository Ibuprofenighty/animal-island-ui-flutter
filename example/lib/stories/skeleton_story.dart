import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class SkeletonStory extends StatelessWidget {
  const SkeletonStory({super.key});

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
            child: const Text('Skeleton (C26)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Warm shimmer placeholder loader with ticker suspension when inactive',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Placeholder Shimmer',
            capabilityIds: const ['C26-SKL', 'SKL01'],
            child: AnimalSkeleton.paragraph(rows: 3),
          ),
        ],
      ),
    );
  }
}

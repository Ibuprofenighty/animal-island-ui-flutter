import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class ProgressStory extends StatelessWidget {
  const ProgressStory({super.key});

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
            child: const Text('Progress (C24)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Signature 45° candy-cane striped progress bars and circular gauge meters',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Progress Indicators',
            capabilityIds: const ['C24-PRO', 'PRO01'],
            child: Column(
              children: const [
                AnimalProgress(percent: 0.65),
                SizedBox(height: 16),
                AnimalProgress.circle(percent: 0.82),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

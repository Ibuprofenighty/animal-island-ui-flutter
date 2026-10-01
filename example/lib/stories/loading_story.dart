import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class LoadingStory extends StatelessWidget {
  const LoadingStory({super.key});

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
            child: const Text('Loading (C25)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Whimsical island leaf spinners, falling snowflakes, and bounce dots with scoped handles (F14 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Loading Indicators',
            capabilityIds: const ['C25-LOD', 'LOD01', 'F14'],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                AnimalLoading(type: AnimalLoadingType.spinner, tip: 'Spinning'),
                AnimalLoading(type: AnimalLoadingType.dots, tip: 'Bouncing'),
                AnimalLoading(
                  type: AnimalLoadingType.snowflake,
                  tip: 'Snowing',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CountdownStory extends StatelessWidget {
  const CountdownStory({super.key});

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
            child: const Text('Countdown (C28)'),
          ),
          const SizedBox(height: 8),
          Text(
            '900-weight digit tile countdown with single scheduling engine and exactly-once onFinish (F15 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Island Event Timer (F15 Tested)',
            capabilityIds: const ['C28-CDN', 'CDN01', 'F15'],
            child: AnimalCountdown.duration(
              duration: const Duration(hours: 12, minutes: 45, seconds: 30),
              size: AnimalCountdownSize.middle,
              onFinish: () {},
            ),
          ),
        ],
      ),
    );
  }
}

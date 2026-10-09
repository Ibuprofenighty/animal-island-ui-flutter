import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TimeStory extends StatelessWidget {
  const TimeStory({super.key});

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
            child: const Text('Time (C29)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Live clock card with screen-reader chatter suppression (F16 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Live Island Clock (F16 Tested)',
            capabilityIds: const ['C29-TIM', 'CLK01', 'F16'],
            child: const AnimalTime.live(),
          ),
        ],
      ),
    );
  }
}

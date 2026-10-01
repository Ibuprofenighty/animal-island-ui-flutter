import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class BackTopStory extends StatelessWidget {
  const BackTopStory({super.key});

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
            child: const Text('BackTop (C27)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Floating button with signature rocket blast-off animation and immediate visibility reactivity',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Rocket Back to Top',
            capabilityIds: const ['C27-BTP', 'BTP01'],
            child: const Text(
              'Scroll this page to see the floating rocket button blast off!',
            ),
          ),
        ],
      ),
    );
  }
}

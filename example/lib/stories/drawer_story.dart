import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class DrawerStory extends StatelessWidget {
  const DrawerStory({super.key});

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
            child: const Text('Drawer (C22)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Slide-out drawer sheet supporting 4 directions with safe-area clamping and focus trapping',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Drawer Sheet Trigger',
            capabilityIds: const ['C22-DRW', 'DRW01'],
            child: AnimalButton(
              onPressed: () {
                AnimalDrawer.show(
                  context: context,
                  title: const Text('Settings Drawer'),
                  child: const Text('Drawer configuration panel content.'),
                );
              },
              child: const Text('Open Right Drawer'),
            ),
          ),
        ],
      ),
    );
  }
}

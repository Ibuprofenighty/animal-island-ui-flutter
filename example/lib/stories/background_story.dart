import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class BackgroundStory extends StatelessWidget {
  const BackgroundStory({super.key});

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
            child: const Text('Background (C08)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Animal Island wallpaper container background with dots, grid, and parchment textures',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Wallpaper Textures',
            capabilityIds: const ['C08-BG'],
            child: SizedBox(
              height: 120,
              child: AnimalBackground(
                type: AnimalBackgroundType.dots,
                child: Center(
                  child: Text(
                    'Dots Texture Canvas',
                    style: theme.typography.heading,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CardStory extends StatelessWidget {
  const CardStory({super.key});

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
            child: const Text('Card (C05)'),
          ),
          const SizedBox(height: 8),
          Text(
            '20px rounded cards with optional organic background textures (dots, sprinkles, stripes) and hover lift',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Card Patterns & Styles',
            capabilityIds: const ['C05-CARD', 'CARD01', 'CARD02'],
            child: Column(
              children: [
                AnimalCard(
                  pattern: AnimalCardPattern.dots,
                  hoverable: true,
                  child: Text(
                    'Card with Dot Pattern & Hover Lift',
                    style: theme.typography.body,
                  ),
                ),
                const SizedBox(height: 16),
                AnimalCard(
                  pattern: AnimalCardPattern.sprinkles,
                  color: AnimalTileColor.appTeal,
                  child: Text(
                    'Card with Sprinkles Pattern & Island Mint Palette',
                    style: theme.typography.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

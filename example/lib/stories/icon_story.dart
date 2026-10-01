import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class IconStory extends StatelessWidget {
  const IconStory({super.key});

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
            child: const Text('Icon (C02)'),
          ),
          const SizedBox(height: 8),
          Text(
            '101 native island vector icons with multi-fill color paths and alpha stroke retention',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Icon Display & Sizing',
            capabilityIds: const ['C02-ICO', 'ICO01', 'ICO02'],
            codeSnippet: "AnimalIcon(data: AnimalIcons.leaf, size: 32)",
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                AnimalIcon(data: AnimalIcons.leaf, size: 20),
                AnimalIcon(data: AnimalIcons.apple, size: 28),
                AnimalIcon(data: AnimalIcons.bear, size: 36),
                AnimalIcon(data: AnimalIcons.compass, size: 44),
                AnimalIcon(data: AnimalIcons.sun, size: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

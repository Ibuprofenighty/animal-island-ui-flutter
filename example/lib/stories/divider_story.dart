import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class DividerStory extends StatelessWidget {
  const DividerStory({super.key});

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
            child: const Text('Divider (C07)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Cozy dividing rules with plain, wavy, dashed styles and island icon center ornaments',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Divider Styles',
            capabilityIds: const ['C07-DIV'],
            child: Column(
              children: const [
                AnimalDivider(type: AnimalDividerType.solid),
                SizedBox(height: 24),
                AnimalDivider(type: AnimalDividerType.dashed),
                SizedBox(height: 24),
                AnimalDivider(type: AnimalDividerType.wavy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

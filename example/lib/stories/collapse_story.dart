import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CollapseStory extends StatelessWidget {
  const CollapseStory({super.key});

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
            child: const Text('Collapse (C09)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Accordion and multi-expansion collapse with stable item IDs and keyboard navigation (F27 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Island FAQ Accordion',
            capabilityIds: const ['C09-COL', 'COL01', 'F27'],
            child: AnimalCollapse(
              accordion: true,
              defaultActiveIds: const {'item1'},
              items: [
                AnimalCollapseItem(
                  id: 'item1',
                  title: const Text('How do I catch rare fish?'),
                  content: const Text(
                    'Craft high-quality fishing bait from clams collected along the beach during morning high tides.',
                  ),
                ),
                AnimalCollapseItem(
                  id: 'item2',
                  title: const Text('When do shooting stars appear?'),
                  content: const Text(
                    'Look up into the clear night sky on cloudless evenings after 7:00 PM when Celeste visits the observatory.',
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

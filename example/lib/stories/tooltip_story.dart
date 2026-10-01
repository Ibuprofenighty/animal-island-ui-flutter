import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TooltipStory extends StatelessWidget {
  const TooltipStory({super.key});

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
            child: const Text('Tooltip (C23)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Disjunctive message payload tooltip eliminating assertion crash bugs (F04 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Hover / Tap Tooltips',
            capabilityIds: const ['C23-TIP', 'TIP01', 'F04'],
            child: AnimalTooltip(
              message: 'Cute animal tooltip notice!',
              child: AnimalButton(
                variant: AnimalButtonVariant.outlined,
                onPressed: () {},
                child: const Text('Hover for Tooltip'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

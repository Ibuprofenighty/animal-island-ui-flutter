import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CursorStory extends StatelessWidget {
  const CursorStory({super.key});

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
            child: const Text('Cursor (C04)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Desktop mouse hover cursor overlay with device-aware hit testing and zero leak on unmount',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Cursor Interaction Zones',
            capabilityIds: const ['C04-CUR', 'CUR01'],
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                AnimalCursor(
                  type: AnimalCursorType.defaultCursor,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colors.bgContent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colors.border),
                    ),
                    child: const Text('Paw Cursor Zone 🐾'),
                  ),
                ),
                AnimalCursor(
                  type: AnimalCursorType.raindrop,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colors.bgContent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colors.border),
                    ),
                    child: const Text('Raindrop Cursor Zone 💧'),
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

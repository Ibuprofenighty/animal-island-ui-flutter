import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class ModalStory extends StatelessWidget {
  const ModalStory({super.key});

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
            child: const Text('Modal (C21)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Type-safe dialog modals with organic blob border and dialogue typewriter support (F23 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Modal Triggers',
            capabilityIds: const ['C21-MOD', 'MOD01', 'F23'],
            child: AnimalButton(
              onPressed: () {
                AnimalModal.show(
                  context: context,
                  title: const Text('Island Bulletin'),
                  content: const Text(
                    'Special visitor K.K. Slider is performing at the plaza!',
                  ),
                  okText: 'Understood',
                );
              },
              child: const Text('Open Modal Dialog'),
            ),
          ),
        ],
      ),
    );
  }
}

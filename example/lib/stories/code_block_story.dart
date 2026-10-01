import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CodeBlockStory extends StatelessWidget {
  const CodeBlockStory({super.key});

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
            child: const Text('CodeBlock (C33)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Monospace syntax block with async clipboard copy and debounce state protection (F25 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Copyable Dart CodeBlock (F25 Tested)',
            capabilityIds: const ['C33-COD', 'COD01', 'F25'],
            child: const AnimalCodeBlock(
              code: "final theme = AnimalIslandTheme.of(context);\nprint('Island Primary: \${theme.colors.primary}');",
              language: 'dart',
            ),
          ),
        ],
      ),
    );
  }
}

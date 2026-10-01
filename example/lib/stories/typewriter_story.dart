import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TypewriterStory extends StatefulWidget {
  const TypewriterStory({super.key});

  @override
  State<TypewriterStory> createState() => _TypewriterStoryState();
}

class _TypewriterStoryState extends State<TypewriterStory> {
  int _cycle = 0;
  bool _completed = false;

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
            child: const Text('Typewriter (C03)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Linear O(N) grapheme cluster typewriter text animation with zero-jitter layout reservation',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Dialogue Typewriter Simulation (F09 Root Fix)',
            capabilityIds: const ['C03-TYP', 'TYP01', 'TYP02', 'F09'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colors.bgContent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: AnimalTypewriter(
                    key: ValueKey(_cycle),
                    text: 'Hello island adventurer! Today is a sunny day on Animal Island. Let us fish and craft tools! 🍎🌟',
                    speed: const Duration(milliseconds: 30),
                    showCursor: true,
                    style: theme.typography.heading.copyWith(
                      color: theme.colors.text,
                    ),
                    onComplete: () => setState(() => _completed = true),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AnimalButton(
                      variant: AnimalButtonVariant.filled,
                      onPressed: () => setState(() {
                        _cycle++;
                        _completed = false;
                      }),
                      child: const Text('Restart Typing'),
                    ),
                    const SizedBox(width: 12),
                    if (_completed)
                      AnimalTag(
                        color: AnimalTileColor.appTeal,
                        child: const Text('Typing Finished!'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

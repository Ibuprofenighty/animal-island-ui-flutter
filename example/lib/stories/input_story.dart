import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class InputStory extends StatefulWidget {
  const InputStory({super.key});

  @override
  State<InputStory> createState() => _InputStoryState();
}

class _InputStoryState extends State<InputStory> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            child: const Text('Input (C12)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Cozy pill input with prefix/suffix icons, keyboard-activated clear button and composition protection',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Interactive Input Controls',
            capabilityIds: const ['C12-INP', 'INP01'],
            child: Column(
              children: [
                AnimalInput(
                  controller: _controller,
                  placeholder: 'Type island notes...',
                  prefix: const AnimalIcon(data: AnimalIcons.edit, size: 18),
                  clearable: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current input value: "${_controller.text}"',
                  style: theme.typography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

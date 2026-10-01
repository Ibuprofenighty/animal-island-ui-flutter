import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class RadioStory extends StatefulWidget {
  const RadioStory({super.key});

  @override
  State<RadioStory> createState() => _RadioStoryState();
}

class _RadioStoryState extends State<RadioStory> {
  String _selected = 'sunny';

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
            child: const Text('Radio (C15)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Classic upstream rounded square with checkmark icon visual (F28 Root Fix) and mutual exclusion',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Weather Preference Selection',
            capabilityIds: const ['C15-RAD', 'RAD01', 'F28'],
            child: AnimalRadioGroup<String>(
              value: _selected,
              options: const [
                AnimalOption(label: 'Bright & Sunny', value: 'sunny'),
                AnimalOption(label: 'Gentle Rain', value: 'rainy'),
                AnimalOption(label: 'Starry Twilight', value: 'night'),
              ],
              onChanged: (v) => setState(() => _selected = v),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CheckboxStory extends StatefulWidget {
  const CheckboxStory({super.key});

  @override
  State<CheckboxStory> createState() => _CheckboxStoryState();
}

class _CheckboxStoryState extends State<CheckboxStory> {
  List<String> _selected = ['apple'];

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
            child: const Text('Checkbox (C14)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Pill checkboxes and group selection with independent focus nodes and no scope pollution',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Island Fruit Harvest (Checkbox Group)',
            capabilityIds: const ['C14-CHK', 'CHK01'],
            child: AnimalCheckboxGroup<String>(
              value: _selected,
              options: const [
                AnimalOption(label: 'Sweet Apples', value: 'apple'),
                AnimalOption(label: 'Wild Cherries', value: 'cherry'),
                AnimalOption(label: 'Juicy Pears', value: 'pear'),
              ],
              onChanged: (vals) => setState(() => _selected = vals),
            ),
          ),
        ],
      ),
    );
  }
}

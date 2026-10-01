import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class SelectStory extends StatefulWidget {
  const SelectStory({super.key});

  @override
  State<SelectStory> createState() => _SelectStoryState();
}

class _SelectStoryState extends State<SelectStory> {
  String? _selectedVillager = 'tom_nook';

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
            child: const Text('Select (C16)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Pill dropdown selector with keyboard navigation, search filtering and focus restoration',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Villager Selection Dropdown',
            capabilityIds: const ['C16-SEL', 'SEL01'],
            child: AnimalSelect<String>(
              value: _selectedVillager,
              placeholder: 'Select a resident...',
              options: const [
                AnimalOption(label: 'Tom Nook (Storeowner)', value: 'tom_nook'),
                AnimalOption(label: 'Isabelle (Secretary)', value: 'isabelle'),
                AnimalOption(label: 'Blathers (Curator)', value: 'blathers'),
              ],
              onChanged: (val) => setState(() => _selectedVillager = val),
            ),
          ),
        ],
      ),
    );
  }
}

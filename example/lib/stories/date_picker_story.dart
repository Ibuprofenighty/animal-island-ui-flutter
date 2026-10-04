import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class DatePickerStory extends StatefulWidget {
  const DatePickerStory({super.key});

  @override
  State<DatePickerStory> createState() => _DatePickerStoryState();
}

class _DatePickerStoryState extends State<DatePickerStory> {
  AnimalDateSelection? _selection =
      AnimalDateSelection.date(AnimalDate(2026, 9, 13));

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
            child: const Text('DatePicker (C17)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Immutable AnimalDate calendar panel with popover sheet and inline mode',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Popover Date Selection',
            capabilityIds: const ['C17-DAT', 'DAT01'],
            child: AnimalDatePicker.popover(
              selection: _selection,
              onChanged: (selection) =>
                  setState(() => _selection = selection),
            ),
          ),
        ],
      ),
    );
  }
}

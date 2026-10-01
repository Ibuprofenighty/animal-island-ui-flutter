import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TimePickerStory extends StatefulWidget {
  const TimePickerStory({super.key});

  @override
  State<TimePickerStory> createState() => _TimePickerStoryState();
}

class _TimePickerStoryState extends State<TimePickerStory> {
  AnimalTimeValue? _selectedTime = AnimalTimeValue(
    hour: 10,
    minute: 30,
    second: 0,
  );

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
            child: const Text('TimePicker (C18)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Three-wheel hour/minute/second picker with atomic second preservation (F11 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Atomic Time Selector (F11 Tested)',
            capabilityIds: const ['C18-TIM', 'TIM01', 'F11'],
            child: AnimalTimePicker(
              value: _selectedTime,
              onChanged: (t) => setState(() => _selectedTime = t),
            ),
          ),
        ],
      ),
    );
  }
}

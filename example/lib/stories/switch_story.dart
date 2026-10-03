import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class SwitchStory extends StatefulWidget {
  const SwitchStory({super.key});

  @override
  State<SwitchStory> createState() => _SwitchStoryState();
}

class _SwitchStoryState extends State<SwitchStory> {
  bool _enabled = true;

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
            child: const Text('Switch (C13)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Physical micro-motion spring toggle switch with inset track and keyboard accessibility',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Interactive Spring Toggle',
            capabilityIds: const ['C13-SW', 'SW01'],
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AnimalSwitchSize.defaultSize.width,
                  ),
                  child: AnimalSwitch(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _enabled ? 'Switch is ACTIVE' : 'Switch is INACTIVE',
                  style: theme.typography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

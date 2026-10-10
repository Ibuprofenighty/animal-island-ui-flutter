import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TabsStory extends StatefulWidget {
  const TabsStory({super.key});

  @override
  State<TabsStory> createState() => _TabsStoryState();
}

class _TabsStoryState extends State<TabsStory> {
  String _selectedTab = 'tab-0';

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
            child: const Text('Tabs (C10)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Layout-driven animated pill tab bar with roving keyboard focus and resize recalculation (F26 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Interactive Pill Tabs',
            capabilityIds: const ['C10-TAB', 'TAB01', 'F26'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimalTabs(
                  selectedId: _selectedTab,
                  onChanged: (idx) => setState(() => _selectedTab = idx),
                  tabs: [
                    AnimalTabItem(
                      id: 'tab-0',
                      label: 'Town Hall',
                      icon: AnimalIcon(data: AnimalIcons.home, size: 16),
                    ),
                    AnimalTabItem(
                      id: 'tab-1',
                      label: 'Museum',
                      icon: AnimalIcon(data: AnimalIcons.trophy, size: 16),
                    ),
                    AnimalTabItem(
                      id: 'tab-2',
                      label: 'Able Sisters',
                      icon: AnimalIcon(data: AnimalIcons.tag, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colors.bgContent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: Text(
                    'Displaying panel for tab ID $_selectedTab',
                    style: theme.typography.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

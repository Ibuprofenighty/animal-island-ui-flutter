import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TableStory extends StatelessWidget {
  const TableStory({super.key});

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
            child: const Text('Table (C31)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Virtualized lazy rowBuilder table supporting fixed & flex columns and sticky header (F10 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Lazy Virtualized Table (F10 Tested)',
            capabilityIds: const ['C31-TBL', 'TBL01', 'F10'],
            child: SizedBox(
              height: 200,
              child: AnimalTable(
                columns: const [
                  AnimalTableColumn(title: 'Index', width: 80),
                  AnimalTableColumn(title: 'Item Name', flex: 2),
                  AnimalTableColumn(title: 'Price', width: 100),
                ],
                rowCount: 100,
                rowBuilder: (ctx, idx) => [
                  Text('#${idx + 1}'),
                  Text('Island Collectible #${idx + 1}'),
                  const Text('500 🔔'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

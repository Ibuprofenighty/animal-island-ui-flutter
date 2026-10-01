import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class PaginationStory extends StatefulWidget {
  const PaginationStory({super.key});

  @override
  State<PaginationStory> createState() => _PaginationStoryState();
}

class _PaginationStoryState extends State<PaginationStory> {
  int _page = 1;

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
            child: const Text('Pagination (C32)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Integer-safe pagination with adaptive compact mode and jump ellipsis (F24 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Adaptive Pagination (F24 Tested)',
            capabilityIds: const ['C32-PAG', 'PAG01', 'F24'],
            child: AnimalPagination(
              current: _page,
              total: 500,
              pageSize: 10,
              onChanged: (p) => setState(() => _page = p),
            ),
          ),
        ],
      ),
    );
  }
}

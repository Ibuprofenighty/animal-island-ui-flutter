import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class TitleStory extends StatelessWidget {
  const TitleStory({super.key});

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
            child: const Text('Title Ribbon (C06)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Swallowtail notched ribbon banner with 3D folded corner triangle shadows and screen-reader heading semantics',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Ribbon Sizes & Island Themes',
            capabilityIds: const ['C06-TIT', 'TIT01'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimalTitle(
                  size: AnimalTitleSize.large,
                  color: AnimalTileColor.appOrange,
                  child: const Text('Large Citrus Ribbon'),
                ),
                const SizedBox(height: 20),
                AnimalTitle(
                  size: AnimalTitleSize.middle,
                  color: AnimalTileColor.appTeal,
                  child: const Text('Middle Mint Ribbon'),
                ),
                const SizedBox(height: 20),
                AnimalTitle(
                  size: AnimalTitleSize.small,
                  color: AnimalTileColor.appBlue,
                  child: const Text('Small Sky Ribbon'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

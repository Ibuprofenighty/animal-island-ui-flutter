import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class CarouselStory extends StatelessWidget {
  const CarouselStory({super.key});

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
            child: const Text('Carousel (C11)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipeable carousel slider with hover pause, keyboard accessible dot indicators and loop mode',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Island Highlights Carousel',
            capabilityIds: const ['C11-CAR'],
            child: AnimalCarousel(
              height: 160,
              items: [
                _buildSlide(
                  context,
                  'Spring Blossom Fair',
                  AnimalTileColor.appOrange,
                ),
                _buildSlide(
                  context,
                  'Summer Night Fireworks',
                  AnimalTileColor.appBlue,
                ),
                _buildSlide(
                  context,
                  'Autumn Mushroom Gathering',
                  AnimalTileColor.appTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(BuildContext context, String text, AnimalTileColor color) {
    final theme = AnimalIslandTheme.of(context);
    final tile = theme.colors.tile(color);
    return Container(
      decoration: BoxDecoration(
        color: tile.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: theme.typography.heading.copyWith(color: tile.foreground),
        ),
      ),
    );
  }
}

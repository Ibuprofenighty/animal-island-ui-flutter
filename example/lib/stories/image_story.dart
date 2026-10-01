import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class ImageStory extends StatelessWidget {
  const ImageStory({super.key});

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
            child: const Text('Image (C35)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Image container with skeleton placeholder, cute error fallback, and full-screen zoomable lightbox',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Click to Preview Lightbox',
            capabilityIds: const ['C35-IMG', 'IMG01'],
            child: const AnimalImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
              ),
              width: 160,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

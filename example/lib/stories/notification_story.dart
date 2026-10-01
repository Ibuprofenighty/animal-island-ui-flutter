import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class NotificationStory extends StatelessWidget {
  const NotificationStory({super.key});

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
            child: const Text('Notification (C30)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Scoped host notifications with synchronous transaction enqueue and exactly-once close (F07 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Notification Trigger (F07 Tested)',
            capabilityIds: const ['C30-NOT', 'NOT01', 'F07'],
            child: AnimalButton(
              onPressed: () {
                AnimalNotification.info(
                  context,
                  message: 'Island Mail Notice',
                  description: 'A parcel from Mom has arrived at your door!',
                );
              },
              child: const Text('Dispatch Notification'),
            ),
          ),
        ],
      ),
    );
  }
}

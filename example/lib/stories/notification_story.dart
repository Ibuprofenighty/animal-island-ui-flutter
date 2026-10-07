import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class NotificationStory extends StatefulWidget {
  const NotificationStory({super.key});

  @override
  State<NotificationStory> createState() => _NotificationStoryState();
}

class _NotificationStoryState extends State<NotificationStory> {
  AnimalNotificationPlacement _placement = AnimalNotificationPlacement.topRight;
  AnimalNotificationHandle? _upload;
  int _progress = 0;
  String _status = 'Idle';

  void _report(String status) {
    if (mounted) setState(() => _status = status);
  }

  void _dispatch() {
    final AnimalNotificationHandle handle = AnimalNotification.info(
      context,
      message: 'Island Mail Notice',
      description: 'A parcel from Mom has arrived at your door!',
      placement: _placement,
      onClose: () => _report('Mail notice closed'),
    );
    _report('Mail notice ${handle.status.name}');
  }

  void _updateUpload() {
    _progress = (_progress + 30).clamp(0, 100);
    final bool done = _progress == 100;
    // One business key: a live occurrence is updated in place and its
    // duration restarts; after it closes the key opens a new occurrence.
    _upload = AnimalNotification.open(
      context,
      key: 'upload',
      type: done ? AnimalNotificationType.success : AnimalNotificationType.info,
      message: Text(done ? 'Upload complete' : 'Uploading... $_progress%'),
      duration: done ? const Duration(seconds: 3) : null,
      placement: _placement,
      onClose: () {
        _progress = 0;
        _report('Upload notice closed');
      },
    );
    _report('Upload notice ${_upload?.status.name}');
  }

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
            'Notifications open in the nearest AnimalOverlayHost. Each placement '
            'shows up to 3 and queues up to 50; open returns a handle whose '
            'status reports active, waiting, rejected or closed.',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Placement queue',
            capabilityIds: const ['C30-NOT', 'NOT01', 'NOT04', 'NOT05'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final AnimalNotificationPlacement placement
                        in AnimalNotificationPlacement.values)
                      AnimalButton(
                        variant: placement == _placement
                            ? AnimalButtonVariant.filled
                            : AnimalButtonVariant.outlined,
                        onPressed: () => setState(() => _placement = placement),
                        child: Text(placement.name),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AnimalButton(
                      onPressed: _dispatch,
                      child: const Text('Dispatch Notification'),
                    ),
                    AnimalButton(
                      onPressed: () => AnimalNotification.closeAll(context),
                      child: const Text('Close All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StoryCard(
            title: 'Business key update',
            capabilityIds: const ['C30-NOT', 'NOT03'],
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AnimalButton(
                  onPressed: _updateUpload,
                  child: const Text('Advance Upload'),
                ),
                AnimalButton(
                  onPressed: () => _upload?.close(),
                  child: const Text('Close Upload Notice'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Last status: $_status', style: theme.typography.body),
        ],
      ),
    );
  }
}

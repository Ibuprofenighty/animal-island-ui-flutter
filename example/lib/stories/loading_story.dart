import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class LoadingStory extends StatefulWidget {
  const LoadingStory({super.key});

  @override
  State<LoadingStory> createState() => _LoadingStoryState();
}

class _LoadingStoryState extends State<LoadingStory> {
  AnimalLoadingHandle? _handle;

  @override
  void dispose() {
    _handle?.close();
    super.dispose();
  }

  Future<void> _showFullScreen() async {
    // The Gallery wraps every page in an AnimalOverlayHost.
    final AnimalLoadingHandle handle = AnimalLoading.show(
      context,
      tip: 'Syncing island...',
    );
    _handle = handle;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    } finally {
      handle.close();
      if (identical(_handle, handle)) _handle = null;
    }
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
            child: const Text('Loading (C25)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Island leaf spinners, snowflakes and bouncing dots, plus a '
            'full-screen loading shown in the nearest overlay host',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Loading Indicators',
            capabilityIds: const ['C25-LOD', 'LOD01', 'F14'],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimalLoading(type: AnimalLoadingType.spinner, tip: 'Spinning'),
                AnimalLoading(type: AnimalLoadingType.dots, tip: 'Bouncing'),
                AnimalLoading(
                  type: AnimalLoadingType.snowflake,
                  tip: 'Snowing',
                ),
              ],
            ),
          ),
          StoryCard(
            title: 'Full-screen Loading',
            capabilityIds: const ['LOD02', 'LOD03'],
            codeSnippet: '''final handle = AnimalLoading.show(
  context,
  tip: 'Syncing island...',
);
try {
  await sync();
} finally {
  handle.close();
}''',
            child: AnimalButton(
              onPressed: _showFullScreen,
              child: const Text('Show full-screen loading'),
            ),
          ),
        ],
      ),
    );
  }
}

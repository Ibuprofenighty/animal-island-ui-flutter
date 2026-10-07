import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class DrawerStory extends StatefulWidget {
  const DrawerStory({super.key});

  @override
  State<DrawerStory> createState() => _DrawerStoryState();
}

class _DrawerStoryState extends State<DrawerStory> {
  String _lastResult = 'No drawer result yet';

  Future<void> _open(AnimalDrawerPlacement placement) async {
    final String? choice = await AnimalDrawer.show<String>(
      context: context,
      placement: placement,
      title: const Text('Settings Drawer'),
      builder: (context, close) =>
          const Text('Drawer configuration panel content.'),
      footerBuilder: (context, close) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimalButton(
            size: AnimalButtonSize.small,
            onPressed: () => close('saved'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(
      () => _lastResult = '${placement.name}: ${choice ?? 'dismissed (null)'}',
    );
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
            child: const Text('Drawer (C22)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Route drawer sheet with four placements, safe-area and keyboard '
            'clamping, typed results and focus return',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Drawer Sheet Trigger',
            capabilityIds: const ['C22-DRW', 'DRW01', 'DRW02', 'DRW03'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final AnimalDrawerPlacement placement
                        in AnimalDrawerPlacement.values)
                      AnimalButton(
                        variant: placement == AnimalDrawerPlacement.right
                            ? AnimalButtonVariant.filled
                            : AnimalButtonVariant.outlined,
                        onPressed: () => _open(placement),
                        child: Text(
                          placement == AnimalDrawerPlacement.right
                              ? 'Open Right Drawer'
                              : 'Open ${placement.name} drawer',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_lastResult, style: theme.typography.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

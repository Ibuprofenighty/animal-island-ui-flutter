import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class ModalStory extends StatefulWidget {
  const ModalStory({super.key});

  @override
  State<ModalStory> createState() => _ModalStoryState();
}

class _ModalStoryState extends State<ModalStory> {
  String _lastResult = 'No modal result yet';

  void _report(String result) {
    if (mounted) setState(() => _lastResult = result);
  }

  Future<void> _confirm() async {
    final bool confirmed = await AnimalModal.confirm(
      context: context,
      title: const Text('Island Bulletin'),
      content: const Text(
        'Special visitor K.K. Slider is performing at the plaza!',
      ),
      confirmText: 'Understood',
    );
    _report('confirm: $confirmed');
  }

  Future<void> _asyncConfirm() async {
    var attempts = 0;
    final bool confirmed = await AnimalModal.confirm(
      context: context,
      title: const Text('Donate Fossils'),
      content: const Text('Send three fossils to the museum?'),
      onConfirm: () async {
        attempts += 1;
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (attempts == 1) {
          throw StateError('Blathers is asleep. Try again.');
        }
        return true;
      },
    );
    _report('async confirm: $confirmed after $attempts attempt(s)');
  }

  Future<void> _dialogue() async {
    final bool continued = await AnimalModal.showDialogue(
      context: context,
      speaker: 'Tom Nook',
      avatar: const AnimalIcon(data: AnimalIcons.leaf, size: 32),
      dialogue: 'Yes, yes! Welcome to your new island getaway!',
    );
    _report('dialogue: $continued');
  }

  Future<void> _pickFruit() async {
    final String? fruit = await AnimalModal.show<String>(
      context: context,
      title: const Text('Pick a Native Fruit'),
      builder: (context, close) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final String fruit in const ['Apple', 'Cherry', 'Peach'])
            AnimalButton(
              size: AnimalButtonSize.small,
              onPressed: () => close(fruit),
              child: Text(fruit),
            ),
        ],
      ),
    );
    _report('show<String>: ${fruit ?? 'dismissed (null)'}');
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
            child: const Text('Modal (C21)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Route modals with an organic blob border, typed results, guarded '
            'async confirmation and speaker dialogue',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Modal Triggers',
            capabilityIds: const [
              'C21-MOD',
              'MOD01',
              'MOD02',
              'MOD03',
              'MOD04',
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AnimalButton(
                      onPressed: _confirm,
                      child: const Text('Open Modal Dialog'),
                    ),
                    AnimalButton(
                      variant: AnimalButtonVariant.outlined,
                      onPressed: _asyncConfirm,
                      child: const Text('Async Confirm (fails once)'),
                    ),
                    AnimalButton(
                      variant: AnimalButtonVariant.outlined,
                      onPressed: _dialogue,
                      child: const Text('Talk to Tom Nook'),
                    ),
                    AnimalButton(
                      variant: AnimalButtonVariant.outlined,
                      onPressed: _pickFruit,
                      child: const Text('Pick a Fruit'),
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

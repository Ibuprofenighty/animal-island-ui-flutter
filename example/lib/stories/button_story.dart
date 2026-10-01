import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class ButtonStory extends StatefulWidget {
  const ButtonStory({super.key});

  @override
  State<ButtonStory> createState() => _ButtonStoryState();
}

class _ButtonStoryState extends State<ButtonStory> {
  int _clickCount = 0;
  bool _isLoading = false;

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
            child: const Text('Button (C01)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Cozy game-like 3D tactile buttons with signature 50px pill shape and spring press depth',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: '1. Visual Variants (Orthogonal Tones)',
            capabilityIds: const ['C01-BTN', 'BTN01', 'BTN02'],
            description: 'Filled (with stacked tactile depth), Outlined, Dashed, Text, and Link variants.',
            codeSnippet: """AnimalButton(
  variant: AnimalButtonVariant.filled,
  tone: AnimalButtonTone.primary,
  onPressed: () {},
  child: const Text('Filled Button'),
)""",
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.primary,
                  onPressed: () => setState(() => _clickCount++),
                  child: const Text('Primary Filled'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.outlined,
                  tone: AnimalButtonTone.primary,
                  onPressed: () => setState(() => _clickCount++),
                  child: const Text('Outlined'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.dashed,
                  tone: AnimalButtonTone.primary,
                  onPressed: () => setState(() => _clickCount++),
                  child: const Text('Dashed'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.text,
                  onPressed: () => setState(() => _clickCount++),
                  child: const Text('Text Link'),
                ),
              ],
            ),
          ),
          StoryCard(
            title: '2. Semantic Color Tones',
            capabilityIds: const ['BTN03'],
            description: 'Semantic status tones: Primary, Success, Warning, Danger, and Neutral.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.primary,
                  onPressed: () {},
                  child: const Text('Primary'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.success,
                  onPressed: () {},
                  child: const Text('Success'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.warning,
                  onPressed: () {},
                  child: const Text('Warning'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.danger,
                  onPressed: () {},
                  child: const Text('Danger'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.neutral,
                  onPressed: () {},
                  child: const Text('Neutral'),
                ),
              ],
            ),
          ),
          StoryCard(
            title: '3. Sizes, Icons & Disabled States',
            capabilityIds: const ['BTN04'],
            keyboardTips: 'Tab to focus, Space or Enter to trigger. Disabled buttons reject pointer and keyboard inputs.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AnimalButton(
                  size: AnimalButtonSize.small,
                  icon: const AnimalIcon(data: AnimalIcons.star, size: 14),
                  onPressed: () {},
                  child: const Text('Small'),
                ),
                AnimalButton(
                  size: AnimalButtonSize.middle,
                  icon: const AnimalIcon(data: AnimalIcons.star, size: 18),
                  onPressed: () {},
                  child: const Text('Medium'),
                ),
                AnimalButton(
                  size: AnimalButtonSize.large,
                  icon: const AnimalIcon(data: AnimalIcons.trophy, size: 22),
                  onPressed: () {},
                  child: const Text('Large'),
                ),
                const AnimalButton(
                  disabled: true,
                  onPressed: null,
                  child: Text('Disabled'),
                ),
                AnimalButton(
                  loading: true,
                  onPressed: () {},
                  child: const Text('Loading'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: '4. Interactive Loading & Async Trigger',
            capabilityIds: const ['C01-BTN', 'BTN01'],
            description: 'Buttons support built-in loading spinners that block duplicate taps and keyboard triggers during async tasks.',
            codeSnippet: """AnimalButton(
  loading: _isLoading,
  onPressed: () async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  },
  child: Text(_isLoading ? 'Submitting...' : 'Click to Load (2s)'),
)""",
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AnimalButton(
                  loading: _isLoading,
                  tone: AnimalButtonTone.primary,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _isLoading = false);
                  },
                  child: Text(
                    _isLoading ? 'Submitting...' : 'Click to Load (2s)',
                  ),
                ),
                AnimalButton(
                  loading: true,
                  tone: AnimalButtonTone.success,
                  onPressed: () {},
                  child: const Text('Success Loading'),
                ),
                AnimalButton(
                  loading: true,
                  variant: AnimalButtonVariant.outlined,
                  tone: AnimalButtonTone.danger,
                  onPressed: () {},
                  child: const Text('Outlined Loading'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

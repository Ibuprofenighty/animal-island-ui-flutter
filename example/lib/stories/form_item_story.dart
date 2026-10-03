import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class FormItemStory extends StatefulWidget {
  const FormItemStory({super.key});

  @override
  State<FormItemStory> createState() => _FormItemStoryState();
}

class _FormItemStoryState extends State<FormItemStory> {
  final _demoKey = AnimalFieldKey<String>(debugLabel: 'demo');
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
            child: const Text('FormItem (C20)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Explicit builder binding form item eliminating ambient scope theft and providing smooth error transitions',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'FormItem Anatomy',
            capabilityIds: const ['C20-FI', 'FI01'],
            child: AnimalForm(
              child: AnimalFormItem<String>(
                fieldKey: _demoKey,
                textController: _textController,
                label: 'Sample Label',
                help: 'Helpful hint explaining requirements',
                required: true,
                builder: (context, binding) {
                  return AnimalInput(
                    controller: _textController,
                    placeholder: 'Enter content...',
                    focusNode: binding.focusNode,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class FormStory extends StatefulWidget {
  const FormStory({super.key});

  @override
  State<FormStory> createState() => _FormStoryState();
}

class _FormStoryState extends State<FormStory> {
  final _controller = AnimalFormController();
  final _keyName = const AnimalFieldKey<String>('islandName');

  @override
  void dispose() {
    _controller.dispose();
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
            child: const Text('Form (C19)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Typed form container with validation epoch and asynchronous race defense (F06 Root Fix)',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Simple Form Validation',
            capabilityIds: const ['C19-FOR', 'FOR01', 'F06'],
            child: AnimalForm(
              controller: _controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimalFormItem<String>(
                    fieldKey: _keyName,
                    label: 'Island Name',
                    required: true,
                    rules: [
                      AnimalRule.required(
                        message: 'Island name cannot be empty',
                      ),
                    ],
                    builder: (context, binding) {
                      return AnimalInput(
                        value: binding.value,
                        status: binding.error != null
                            ? AnimalInputStatus.error
                            : AnimalInputStatus.normal,
                        onChanged: binding.onChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AnimalButton(
                    onPressed: () async {
                      await _controller.validate();
                    },
                    child: const Text('Validate Island Name'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

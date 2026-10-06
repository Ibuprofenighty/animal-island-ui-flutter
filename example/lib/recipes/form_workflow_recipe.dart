import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class FormWorkflowRecipe extends StatefulWidget {
  const FormWorkflowRecipe({super.key});

  @override
  State<FormWorkflowRecipe> createState() => _FormWorkflowRecipeState();
}

class _FormWorkflowRecipeState extends State<FormWorkflowRecipe> {
  final _formController = AnimalFormController();
  final _usernameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _kUsername = AnimalFieldKey<String>(debugLabel: 'username');
  final _kEmail = AnimalFieldKey<String>(debugLabel: 'email');
  final _kRole = AnimalFieldKey<String>(debugLabel: 'role');
  final _kNotifications = AnimalFieldKey<bool>(debugLabel: 'notifications');
  final _kSkills = AnimalFieldKey.list<String>(debugLabel: 'skills');
  final _kBirthDate = AnimalFieldKey<AnimalDateSelection>(
    debugLabel: 'birthDate',
  );
  final _kCheckInTime = AnimalFieldKey<AnimalTimeValue>(
    debugLabel: 'checkInTime',
  );

  String? _submissionResult;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _formController.dispose();
    _usernameTextController.dispose();
    _emailTextController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _submissionResult = null;
    });

    late AnimalFormValues submittedValues;
    final result = await _formController.submit(
      onSubmit: (values) async {
        submittedValues = values;
        // Simulated network request and server-side rejection.
        await Future.delayed(const Duration(milliseconds: 600));
        return values.valueFor(_kUsername)?.toLowerCase() != 'island-reject';
      },
    );
    if (!mounted) return;

    final message = switch (result.status) {
      AnimalSubmitStatus.success =>
        'Registration successful for: ${submittedValues.valueFor(_kUsername)} (${submittedValues.valueFor(_kEmail)})\n'
            'Role: ${submittedValues.valueFor(_kRole)}, BirthDate: ${submittedValues.valueFor(_kBirthDate)}, CheckIn: ${submittedValues.valueFor(_kCheckInTime)}',
      AnimalSubmitStatus.invalid =>
        'Validation failed! Please review the highlighted errors above.',
      AnimalSubmitStatus.rejected =>
        'The server rejected this registration. Choose another nickname.',
      AnimalSubmitStatus.changedDuringValidation => 'Form state changed or was cancelled while submitting. Please try again.',
      AnimalSubmitStatus.busy => 'A registration is already in progress.',
      AnimalSubmitStatus.error => 'Submission failed: ${result.error}',
    };
    setState(() {
      _isSubmitting = false;
      _submissionResult = message;
    });
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
            child: const Text('Recipe 1: Form Lifecycle & Async Validation'),
          ),
          const SizedBox(height: 8),
          Text(
            'End-to-end interactive workflow verifying typed field bindings, asynchronous race defense, and autofocus error recovery',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Island Resident Registration Form',
            capabilityIds: const [
              'C19-FOR',
              'C20-FI',
              'C12-INP',
              'C13-SW',
              'C14-CHK',
              'C15-RAD',
              'C17-DAT',
              'C18-TIM',
              'F06',
            ],
            description: 'Demonstrates real form validation with asynchronous server checks (e.g. username taken), atomic reset, and focus management.',
            child: AnimalForm(
              controller: _formController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username Field with async uniqueness validator
                  AnimalFormItem<String>(
                    fieldKey: _kUsername,
                    textController: _usernameTextController,
                    label: 'Resident Nickname',
                    required: true,
                    rules: [
                      AnimalRule.required(message: 'Nickname is required'),
                      AnimalRule.length(
                        min: 3,
                        message: 'Nickname must be at least 3 characters',
                      ),
                      AnimalRule.custom((val) async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (val?.toLowerCase() == 'taken') {
                          return 'Nickname "taken" is already occupied on this island';
                        }
                        return null;
                      }),
                    ],
                    builder: (context, binding) {
                      return AnimalInput(
                        controller: _usernameTextController,
                        placeholder: 'Try "taken" for validation or "island-reject" for server rejection',
                        status: binding.error != null
                            ? AnimalInputStatus.error
                            : AnimalInputStatus.normal,
                        focusNode: binding.focusNode,
                        clearable: true,
                        prefix: const AnimalIcon(
                          data: AnimalIcons.user,
                          size: 18,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  AnimalFormItem<String>(
                    fieldKey: _kEmail,
                    textController: _emailTextController,
                    label: 'Contact Email',
                    required: true,
                    rules: [
                      AnimalRule.required(message: 'Email address is required'),
                      AnimalRule.pattern(
                        RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$'),
                        message: 'Please provide a valid email format',
                      ),
                    ],
                    builder: (context, binding) {
                      return AnimalInput(
                        controller: _emailTextController,
                        placeholder: 'resident@island.com',
                        status: binding.error != null
                            ? AnimalInputStatus.error
                            : AnimalInputStatus.normal,
                        focusNode: binding.focusNode,
                        clearable: true,
                        prefix: const AnimalIcon(
                          data: AnimalIcons.mail,
                          size: 18,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Role Selection (Radio)
                  AnimalFormItem<String>(
                    fieldKey: _kRole,
                    label: 'Island Role',
                    initialValue: 'farmer',
                    builder: (context, binding) {
                      return AnimalRadioGroup<String>(
                        value: binding.value,
                        options: const [
                          AnimalOption(
                            label: 'Gardener & Farmer',
                            value: 'farmer',
                          ),
                          AnimalOption(
                            label: 'Fish & Marine Explorer',
                            value: 'angler',
                          ),
                          AnimalOption(
                            label: 'Town Decorator',
                            value: 'designer',
                          ),
                        ],
                        onChanged: binding.onChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Birth Date (DatePicker)
                  AnimalFormItem<AnimalDateSelection>(
                    fieldKey: _kBirthDate,
                    label: 'Island Arrival Date',
                    required: true,
                    rules: [
                      AnimalRule.required(
                        message: 'Please choose an arrival date',
                      ),
                    ],
                    builder: (context, binding) {
                      return AnimalDatePicker.popover(
                        selection: binding.value,
                        placeholder: 'Pick arrival date',
                        onChanged: binding.onChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Daily Check-in Time (TimePicker)
                  AnimalFormItem<AnimalTimeValue>(
                    fieldKey: _kCheckInTime,
                    label: 'Daily Gathering Time',
                    builder: (context, binding) {
                      return AnimalTimePicker.popover(
                        value: binding.value,
                        placeholder: 'Select gathering hour & minute',
                        onChanged: binding.onChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Skills Checkbox Group
                  AnimalFormItem<List<String>>(
                    fieldKey: _kSkills,
                    label: 'Island Activities & Interests',
                    initialValue: const ['crafting'],
                    builder: (context, binding) {
                      return AnimalCheckboxGroup<String>(
                        value: binding.value ?? const [],
                        options: const [
                          AnimalOption(
                            label: 'Fruit Harvesting',
                            value: 'harvest',
                          ),
                          AnimalOption(
                            label: 'Tool Crafting',
                            value: 'crafting',
                          ),
                          AnimalOption(
                            label: 'Fossil Hunting',
                            value: 'fossils',
                          ),
                        ],
                        onChanged: binding.onChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Notification Switch
                  AnimalFormItem<bool>(
                    fieldKey: _kNotifications,
                    label: 'Island Bulletin Notifications',
                    initialValue: true,
                    builder: (context, binding) {
                      return Row(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 58),
                            child: AnimalSwitch(
                              value: binding.value ?? false,
                              onChanged: binding.onChanged,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            (binding.value ?? false)
                                ? 'Receive morning announcements'
                                : 'Muted',
                            style: theme.typography.body,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      AnimalButton(
                        variant: AnimalButtonVariant.filled,
                        tone: AnimalButtonTone.primary,
                        icon: const AnimalIcon(
                          data: AnimalIcons.check,
                          size: 18,
                        ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: Text(
                          _isSubmitting
                              ? 'Registering...'
                              : 'Submit Application',
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimalButton(
                        variant: AnimalButtonVariant.outlined,
                        tone: AnimalButtonTone.neutral,
                        icon: const AnimalIcon(
                          data: AnimalIcons.refresh,
                          size: 18,
                        ),
                        onPressed: () {
                          _formController.reset();
                          setState(() => _submissionResult = null);
                        },
                        child: const Text('Reset Form'),
                      ),
                      const SizedBox(width: 12),
                      AnimalButton(
                        variant: AnimalButtonVariant.text,
                        onPressed: () {
                          _formController.clear();
                          setState(() => _submissionResult = null);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  if (_submissionResult != null) ...[
                    const SizedBox(height: 20),
                    AnimalCard(
                      child: Row(
                        children: [
                          AnimalIcon(
                            data: _submissionResult!.startsWith('Registration')
                                ? AnimalIcons.check
                                : AnimalIcons.close,
                            size: 24,
                            color: _submissionResult!.startsWith('Registration')
                                ? theme.colors.success
                                : theme.colors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _submissionResult!,
                              style: theme.typography.body.copyWith(
                                color:
                                    _submissionResult!.startsWith(
                                      'Registration',
                                    )
                                    ? theme.colors.success
                                    : theme.colors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

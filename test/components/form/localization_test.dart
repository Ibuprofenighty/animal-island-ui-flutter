import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C19 AnimalForm preserves its typed issue while locale changes', (
    tester,
  ) async {
    final controller = AnimalFormController();
    final localeController = LocalizationTestController(
      initialLocale: const Locale('en'),
    );
    final key = AnimalFieldKey<String>(debugLabel: 'required-value');
    var customRuleRuns = 0;

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: localeController,
        child: Scaffold(
          body: AnimalForm(
            controller: controller,
            child: AnimalFormItem<String>(
              fieldKey: key,
              label: 'Caller-owned label',
              rules: [
                AnimalRule<String>.custom((_) {
                  customRuleRuns++;
                  return null;
                }),
                AnimalRule<String>.required(),
              ],
              builder: (_, _) => const SizedBox(height: 1),
            ),
          ),
        ),
      ),
    );

    expect(await controller.validate(null, false), isFalse);
    expect(customRuleRuns, 1);
    final issueBeforeLocaleChange = controller.getFieldError(key);
    expect(
      issueBeforeLocaleChange?.kind,
      AnimalValidationIssueKind.requiredField,
    );

    localeController.locale = const Locale('zh', 'TW');
    await tester.pumpAndSettle();

    expect(controller.getFieldError(key), same(issueBeforeLocaleChange));
    expect(customRuleRuns, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    localeController.dispose();
  });

  testWidgets(
    'stored validation issues retranslate after locale changes without rerunning validation',
    (tester) async {
      final controller = AnimalFormController();
      final localeController = LocalizationTestController(
        initialLocale: const Locale('en'),
      );
      final key = AnimalFieldKey<String>(debugLabel: 'required-value');
      var customRuleRuns = 0;

      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: localeController,
          child: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: AnimalFormItem<String>(
                fieldKey: key,
                label: 'Caller-owned label',
                rules: [
                  AnimalRule<String>.custom((_) {
                    customRuleRuns++;
                    return null;
                  }),
                  AnimalRule<String>.required(),
                ],
                builder: (_, _) => const SizedBox(height: 1),
              ),
            ),
          ),
        ),
      );

      expect(await controller.validate(null, false), isFalse);
      await tester.pumpAndSettle();
      expect(customRuleRuns, 1);
      expect(find.text('This field is required'), findsOneWidget);
      expect(find.text('Caller-owned label'), findsOneWidget);

      localeController.locale = const Locale('zh', 'TW');
      await tester.pumpAndSettle();

      expect(find.text('此字段为必填项'), findsOneWidget);
      expect(find.text('Caller-owned label'), findsOneWidget);
      expect(customRuleRuns, 1);
      expect(
        controller.getFieldError(key)?.kind,
        AnimalValidationIssueKind.requiredField,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      localeController.dispose();
    },
  );

  testWidgets(
    'all built-in issue kinds localize and caller messages remain literal',
    (tester) async {
      final controller = AnimalFormController();
      final localeController = LocalizationTestController(
        initialLocale: const Locale('en'),
      );
      var asyncValidatorRuns = 0;
      final requiredKey = AnimalFieldKey<String>(debugLabel: 'required');
      final emailKey = AnimalFieldKey<String>(debugLabel: 'email');
      final urlKey = AnimalFieldKey<String>(debugLabel: 'url');
      final patternKey = AnimalFieldKey<String>(debugLabel: 'pattern');
      final minimumKey = AnimalFieldKey<num>(debugLabel: 'minimum');
      final maximumKey = AnimalFieldKey<num>(debugLabel: 'maximum');
      final minimumLengthKey = AnimalFieldKey<String>(
        debugLabel: 'minimum-length',
      );
      final maximumLengthKey = AnimalFieldKey<String>(
        debugLabel: 'maximum-length',
      );
      final lengthRangeKey = AnimalFieldKey<String>(debugLabel: 'length-range');
      final exceptionKey = AnimalFieldKey<String>(debugLabel: 'exception');
      final callerMessageKey = AnimalFieldKey<String>(
        debugLabel: 'caller-message',
      );
      final asyncCallerMessageKey = AnimalFieldKey<String>(
        debugLabel: 'async-caller-message',
      );

      AnimalFormItem<T> field<T>({
        required String label,
        required AnimalFieldKey<T> fieldKey,
        required T initialValue,
        required List<AnimalRule<T>> rules,
      }) => AnimalFormItem<T>(
        fieldKey: fieldKey,
        label: label,
        initialValue: initialValue,
        rules: rules,
        builder: (_, _) => const SizedBox(height: 1),
      );

      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: localeController,
          child: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    field<String>(
                      label: 'required',
                      fieldKey: requiredKey,
                      initialValue: '',
                      rules: [AnimalRule<String>.required()],
                    ),
                    field<String>(
                      label: 'email',
                      fieldKey: emailKey,
                      initialValue: 'invalid',
                      rules: [AnimalRule<String>.email()],
                    ),
                    field<String>(
                      label: 'url',
                      fieldKey: urlKey,
                      initialValue: 'invalid',
                      rules: [AnimalRule<String>.url()],
                    ),
                    field<String>(
                      label: 'pattern',
                      fieldKey: patternKey,
                      initialValue: 'no',
                      rules: [AnimalRule<String>.pattern(RegExp(r'^yes$'))],
                    ),
                    field<num>(
                      label: 'minimum',
                      fieldKey: minimumKey,
                      initialValue: 5,
                      rules: [AnimalRule<num>.min(10)],
                    ),
                    field<num>(
                      label: 'maximum',
                      fieldKey: maximumKey,
                      initialValue: 11,
                      rules: [AnimalRule<num>.max(10)],
                    ),
                    field<String>(
                      label: 'minimum-length',
                      fieldKey: minimumLengthKey,
                      initialValue: 'a',
                      rules: [AnimalRule<String>.length(min: 3)],
                    ),
                    field<String>(
                      label: 'maximum-length',
                      fieldKey: maximumLengthKey,
                      initialValue: 'abcd',
                      rules: [AnimalRule<String>.length(max: 3)],
                    ),
                    field<String>(
                      label: 'length-range',
                      fieldKey: lengthRangeKey,
                      initialValue: 'a',
                      rules: [AnimalRule<String>.length(min: 3, max: 5)],
                    ),
                    field<String>(
                      label: 'exception',
                      fieldKey: exceptionKey,
                      initialValue: 'value',
                      rules: [
                        AnimalRule<String>.custom((_) {
                          throw StateError('validator failed');
                        }),
                      ],
                    ),
                    field<String>(
                      label: 'caller-message',
                      fieldKey: callerMessageKey,
                      initialValue: '',
                      rules: [
                        AnimalRule<String>.required(message: 'Caller message'),
                      ],
                    ),
                    field<String>(
                      label: 'async-caller-message',
                      fieldKey: asyncCallerMessageKey,
                      initialValue: 'value',
                      rules: [
                        AnimalRule<String>.custom((_) async {
                          asyncValidatorRuns++;
                          return 'Async caller message';
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(await controller.validate(null, false), isFalse);
      await tester.pumpAndSettle();
      const englishMessages = [
        'This field is required',
        'Please enter a valid email address',
        'Please enter a valid URL',
        'Value does not match the required pattern',
        'Value must be at least 10',
        'Value cannot exceed 10',
        'Length must be at least 3',
        'Length cannot exceed 3',
        'Length must be between 3 and 5',
        'Validation could not be completed',
        'Caller message',
        'Async caller message',
      ];
      for (final message in englishMessages) {
        expect(find.text(message), findsOneWidget, reason: message);
      }
      expect(asyncValidatorRuns, 1);

      localeController.locale = const Locale('zh', 'TW');
      await tester.pumpAndSettle();
      const chineseMessages = [
        '此字段为必填项',
        '请输入有效的电子邮件地址',
        '请输入有效的网址',
        '输入内容不符合要求的格式',
        '数值必须大于或等于 10',
        '数值不能大于 10',
        '长度至少为 3',
        '长度不能超过 3',
        '长度必须介于 3 和 5 之间',
        '验证暂时无法完成',
        'Caller message',
        'Async caller message',
      ];
      for (final message in chineseMessages) {
        expect(find.text(message), findsOneWidget, reason: message);
      }
      expect(asyncValidatorRuns, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      localeController.dispose();
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalFormItem Tests (C20 / FIT01-FIT04)', () {
    testWidgets('FIT01: displays label, required indicator, and help text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              child: AnimalFormItem<String>(
                name: 'nickname',
                label: 'Nickname',
                required: true,
                help: 'Enter your friendly islander nickname',
                child: AnimalInput(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nickname'), findsOneWidget);
      expect(find.text('* '), findsOneWidget);
      expect(
        find.text('Enter your friendly islander nickname'),
        findsOneWidget,
      );
    });

    testWidgets(
      'FIT02: error message replaces help text and renders with error style',
      (tester) async {
        final controller = AnimalFormController();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: AnimalFormItem<String>(
                  name: 'email',
                  label: 'Email',
                  help: 'We never share your email',
                  rules: [AnimalRule.required(message: 'Email is required')],
                  builder: (context, binding) {
                    return AnimalInput(
                      status: binding.error != null
                          ? AnimalInputStatus.error
                          : AnimalInputStatus.normal,
                      onChanged: binding.onChanged,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Initially shows help text
        expect(find.text('We never share your email'), findsOneWidget);
        expect(find.text('Email is required'), findsNothing);

        // Trigger validation error
        final isValid = await controller.validate();
        expect(isValid, isFalse);
        await tester.pumpAndSettle();

        // Help text replaced by error text
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('We never share your email'), findsNothing);
      },
    );

    testWidgets(
      'FIT03: focusNode in FormItem is focused by focusFirstError()',
      (tester) async {
        final controller = AnimalFormController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: AnimalFormItem<String>(
                  name: 'username',
                  label: 'Username',
                  focusNode: focusNode,
                  rules: [AnimalRule.required(message: 'Username is required')],
                  builder: (context, binding) {
                    return AnimalInput(
                      focusNode: binding.focusNode,
                      onChanged: binding.onChanged,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(focusNode.hasFocus, isFalse);

        await controller.validate();
        await tester.pumpAndSettle();

        controller.focusFirstError();
        await tester.pumpAndSettle();

        expect(focusNode.hasFocus, isTrue);

        focusNode.dispose();
      },
    );

    testWidgets('FIT04: custom labelWidget overrides text label', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              child: AnimalFormItem<String>(
                name: 'custom',
                label: 'Default Label',
                labelWidget: Text('Custom Rich Label'),
                child: AnimalInput(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Rich Label'), findsOneWidget);
      expect(find.text('Default Label'), findsNothing);
    });
  });
}

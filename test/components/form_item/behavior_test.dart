import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalFormItem Tests (C20 / FIT01-FIT04)', () {
    testWidgets('a field without a typed form owner fails during composition', (
      tester,
    ) async {
      final key = AnimalFieldKey<String>(debugLabel: 'missing-owner');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalFormItem<String>(
              fieldKey: key,
              builder: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isA<StateError>());
    });

    testWidgets('FIT01: displays label, required indicator, and help text', (
      tester,
    ) async {
      final nicknameKey = AnimalFieldKey<String>(debugLabel: 'nickname');
      final nicknameBuffer = TextEditingController();
      addTearDown(nicknameBuffer.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              child: AnimalFormItem<String>(
                fieldKey: nicknameKey,
                textController: nicknameBuffer,
                label: 'Nickname',
                required: true,
                help: 'Enter your friendly islander nickname',
                builder: (_, _) => AnimalInput(controller: nicknameBuffer),
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
        final emailKey = AnimalFieldKey<String>(debugLabel: 'email');
        final emailBuffer = TextEditingController();
        addTearDown(() {
          controller.dispose();
          emailBuffer.dispose();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: AnimalFormItem<String>(
                  fieldKey: emailKey,
                  textController: emailBuffer,
                  label: 'Email',
                  help: 'We never share your email',
                  rules: [AnimalRule.required(message: 'Email is required')],
                  builder: (context, binding) {
                    return AnimalInput(
                      controller: emailBuffer,
                      status: binding.error != null
                          ? AnimalInputStatus.error
                          : AnimalInputStatus.normal,
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
        final usernameKey = AnimalFieldKey<String>(debugLabel: 'username');
        final usernameBuffer = TextEditingController();
        addTearDown(() {
          controller.dispose();
          focusNode.dispose();
          usernameBuffer.dispose();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: AnimalFormItem<String>(
                  fieldKey: usernameKey,
                  textController: usernameBuffer,
                  label: 'Username',
                  focusNode: focusNode,
                  rules: [AnimalRule.required(message: 'Username is required')],
                  builder: (context, binding) {
                    return AnimalInput(
                      controller: usernameBuffer,
                      focusNode: binding.focusNode,
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
      },
    );

    testWidgets('FIT04: custom labelWidget overrides text label', (
      tester,
    ) async {
      final customKey = AnimalFieldKey<String>(debugLabel: 'custom');
      final customBuffer = TextEditingController();
      addTearDown(customBuffer.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              child: AnimalFormItem<String>(
                fieldKey: customKey,
                textController: customBuffer,
                label: 'Default Label',
                labelWidget: Text('Custom Rich Label'),
                builder: (_, _) => AnimalInput(controller: customBuffer),
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

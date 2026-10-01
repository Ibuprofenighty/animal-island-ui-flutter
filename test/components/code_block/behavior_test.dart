import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'AnimalCodeBlock S12 Contract & Behavior Tests (F25 / COD01-COD03)',
    () {
      testWidgets(
        'COD01: Successful copy awaits Clipboard and displays Copied! feedback',
        (tester) async {
          String? clipboardContent;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, (
                methodCall,
              ) async {
                if (methodCall.method == 'Clipboard.setData') {
                  final Map<String, dynamic> args =
                      methodCall.arguments as Map<String, dynamic>;
                  clipboardContent = args['text'] as String?;
                  return null;
                }
                return null;
              });

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCodeBlock(code: 'final x = 42;', language: 'dart'),
              ),
            ),
          );

          expect(find.text('Copy'), findsOneWidget);
          expect(find.text('dart'), findsOneWidget);
          expect(find.text('final x = 42;'), findsOneWidget);

          await tester.tap(find.text('Copy'));
          await tester.pumpAndSettle();

          expect(clipboardContent, equals('final x = 42;'));
          expect(find.text('Copied!'), findsOneWidget);
        },
      );

      testWidgets(
        'COD01: Clipboard failure does NOT display Copied! and reports Failed',
        (tester) async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, (
                methodCall,
              ) async {
                if (methodCall.method == 'Clipboard.setData') {
                  throw PlatformException(
                    code: 'PERMISSION_DENIED',
                    message: 'Access denied',
                  );
                }
                return null;
              });

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCodeBlock(code: 'echo "hello"', language: 'bash'),
              ),
            ),
          );

          await tester.tap(find.text('Copy'));
          await tester.pumpAndSettle();

          final codeBlockContext = tester.element(find.byType(AnimalCodeBlock));
          final localizations = AnimalLocalizations.of(codeBlockContext)!;

          expect(
            find.text('Copied!'),
            findsNothing,
            reason: 'COD01 clipboard failure must not show Copied! feedback',
          );
          expect(find.text(localizations.copyFailed), findsOneWidget);
        },
      );

      testWidgets(
        'COD02: Rapid sequential copy does not suffer stale reset race conditions',
        (tester) async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, (
                methodCall,
              ) async {
                return null;
              });

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCodeBlock(code: 'const island = "cozy";'),
              ),
            ),
          );

          // t0 copy
          await tester.tap(find.text('Copy'));
          await tester.pump();
          expect(find.text('Copied!'), findsOneWidget);

          // Advance time by 1.5s
          await tester.pump(const Duration(milliseconds: 1500));

          // t1 copy before t0 timer finishes (t0 would fire at 2.0s)
          await tester.tap(find.text('Copied!'));
          await tester.pump();

          // Advance by another 1.0s (total 2.5s from start, past original t0 timer)
          await tester.pump(const Duration(seconds: 1));

          // Should still show Copied! because t1 reset timer was set for 2.0s from t1!
          expect(find.text('Copied!'), findsOneWidget);

          // Advance remaining time to complete t1
          await tester.pump(const Duration(seconds: 2));
          expect(find.text('Copy'), findsOneWidget);
        },
      );

      testWidgets(
        'COD03: Typography boundaries ensure monospace only for code text',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCodeBlock(
                  code: 'SELECT * FROM villagers;',
                  language: 'sql',
                ),
              ),
            ),
          );

          final codeWidget = tester.widget<SelectableText>(
            find.byType(SelectableText),
          );
          expect(codeWidget.style?.fontFamily, equals('monospace'));

          final langWidget = tester.widget<Text>(find.text('sql'));
          expect(langWidget.style?.fontFamily, isNot(equals('monospace')));
        },
      );
    },
  );
}

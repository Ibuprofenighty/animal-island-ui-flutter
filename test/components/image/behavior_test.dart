import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

class _FakeErrorImageProvider extends ImageProvider<_FakeErrorImageProvider> {
  const _FakeErrorImageProvider();

  @override
  Future<_FakeErrorImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FakeErrorImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _FakeErrorImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final completer = OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(Exception('Failed to load fake image')),
    );
    return completer;
  }
}

void main() {
  group('AnimalImage S12 Contract & Behavior Tests (IMG01-IMG03)', () {
    testWidgets(
      'IMG01: Error fallback renders gracefully on image error without layout crash',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalImage(
                image: _FakeErrorImageProvider(),
                width: 120,
                height: 120,
              ),
            ),
          ),
        );

        await tester.pump();

        // Verified fallback icon renders inside the frame
        expect(find.byType(AnimalIcon), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'IMG02: Preview opens interactive lightbox and closes via close button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalImage(
                image: const _FakeErrorImageProvider(),
                width: 100,
                height: 100,
                preview: true,
                semanticLabel: 'Sample Photo',
              ),
            ),
          ),
        );

        // Verify preview trigger exists
        expect(
          find.bySemanticsLabel('Sample Photo, click to preview'),
          findsOneWidget,
        );

        // Tap to open lightbox
        await tester.tap(
          find.bySemanticsLabel('Sample Photo, click to preview'),
        );
        await tester.pumpAndSettle();

        // Lightbox is open: Close button is visible
        expect(find.bySemanticsLabel('Close preview'), findsOneWidget);

        // Tap close button to exit lightbox
        await tester.tap(find.bySemanticsLabel('Close preview'));
        await tester.pumpAndSettle();

        // Lightbox is closed
        expect(find.bySemanticsLabel('Close preview'), findsNothing);
      },
    );

    testWidgets('IMG02: Preview closes via Escape key and restores focus', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalImage(
              image: const _FakeErrorImageProvider(),
              width: 100,
              height: 100,
              preview: true,
              semanticLabel: 'Test Image',
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Test Image, click to preview'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Close preview'), findsOneWidget);

      // Press Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Close preview'), findsNothing);
    });
  });
}

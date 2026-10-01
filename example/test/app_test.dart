import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:example/app.dart';

void main() {
  testWidgets('App renders shell and responds to theme and controls', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AnimalIslandGalleryApp());
    await tester.pumpAndSettle();

    // Verify title and header
    expect(find.text('Animal Island UI'), findsOneWidget);
    final localizations = AnimalLocalizations.of(
      tester.element(find.text('Animal Island UI')),
    )!;
    final appFinder = find.byType(MaterialApp);
    expect(
      tester.widget<MaterialApp>(appFinder).theme!.brightness,
      Brightness.light,
    );
    expect(
      find.text(localizations.galleryDevelopmentCandidateBadge),
      findsOneWidget,
    );

    // Verify theme toggle button exists
    final themeToggle = find.text(localizations.galleryThemeLight);
    expect(themeToggle, findsOneWidget);
    await tester.ensureVisible(themeToggle);
    await tester.pumpAndSettle();
    await tester.tap(themeToggle);
    await tester.pumpAndSettle();

    // After toggle, text becomes Dark
    expect(
      tester.widget<MaterialApp>(appFinder).theme!.brightness,
      Brightness.dark,
    );
    expect(find.text(localizations.galleryThemeDark), findsOneWidget);

    // Verify motion toggle
    final motionToggle = find.text(localizations.galleryReducedMotionOff);
    expect(motionToggle, findsOneWidget);
    await tester.ensureVisible(motionToggle);
    await tester.pumpAndSettle();
    await tester.tap(motionToggle);
    await tester.pumpAndSettle();
    expect(find.text(localizations.galleryReducedMotionOn), findsOneWidget);

    // Verify text scale toggle
    final scaleToggle = find.text(localizations.galleryTextScaleValue(1.0));
    expect(scaleToggle, findsOneWidget);
    await tester.ensureVisible(scaleToggle);
    await tester.pumpAndSettle();
    await tester.tap(scaleToggle);
    await tester.pumpAndSettle();
    expect(find.text(localizations.galleryTextScaleValue(1.5)), findsOneWidget);
  });
}

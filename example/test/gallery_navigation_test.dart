import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/l10n/generated/gallery_localizations.g.dart';
import 'package:example/app.dart';

void main() {
  testWidgets('Gallery Navigation: opens overview by default', (
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

    final localizations = GalleryLocalizations.of(
      tester.element(find.text('Animal Island UI')),
    );
    expect(find.text(localizations.galleryWelcomeTitle), findsOneWidget);
    expect(find.text(localizations.galleryCount(36)), findsOneWidget);
    expect(find.text(localizations.galleryMetricComponents), findsOneWidget);
    expect(find.text('101'), findsNWidgets(2));
    expect(find.text(localizations.galleryMetricIcons), findsOneWidget);
  });

  testWidgets('Gallery Navigation: navigates to Button story via sidebar', (
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

    // Click on Button (C01) nav item in sidebar
    final buttonNavItem = find.text('Button (C01)');
    expect(buttonNavItem, findsOneWidget);
    await tester.tap(buttonNavItem);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Button story loaded
    expect(find.text('Button (C01)'), findsWidgets);
    expect(find.text('1. Visual Variants (Orthogonal Tones)'), findsOneWidget);
    expect(find.text('Primary Filled'), findsOneWidget);
  });

  testWidgets('Gallery Navigation: navigates to Icons Browser', (
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

    // Find 101 Icons Gallery chip in Overview
    final iconsChip = find.text('101 Icons Gallery');
    expect(iconsChip, findsOneWidget);
    await tester.tap(iconsChip);
    await tester.pumpAndSettle();

    expect(find.text('101 Canonical Vector Icons (C02)'), findsOneWidget);
    expect(find.text('101 / 101 Icons'), findsOneWidget);
  });

  testWidgets('Gallery Navigation: navigates to Form Workflow Recipe', (
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

    final formRecipeNavItem = find.text('Form & Async Validation');
    expect(formRecipeNavItem, findsWidgets);
    await tester.tap(formRecipeNavItem.first);
    await tester.pumpAndSettle();

    expect(
      find.text('Recipe 1: Form Lifecycle & Async Validation'),
      findsOneWidget,
    );
    expect(find.text('Resident Nickname'), findsOneWidget);
  });

  testWidgets('Gallery Navigation: navigates to Provenance View', (
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

    // Route to /provenance
    final provenanceItem = find.text('Build Provenance');
    expect(provenanceItem, findsOneWidget);
    await tester.tap(provenanceItem);
    await tester.pumpAndSettle();

    final localizations = GalleryLocalizations.of(
      tester.element(provenanceItem),
    );
    expect(find.text(localizations.provenanceReleaseIdentity), findsOneWidget);
    // Widget tests run unstamped builds, which must say so.
    expect(find.text(localizations.provenanceUnavailable), findsOneWidget);
  });
}

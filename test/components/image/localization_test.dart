import 'dart:convert';
import 'dart:typed_data';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets(
    'C35 open image preview semantics update with the mounted locale',
    (tester) async {
      final controller = LocalizationTestController();
      addTearDown(controller.dispose);
      final image = MemoryImage(
        Uint8List.fromList(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADUlEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
          ),
        ),
      );
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Scaffold(
            body: Row(
              children: [
                AnimalImage(
                  image: image,
                  width: 100,
                  height: 100,
                  preview: true,
                ),
                AnimalImage(
                  image: image,
                  width: 100,
                  height: 100,
                  preview: true,
                  semanticLabel: 'Portrait',
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Preview image'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Portrait, click to preview'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Portrait, click to preview'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Close preview'), findsOneWidget);
      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      expect(find.bySemanticsLabel('Image preview'), findsOneWidget);

      controller.locale = const Locale('zh');
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('关闭预览'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭'), findsOneWidget);
      expect(find.bySemanticsLabel('图片预览'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('关闭预览'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('预览图片'), findsOneWidget);
      expect(find.bySemanticsLabel('Portrait，点击预览'), findsOneWidget);
    },
  );
}

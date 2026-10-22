import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show host, foreground, fill, readable;

void main() => registerOwnedSurfaceContrastTests();

void registerOwnedSurfaceContrastTests() {
  testWidgets(
    'CodeBlock every owned syntax token remains readable on default backing',
    (t) async {
      const code =
          "// necessary comment\n/* block comment */\nfinal value = Type('string', 12);\nflutter pub get";
      for (final brightness in Brightness.values) {
        for (final language in IslandCodeLanguage.values) {
          await t.pumpWidget(
            host(
              SizedBox(
                width: 600,
                child: IslandCodeBlock(code: code, language: language),
              ),
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
          final editable = t
              .state<EditableTextState>(find.byType(EditableText))
              .renderEditable;
          var leaves = 0;
          void inspect(InlineSpan span, TextStyle parent) {
            final style = parent.merge(span.style);
            if (span is TextSpan) {
              if (span.text?.trim().isNotEmpty ?? false) {
                leaves++;
                readable(
                  style.color!,
                  const Color(0xff2b2118),
                  reason: '$brightness $language token=${span.text}',
                );
              }
              for (final child in span.children ?? <InlineSpan>[]) {
                inspect(child, style);
              }
            }
          }

          inspect(editable.text!, const TextStyle());
          expect(leaves, greaterThan(0));
        }
      }
    },
  );

  testWidgets(
    'Carousel fixed pale slide surface supplies readable defaults in dark host',
    (t) async {
      await t.pumpWidget(
        host(
          const SizedBox(
            width: 500,
            child: IslandCarousel<int>(
              value: 1,
              onChanged: null,
              items: [
                IslandSlide(value: 1, child: Center(child: Text('Slide text'))),
              ],
            ),
          ),
          brightness: Brightness.dark,
        ),
      );
      await t.pumpAndSettle();
      expect(fill(t, find.text('Slide text')), const Color(0xfff7f3df));
      readable(foreground(t, 'Slide text'), fill(t, find.text('Slide text')));
    },
  );
}

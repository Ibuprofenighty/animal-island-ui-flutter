import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Title palette and theme changes keep borrowed editing focus explicit ink and one child',
    (t) async {
      for (final variant in IslandTitleVariant.values) {
        for (final size in IslandSize.values) {
          final controller = TextEditingController(text: 'retain state'),
              focus = FocusNode();
          final key = GlobalKey();
          late StateSetter change;
          var palette = IslandPalette.brown;
          var brightness = Brightness.light;
          Color? passive, semantic;
          var edits = 0;
          await t.pumpWidget(
            StatefulBuilder(
              builder: (_, set) {
                change = set;
                return MaterialApp(
                  theme: IslandTheme.create(brightness: brightness),
                  home: Scaffold(
                    body: Center(
                      child: IslandTitle(
                        variant: variant,
                        size: size,
                        palette: palette,
                        child: Builder(
                          builder: (context) {
                            passive = DefaultTextStyle.of(context).style.color;
                            semantic = IslandTheme.of(context).ink;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Explicit ink',
                                  style: TextStyle(color: Colors.purple),
                                ),
                                SizedBox(
                                  width: 240,
                                  child: TextField(
                                    key: key,
                                    controller: controller,
                                    focusNode: focus,
                                    style: const TextStyle(
                                      color: Colors.purple,
                                    ),
                                    onChanged: (_) => edits++,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
          await t.pumpAndSettle();
          focus.requestFocus();
          await t.pump();
          controller.selection = const TextSelection(
            baseOffset: 2,
            extentOffset: 6,
          );
          await t.pump();
          final editor = t.state<EditableTextState>(find.byType(EditableText));
          for (final next in [
            (IslandPalette.yellowGreen, Brightness.dark),
            (IslandPalette.brown, Brightness.light),
            (IslandPalette.yellowGreen, Brightness.light),
            (IslandPalette.yellowGreen, Brightness.dark),
          ]) {
            change(() {
              palette = next.$1;
              brightness = next.$2;
            });
            for (final ms in [0, 1, 80, 250]) {
              await t.pump(Duration(milliseconds: ms));
              expect(focus.hasPrimaryFocus, isTrue);
              expect(
                t.state<EditableTextState>(find.byType(EditableText)),
                same(editor),
              );
              expect(controller.text, 'retain state');
              expect(
                controller.selection,
                const TextSelection(baseOffset: 2, extentOffset: 6),
              );
              expect(
                t.widget<EditableText>(find.byType(EditableText)).style.color,
                Colors.purple,
              );
              expect(
                (t.renderObject<RenderParagraph>(find.text('Explicit ink')).text
                        as TextSpan)
                    .style!
                    .color,
                Colors.purple,
              );
              expect(
                passive,
                next.$1 == IslandPalette.yellowGreen
                    ? const Color(0xff69563d)
                    : const Color(0xff2a1d0c),
              );
              expect(semantic, passive);
              expect(edits, 0);
            }
          }
          await t.pumpWidget(const SizedBox());
          controller.dispose();
          focus.dispose();
        }
      }
    },
  );
}

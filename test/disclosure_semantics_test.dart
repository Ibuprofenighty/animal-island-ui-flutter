import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <String, Widget>{
    'Disclosure': const IslandCollapse.uncontrolled(
      question: Text('Disclosure'),
      answer: Text('Answer'),
    ),
    'Date trigger': const IslandDatePicker.uncontrolled(label: 'Date trigger'),
    'Time trigger': const IslandTimePicker.uncontrolled(label: 'Time trigger'),
    '10 条/页': const IslandPagination.uncontrolled(
      total: 50,
      showSizeChanger: true,
    ),
  };
  for (final entry in cases.entries) {
    testWidgets('${entry.key} exposes expansion on its named action', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            home: Scaffold(
              body: Align(alignment: Alignment.center, child: entry.value),
            ),
          ),
        );
        int? triggerId;
        ui.Tristate actionExpansion() {
          final nodes = <SemanticsNode>[];
          void visit(SemanticsNode node) {
            final data = node.getSemanticsData();
            if (data.flagsCollection.isButton &&
                data.label.startsWith(entry.key) &&
                (triggerId == null || node.id == triggerId)) {
              nodes.add(node);
            }
            node.visitChildren((child) {
              visit(child);
              return true;
            });
          }

          visit(
            tester
                .binding
                .renderViews
                .single
                .owner!
                .semanticsOwner!
                .rootSemanticsNode!,
          );
          expect(nodes, hasLength(1));
          triggerId ??= nodes.single.id;
          final data = nodes.single.getSemanticsData();
          expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
          return data.flagsCollection.isExpanded;
        }

        expect(actionExpansion(), ui.Tristate.isFalse);
        final action = find.bySemanticsLabel(
          RegExp('^${RegExp.escape(entry.key)}'),
        );
        await tester.tap(action.first);
        await tester.pumpAndSettle();
        expect(actionExpansion(), ui.Tristate.isTrue);
        await tester.tap(action.first);
        await tester.pumpAndSettle();
        expect(actionExpansion(), ui.Tristate.isFalse);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      } finally {
        semantics.dispose();
      }
    });
  }

  for (final date in [true, false]) {
    testWidgets(
      '${date ? 'Date' : 'Time'} picker closes only for an actual external focus target',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final triggerFocus = FocusNode();
        final outsideFocus = FocusNode();
        try {
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('zh'),
              localizationsDelegates: IslandLocalizations.delegates,
              supportedLocales: IslandLocalizations.supportedLocales,
              home: Scaffold(
                body: Row(
                  children: [
                    if (date)
                      IslandDatePicker.uncontrolled(
                        label: 'Picker',
                        focusNode: triggerFocus,
                      )
                    else
                      IslandTimePicker.uncontrolled(
                        label: 'Picker',
                        focusNode: triggerFocus,
                      ),
                    const Spacer(),
                    TextButton(
                      focusNode: outsideFocus,
                      onPressed: () {},
                      child: const Text('Outside'),
                    ),
                  ],
                ),
              ),
            ),
          );
          final trigger = find
              .bySemanticsLabel(RegExp(r'^Picker(?:\n|$)'))
              .first;
          ui.Tristate expansion() => tester
              .getSemantics(trigger)
              .getSemanticsData()
              .flagsCollection
              .isExpanded;
          await tester.tap(trigger);
          await tester.pumpAndSettle();
          expect(expansion(), ui.Tristate.isTrue);
          triggerFocus.unfocus();
          await tester.pumpAndSettle();
          expect(
            expansion(),
            ui.Tristate.isTrue,
            reason: 'A blur without an external target keeps the panel open',
          );
          triggerFocus.requestFocus();
          await tester.pump();
          outsideFocus.requestFocus();
          await tester.pumpAndSettle();
          expect(
            expansion(),
            ui.Tristate.isFalse,
            reason: 'Focus transferred to an external control closes the panel',
          );
          await tester.tap(trigger);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Outside'));
          await tester.pumpAndSettle();
          expect(
            expansion(),
            ui.Tristate.isFalse,
            reason: 'Outside pointer dismissal remains independently effective',
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        } finally {
          triggerFocus.dispose();
          outsideFocus.dispose();
          semantics.dispose();
        }
      },
    );
  }
}

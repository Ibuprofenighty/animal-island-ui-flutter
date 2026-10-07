// N09 oracles for the shared interaction primitives every component reuses:
// the icon action, the field-trigger border and glow rule, and focus return.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/field_status.dart';
import 'package:animal_island_ui/src/internal/interaction/focus_return.dart';
import 'package:animal_island_ui/src/internal/interaction/icon_action.dart';
import 'package:animal_island_ui/src/internal/interaction/focus_ring.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _idle = Color(0xFF000001);
const Color _hover = Color(0xFF000002);

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AnimalIslandTheme.light.toThemeData(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

Widget _action(VoidCallback onPressed) => AnimalIconAction(
  onPressed: onPressed,
  semanticLabel: 'Close sample',
  padding: const EdgeInsets.all(2),
  borderRadius: const BorderRadius.all(Radius.circular(4)),
  backgroundColor: resolveIconActionBackground(
    null,
    idle: _idle,
    hovered: _hover,
  ),
  icon: const SizedBox.square(dimension: 10),
);

/// The fill: the innermost animated container; the outer one belongs to the
/// activation region.
AnimatedContainer _fill(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(AnimalIconAction),
        matching: find.byType(AnimatedContainer),
      ),
    )
    .last;

Color? _fillColor(WidgetTester tester) =>
    (_fill(tester).decoration! as BoxDecoration).color;

void main() {
  group('N09 shared controls', () {
    testWidgets('an icon action has a 48dp target, one labelled action and a '
        'hover fill', (tester) async {
      int presses = 0;
      await tester.pumpWidget(_app(_action(() => presses++)));
      final Size target = tester.getSize(
        find
            .descendant(
              of: find.byType(AnimalIconAction),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      expect(find.bySemanticsLabel('Close sample'), findsOneWidget);
      expect(_fillColor(tester), _idle);

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(AnimalIconAction)));
      await tester.pumpAndSettle();
      expect(_fillColor(tester), _hover);

      await tester.tap(find.byType(AnimalIconAction));
      expect(presses, 1);
    });

    testWidgets('an icon action changes its fill at once with reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_action(() {}), reduceMotion: true));
      expect(_fill(tester).duration, Duration.zero);
      await tester.pumpWidget(_app(_action(() {})));
      expect(_fill(tester).duration, AnimalIslandTheme.light.motion.fast);
    });

    test('a styled icon action fill wins over the defaults per state', () {
      final WidgetStateProperty<Color> fill = resolveIconActionBackground(
        WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? const Color(0xFF0000AA)
              : null,
        ),
        idle: _idle,
        hovered: _hover,
      );
      expect(fill.resolve(<WidgetState>{}), _idle);
      expect(
        fill.resolve(<WidgetState>{WidgetState.hovered}),
        const Color(0xFF0000AA),
      );
    });

    test('field triggers share one border and glow precedence', () {
      final AnimalIslandTheme theme = AnimalIslandTheme.light;
      final colors = theme.colors;
      AnimalFieldTriggerStatus status(
        Set<WidgetState> states, {
        bool warning = false,
        WidgetStateProperty<Color?>? border,
        Color? warningColor,
        WidgetStateProperty<Color?>? glow,
      }) => resolveFieldTriggerStatus(
        theme: theme,
        states: states,
        warning: warning,
        borderColor: border,
        warningColor: warningColor,
        glowColor: glow,
      );

      // Idle: theme border, no glow.
      expect(status(<WidgetState>{}).border, colors.border);
      expect(status(<WidgetState>{}).glow, isNull);

      // Focus: focus-ring color with a 45% glow.
      final focused = status(<WidgetState>{WidgetState.focused});
      expect(focused.border, resolveFocusRing(theme).color);
      expect(focused.glow!.color, focused.border.withValues(alpha: 0.45));
      expect(focused.glow!.blurRadius, 4);
      expect(focused.glow!.spreadRadius, 2);

      // Error wins over focus and warning, with a 35% glow.
      final error = status(<WidgetState>{
        WidgetState.focused,
        WidgetState.error,
      }, warning: true);
      expect(error.border, colors.errorText);
      expect(error.glow!.color, colors.errorText.withValues(alpha: 0.35));

      // Warning wins over a styled border.
      final warning = status(
        <WidgetState>{},
        warning: true,
        border: const WidgetStatePropertyAll<Color?>(Color(0xFF123456)),
      );
      expect(warning.border, colors.warningText);
      expect(
        status(
          <WidgetState>{},
          warning: true,
          warningColor: const Color(0xFF654321),
        ).border,
        const Color(0xFF654321),
      );

      // Disabled: styled or theme disabled border and never a glow.
      final disabled = status(<WidgetState>{
        WidgetState.disabled,
        WidgetState.focused,
        WidgetState.error,
      });
      expect(disabled.border, colors.borderLight);
      expect(disabled.glow, isNull);

      // A styled glow color resolves against the same states.
      expect(
        status(
          <WidgetState>{WidgetState.focused},
          glow: const WidgetStatePropertyAll<Color?>(Color(0xFF00FF00)),
        ).glow!.color,
        const Color(0xFF00FF00),
      );
    });

    testWidgets('focus returns after the closing frame and skips a control '
        'that is gone', (tester) async {
      final FocusNode opener = FocusNode();
      addTearDown(opener.dispose);
      await tester.pumpWidget(
        _app(Focus(focusNode: opener, child: const SizedBox(width: 10))),
      );
      opener.requestFocus();
      await tester.pump();
      final AnimalFocusReturn focusReturn = AnimalFocusReturn.capture();

      final FocusNode other = FocusNode();
      addTearDown(other.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              Focus(focusNode: opener, child: const SizedBox(width: 10)),
              Focus(focusNode: other, child: const SizedBox(width: 10)),
            ],
          ),
        ),
      );
      other.requestFocus();
      await tester.pump();
      focusReturn.restore();
      expect(other.hasFocus, isTrue, reason: 'restored after the frame');
      await tester.pump();
      expect(opener.hasFocus, isTrue);

      // A second restore and a restore to an unmounted control do nothing.
      other.requestFocus();
      await tester.pump();
      focusReturn.restore();
      await tester.pump();
      expect(other.hasFocus, isTrue);

      final AnimalFocusReturn gone = AnimalFocusReturn.capture();
      await tester.pumpWidget(_app(const SizedBox()));
      gone.restore();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}

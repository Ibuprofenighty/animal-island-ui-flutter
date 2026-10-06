// API06 shared oracles: robustness of every delivered component under
// boundary-valid themes, and the static ban on theme null assertions.
//
// Component-specific efficacy and precedence oracles live beside each
// component in test/components/<slug>/customization_test.dart.
import 'dart:io';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A delivered component rendered with only its required inputs.
///
/// Add an entry when a component's owning task delivers it; the robustness
/// oracle then covers it under every boundary theme.
typedef _Subject = ({String name, Widget Function() build});

final List<_Subject> _deliveredComponents = <_Subject>[
  (
    name: 'AnimalInput',
    build: () => _Owned<TextEditingController>(
      create: () => TextEditingController(text: 'Island text'),
      dispose: (controller) => controller.dispose(),
      builder: (controller) => AnimalInput(
        controller: controller,
        placeholder: 'Placeholder',
        clearable: true,
        prefix: const Text('Prefix'),
        suffix: const Text('Suffix'),
      ),
    ),
  ),
  for (final AnimalInputSize size in AnimalInputSize.values)
    (
      name: 'AnimalInput ${size.name}',
      build: () => _Owned<TextEditingController>(
        create: TextEditingController.new,
        dispose: (controller) => controller.dispose(),
        builder: (controller) => AnimalInput(
          controller: controller,
          size: size,
          placeholder: 'Placeholder',
        ),
      ),
    ),
  (
    name: 'AnimalSwitch',
    build: () => AnimalSwitch(value: true, onChanged: (_) {}),
  ),
  (
    name: 'AnimalCheckbox',
    build: () => AnimalCheckbox(
      value: true,
      onChanged: (_) {},
      label: const Text('Checkbox label'),
    ),
  ),
  (
    name: 'AnimalRadio',
    build: () => AnimalRadio<int>(
      value: 1,
      groupValue: 1,
      onChanged: (_) {},
      label: const Text('Radio label'),
    ),
  ),
  (
    name: 'AnimalSelect',
    build: () => AnimalSelect<int>(
      value: 1,
      options: const <AnimalOption<int>>[
        AnimalOption<int>(value: 1, label: 'First option'),
        AnimalOption<int>(value: 2, label: 'Second option'),
      ],
      onChanged: (_) {},
    ),
  ),
  (
    name: 'AnimalDatePicker',
    build: () => AnimalDatePicker(
      selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
      onChanged: (_) {},
    ),
  ),
  (
    name: 'AnimalTimePicker',
    build: () => AnimalTimePicker(
      value: AnimalTimeValue(hour: 9, minute: 30, second: 15),
      format: 'HH:mm:ss',
      onChanged: (_) {},
    ),
  ),
  (
    name: 'AnimalFormItem',
    build: () => AnimalForm(
      child: AnimalFormItem<String>(
        fieldKey: AnimalFieldKey<String>(debugLabel: 'email'),
        label: 'Email address',
        help: 'Use an island email format',
        required: true,
        builder: (context, binding) => const SizedBox(height: 24),
      ),
    ),
  ),
];

/// Boundary-valid themes every delivered component must render under.
List<
  ({
    String name,
    AnimalIslandTheme theme,
    TextDirection direction,
    double textScale,
  })
>
_boundaryThemes() {
  final AnimalIslandTheme light = AnimalIslandTheme.light;
  AnimalThemeSpacing uniformSpacing(double value) => AnimalThemeSpacing(
    xxs: value,
    xs: value,
    sm: value,
    md: value,
    lg: value,
    xl: value,
    xxl: value,
  );
  AnimalThemeTypography uniformType(double size) {
    final AnimalThemeTypography t = light.typography;
    TextStyle sized(TextStyle style) => style.copyWith(fontSize: size);
    return t.copyWith(
      title: sized(t.title),
      heading: sized(t.heading),
      subheading: sized(t.subheading),
      button: sized(t.button),
      body: sized(t.body),
      secondary: sized(t.secondary),
      caption: sized(t.caption),
      code: sized(t.code),
      countdown: sized(t.countdown),
      digitLarge: sized(t.digitLarge),
    );
  }

  final AnimalThemeSpacing s = light.spacing;
  return <
    ({
      String name,
      AnimalIslandTheme theme,
      TextDirection direction,
      double textScale,
    })
  >[
    (
      name: 'spacing all zero',
      theme: light.copyWith(spacing: uniformSpacing(0)),
      direction: TextDirection.ltr,
      textScale: 1,
    ),
    (
      name: 'spacing all equal',
      theme: light.copyWith(spacing: uniformSpacing(s.sm)),
      direction: TextDirection.ltr,
      textScale: 1,
    ),
    (
      name: 'spacing tripled',
      theme: light.copyWith(
        spacing: AnimalThemeSpacing(
          xxs: s.xxs * 3,
          xs: s.xs * 3,
          sm: s.sm * 3,
          md: s.md * 3,
          lg: s.lg * 3,
          xl: s.xl * 3,
          xxl: s.xxl * 3,
        ),
      ),
      direction: TextDirection.ltr,
      textScale: 1,
    ),
    (
      name: 'all type roles 10',
      theme: light.copyWith(typography: uniformType(10)),
      direction: TextDirection.ltr,
      textScale: 1,
    ),
    (
      name: 'all type roles 32',
      theme: light.copyWith(typography: uniformType(32)),
      direction: TextDirection.ltr,
      textScale: 1,
    ),
    (
      name: 'substituted font family',
      theme: light.copyWith(
        typography: light.typography.copyWith(
          fontFamily: 'packages/animal_island_ui/Noto Sans SC',
          fontFamilyFallback: const <String>[
            'packages/animal_island_ui/Nunito',
          ],
        ),
      ),
      direction: TextDirection.ltr,
      textScale: 1,
    ),
    (
      name: '200% text scale',
      theme: light,
      direction: TextDirection.ltr,
      textScale: 2,
    ),
    (
      name: 'right to left',
      theme: light,
      direction: TextDirection.rtl,
      textScale: 1,
    ),
    (
      name: 'dark',
      theme: AnimalIslandTheme.dark,
      direction: TextDirection.ltr,
      textScale: 1,
    ),
  ];
}

void main() {
  group('API06 robustness: delivered components at 320 logical pixels', () {
    for (final variant in _boundaryThemes()) {
      for (final _Subject subject in _deliveredComponents) {
        testWidgets('${subject.name} under ${variant.name}', (tester) async {
          tester.view.physicalSize = const Size(320, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: variant.theme.toThemeData(),
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(variant.textScale)),
                  child: Directionality(
                    textDirection: variant.direction,
                    child: Scaffold(
                      body: SingleChildScrollView(
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: subject.build(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 1));

          expect(
            tester.takeException(),
            isNull,
            reason:
                '${subject.name} must render without an exception, negative '
                'constraint or overflow under ${variant.name}',
          );
        });
      }
    }
  });

  test('API06 static: lib/ applies no null assertion to theme values', () {
    // A theme role or token read followed by `!`, for example
    // `theme.typography.body.fontSize!`. Theme constructors guarantee these
    // values, so components scale them with `TextStyle.apply` instead.
    final RegExp themeAssertion = RegExp(
      r'\b(?:theme|typography|spacing|radii|colors|shadows|motion)'
      r'(?:\.\w+)+!(?!=)',
    );
    final List<String> offenders = <String>[];
    for (final FileSystemEntity entity in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final List<String> lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final String line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (themeAssertion.hasMatch(line)) {
          offenders.add('${entity.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}

/// Creates a disposable resource for a subject and releases it on unmount.
class _Owned<T> extends StatefulWidget {
  const _Owned({
    required this.create,
    required this.dispose,
    required this.builder,
  });

  final T Function() create;
  final void Function(T value) dispose;
  final Widget Function(T value) builder;

  @override
  State<_Owned<T>> createState() => _OwnedState<T>();
}

class _OwnedState<T> extends State<_Owned<T>> {
  late final T _value = widget.create();

  @override
  void dispose() {
    widget.dispose(_value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_value);
}

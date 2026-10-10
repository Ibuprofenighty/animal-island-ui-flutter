import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders a fresh consumer and observes native widgets' painted/layout inputs.
/// The projection excludes component fields and resolver objects so a style
/// must reach a visible surface, typography, geometry or transition to differ.
Future<List<String>> customizationProjection(
  WidgetTester tester,
  Widget child, {
  AnimalIslandTheme? theme,
  bool press = false,
  double width = 800,
  bool advanceCarousel = false,
}) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, height: 500, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  if (advanceCarousel) {
    await tester.tap(find.bySemanticsLabel('Next slide'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  final gesture = press
      ? await tester.startGesture(
          tester.getCenter(find.bySemanticsLabel('Next page')),
        )
      : null;
  if (gesture != null) await tester.pump(const Duration(seconds: 1));
  final result = [
    for (final widget in tester.allWidgets)
      switch (widget) {
        Container() =>
          'container ${widget.color} ${widget.decoration} ${widget.padding} ${widget.constraints}',
        AnimatedContainer() =>
          'animated ${widget.decoration} ${widget.padding} ${widget.constraints} ${widget.duration} ${widget.curve}',
        DefaultTextStyle() => 'text ${widget.style}',
        Text() => 'label ${widget.data} ${widget.style}',
        Icon() => 'icon ${widget.size} ${widget.color}',
        IconTheme() => 'iconTheme ${widget.data}',
        SizedBox() => 'box ${widget.width} ${widget.height}',
        Padding() => 'padding ${widget.padding}',
        Transform() => 'transform ${widget.transform}',
        ClipRRect() => 'clip ${widget.borderRadius}',
        PageView() => advanceCarousel ? 'page ${widget.controller!.page}' : '',
        AnimatedPositioned() =>
          'position ${widget.left} ${widget.top} ${widget.width} ${widget.height} ${widget.duration} ${widget.curve}',
        PositionedDirectional() =>
          'position ${widget.start} ${widget.end} ${widget.bottom}',
        AnimatedSize() => 'size ${widget.duration} ${widget.curve}',
        AnimatedRotation() => 'rotation ${widget.duration} ${widget.curve}',
        _ => '',
      },
  ].where((value) => value.isNotEmpty).toList();
  await gesture?.cancel();
  if (advanceCarousel) await tester.pumpAndSettle();
  return result;
}

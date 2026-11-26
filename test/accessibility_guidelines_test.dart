import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _a11yHost(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: IslandLocalizations.delegates,
    supportedLocales: IslandLocalizations.supportedLocales,
    theme: IslandTheme.create(brightness: brightness),
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: appChild!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'core interactive components satisfy Flutter labeledTapTargetGuideline',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _a11yHost(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                IslandButton(
                  variant: IslandButtonVariant.primary,
                  onPressed: () {},
                  child: const Text('Save'),
                ),
                IslandIconButton(
                  glyph: IslandGlyph.search,
                  label: 'Search items',
                  onPressed: () {},
                ),
                IslandCheckbox(
                  value: true,
                  onChanged: (_) {},
                  label: 'Accept terms',
                ),
                IslandSwitch(
                  value: true,
                  onChanged: (_) {},
                  label: 'Enable notifications',
                ),
                IslandTextField(
                  label: 'Island name',
                  hint: 'Enter name',
                  onChanged: (_) {},
                ),
                IslandTag(onClose: () {}, child: const Text('Cozy')),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'key components reflow cleanly at 2.0x text scale without layout overflow',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _a11yHost(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              IslandForm(
                children: [
                  IslandFormItem(
                    label: 'Resident nickname with longer label text',
                    required: true,
                    child: IslandTextField(
                      label: 'Nickname',
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              IslandPagination(
                total: 100,
                value: const IslandPaginationValue(page: 2, pageSize: 10),
                showQuickJumper: true,
                onChanged: (_) {},
              ),
              const IslandCodeBlock(
                code: 'final greeting = "hello";',
                language: IslandCodeLanguage.dart,
              ),
              SizedBox(
                height: 180,
                child: IslandCarousel<String>(
                  value: 'one',
                  autoplay: true,
                  items: const [
                    IslandSlide(value: 'one', child: Text('First slide')),
                    IslandSlide(value: 'two', child: Text('Second slide')),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          textScaler: const TextScaler.linear(2.0),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

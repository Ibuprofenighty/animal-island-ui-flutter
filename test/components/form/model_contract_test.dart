import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('Typed form model', () {
    test('opaque key identity is object-owned and generations reject stale removal', () {
      final firstKey = AnimalFieldKey<String>(debugLabel: 'same-label');
      final otherKey = AnimalFieldKey<String>(debugLabel: 'same-label');
      final controller = AnimalFormController();

      final first = controller.registerField<String>(
        key: firstKey,
        initialValue: 'first',
      );
      final other = controller.registerField<String>(
        key: otherKey,
        initialValue: 'other',
      );
      expect(firstKey, isNot(otherKey));
      expect(first.generation, lessThan(other.generation));
      expect(
        () => controller.registerField<String>(key: firstKey),
        throwsStateError,
      );

      first.deactivate();
      final replacement = controller.registerField<String>(
        key: firstKey,
        initialValue: 'replacement',
      );
      expect(replacement.generation, greaterThan(first.generation));
      controller.unregisterField(first);
      expect(controller.valueFor(firstKey), 'replacement');

      controller.unregisterField(other);
      controller.unregisterField(replacement);
      controller.dispose();
    });

    testWidgets(
      'owner key and baseline survive rebuild and GlobalKey reparent; remount advances generation',
      (tester) async {
        final key = AnimalFieldKey<String>(debugLabel: 'stable-owner-key');
        final controller = AnimalFormController();
        var initialValue = 'first baseline';
        Key itemMountKey = GlobalKey();
        var moveField = false;
        var showField = true;
        var generation = 0;
        late StateSetter rebuildParent;

        Widget field() => AnimalFormItem<String>(
          key: itemMountKey,
          fieldKey: key,
          initialValue: 'item fallback',
          builder: (context, binding) {
            generation = binding.generation;
            return Text(binding.value ?? 'null');
          },
        );

        Widget buildTree() => MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              rebuildParent = setState;
              return Scaffold(
                body: AnimalForm(
                  controller: controller,
                  initialValues: AnimalFormValues.fromEntries([
                    AnimalFieldValue(key, initialValue),
                  ]),
                  child: Row(
                    children: moveField
                        ? [const SizedBox.shrink(), if (showField) field()]
                        : [if (showField) field(), const SizedBox.shrink()],
                  ),
                ),
              );
            },
          ),
        );

        await tester.pumpWidget(buildTree());
        final firstGeneration = generation;
        expect(controller.valueFor(key), 'first baseline');

        controller.setValue(key, 'edited', validate: false);
        await tester.pump();
        initialValue = 'replacement initial value';
        rebuildParent(() {});
        await tester.pump();

        expect(generation, firstGeneration);
        expect(controller.valueFor(key), 'edited');
        expect(controller.isDirty, isTrue);
        controller.setValue(key, 'edited across reparent', validate: false);
        await tester.pump();

        moveField = true;
        rebuildParent(() {});
        await tester.pump();
        expect(generation, firstGeneration);
        expect(controller.valueFor(key), 'edited across reparent');
        expect(controller.isDirty, isTrue);

        controller.setValue(key, 'first baseline', validate: false);
        expect(controller.isDirty, isFalse);

        showField = false;
        rebuildParent(() {});
        await tester.pump();
        expect(controller.valueFor(key), isNull);

        itemMountKey = const ValueKey<int>(1);
        showField = true;
        rebuildParent(() {});
        await tester.pump();
        expect(generation, greaterThan(firstGeneration));
        expect(controller.valueFor(key), 'replacement initial value');
        expect(controller.isDirty, isFalse);

        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );

    test('key instance rejects values after generic widening', () {
      final key = AnimalFieldKey<String>(debugLabel: 'widened');
      final AnimalFieldKey<dynamic> widenedKey = key;
      final controller = AnimalFormController();

      expect(
        () => controller.registerField<dynamic>(
          key: widenedKey,
          initialValue: 42,
        ),
        throwsStateError,
      );
      expect(
        () => AnimalFormValues.fromEntries([
          AnimalFieldValue<dynamic>(widenedKey, 42),
        ]),
        throwsStateError,
      );

      final registration = controller.registerField<String>(key: key);
      expect(
        () => controller.setValue<dynamic>(widenedKey, 42),
        throwsStateError,
      );
      expect(controller.valueFor(key), isNull);
      controller.unregisterField(registration);
      controller.dispose();
    });

    test(
      'List<String> snapshots retain type and isolate source and output',
      () {
        final key = AnimalFieldKey.list<String>(debugLabel: 'items');
        final setKey = AnimalFieldKey.set<String>(debugLabel: 'tags');
        final mapKey = AnimalFieldKey.map<String, int>(debugLabel: 'counts');
        final source = <String>['shore'];
        final setSource = <String>{'shell'};
        final mapSource = <String, int>{'island': 2};
        final controller = AnimalFormController();
        controller.registerField<List<String>>(key: key, initialValue: source);
        controller.registerField<Set<String>>(
          key: setKey,
          initialValue: setSource,
        );
        controller.registerField<Map<String, int>>(
          key: mapKey,
          initialValue: mapSource,
        );

        source.add('mutable source');
        setSource.add('mutable set');
        mapSource['island'] = 9;
        final value = controller.valueFor(key)!;
        expect(value, isA<List<String>>());
        expect(value, ['shore']);
        expect(() => value.add('mutable result'), throwsUnsupportedError);
        expect(controller.values.valueFor(key), ['shore']);
        expect(controller.valueFor(setKey), isA<Set<String>>());
        expect(controller.valueFor(setKey), {'shell'});
        expect(
          () => controller.valueFor(setKey)!.add('mutable result'),
          throwsUnsupportedError,
        );
        expect(controller.valueFor(mapKey), isA<Map<String, int>>());
        expect(controller.valueFor(mapKey), {'island': 2});
        expect(
          () => controller.valueFor(mapKey)!['other'] = 3,
          throwsUnsupportedError,
        );
        controller.dispose();
      },
    );

    test('nested map values need an explicit deep typed snapshot', () {
      final rejectedKey = AnimalFieldKey.map<String, List<int>>(
        debugLabel: 'shallow-map',
      );
      final controller = AnimalFormController();
      expect(
        () => controller.registerField<Map<String, List<int>>>(
          key: rejectedKey,
          initialValue: <String, List<int>>{
            'points': <int>[1, 2],
          },
        ),
        throwsStateError,
      );

      final key = AnimalFieldKey.withSnapshot<Map<String, List<int>>>(
        debugLabel: 'deep-map',
        snapshot: (value) => value == null
            ? null
            : Map<String, List<int>>.unmodifiable({
                for (final entry in value.entries)
                  entry.key: List<int>.unmodifiable(entry.value),
              }),
      );
      final source = <String, List<int>>{
        'points': <int>[1, 2],
      };
      controller.registerField<Map<String, List<int>>>(
        key: key,
        initialValue: source,
      );

      source['points']!.add(3);
      final value = controller.values.valueFor(key)!;
      expect(value, isA<Map<String, List<int>>>());
      expect(value['points'], [1, 2]);
      expect(() => value['points']!.add(4), throwsUnsupportedError);
      expect(() => value['new'] = <int>[5], throwsUnsupportedError);
      expect(controller.isDirty, isFalse);
      controller.setValue(key, <String, List<int>>{
        'points': <int>[1, 2],
      }, validate: false);
      expect(controller.isDirty, isFalse);
      controller.dispose();
    });

    test(
      'binding exposes the owner snapshot and reset restores field baseline',
      () async {
        final key = AnimalFieldKey<String>(debugLabel: 'nickname');
        final focusNode = FocusNode();
        final controller = AnimalFormController();
        final registration = controller.registerField<String>(
          key: key,
          initialValue: 'islander',
          rules: [AnimalRule<String>.required()],
          focusNode: focusNode,
        );

        var binding = controller.bindingFor(registration);
        expect(binding.value, 'islander');
        expect(binding.dirty, isFalse);
        expect(binding.touched, isFalse);
        expect(binding.status, AnimalValidationStatus.idle);

        binding.onChanged('new name');
        expect(controller.bindingFor(registration).dirty, isTrue);
        binding.onBlur();
        binding = controller.bindingFor(registration);
        expect(binding.touched, isTrue);
        expect(binding.value, 'new name');

        binding.onChanged('islander');
        expect(controller.bindingFor(registration).dirty, isFalse);
        binding.onChanged(null);
        expect(await controller.validateField(key), isFalse);
        expect(controller.getFieldStatus(key), AnimalValidationStatus.invalid);
        expect(controller.getFieldError(key), isNotNull);

        controller.reset();
        binding = controller.bindingFor(registration);
        expect(binding.value, 'islander');
        expect(binding.dirty, isFalse);
        expect(binding.touched, isFalse);
        expect(binding.error, isNull);
        expect(binding.status, AnimalValidationStatus.idle);

        controller.unregisterField(registration);
        controller.dispose();
        focusNode.dispose();
      },
    );

    testWidgets(
      'typed scope feeds initial values to the live binding and submit snapshot',
      (tester) async {
        final key = AnimalFieldKey<String>(debugLabel: 'scope-value');
        final initialValues = AnimalFormValues.fromEntries([
          AnimalFieldValue(key, 'from form'),
        ]);
        final controller = AnimalFormController();
        String? submittedValue;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                initialValues: initialValues,
                onSubmit: (values) {
                  submittedValue = values.valueFor(key);
                },
                child: AnimalFormItem<String>(
                  fieldKey: key,
                  initialValue: 'from item',
                  builder: (context, binding) => Text(binding.value ?? 'null'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('from form'), findsOneWidget);
        expect(controller.valueFor(key), 'from form');
        expect((await controller.submit()).isSuccess, isTrue);
        expect(submittedValue, 'from form');

        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/form/form_controller.dart'
    show AnimalFormFieldProtocol;

void main() {
  group('Typed form model', () {
    test(
      'validation rules compare immutable configuration and callback identity',
      () {
        String? validator(String? value) =>
            value?.isEmpty == true ? 'empty' : null;
        String? otherValidator(String? value) =>
            value == null ? 'missing' : null;
        final firstCustom = AnimalRule<String>.custom(validator);
        final sameCustom = AnimalRule<String>.custom(validator);
        final differentCustom = AnimalRule<String>.custom(otherValidator);

        expect(AnimalRule<String>.required(), AnimalRule<String>.required());
        expect(
          AnimalRule<String>.pattern(RegExp('a+', caseSensitive: false)),
          AnimalRule<String>.pattern(RegExp('a+', caseSensitive: false)),
        );
        expect(firstCustom, sameCustom);
        expect(firstCustom.hashCode, sameCustom.hashCode);
        expect(firstCustom, isNot(differentCustom));
        expect(AnimalRule<String>.min(2), isNot(AnimalRule<String>.min(3)));
      },
    );

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
        ValueChanged<String?>? latestOnChanged;
        late StateSetter rebuildParent;

        Widget field() => AnimalFormItem<String>(
          key: itemMountKey,
          fieldKey: key,
          initialValue: 'item fallback',
          builder: (context, binding) {
            latestOnChanged = binding.onChanged;
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
        // The first registration's callback; it stays valid until a remount.
        final ValueChanged<String?> firstOnChanged = latestOnChanged!;
        expect(controller.valueFor(key), 'first baseline');

        controller.setValue(key, 'edited', validate: false);
        await tester.pump();
        initialValue = 'replacement initial value';
        rebuildParent(() {});
        await tester.pump();

        expect(() => firstOnChanged('edited'), returnsNormally);
        expect(controller.valueFor(key), 'edited');
        expect(controller.isDirty, isTrue);
        controller.setValue(key, 'edited across reparent', validate: false);
        await tester.pump();

        moveField = true;
        rebuildParent(() {});
        await tester.pump();
        expect(() => firstOnChanged('edited across reparent'), returnsNormally);
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
        expect(() => firstOnChanged('stale'), throwsStateError);
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
                  return true;
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
        expect(
          (await controller.submit()).status == AnimalSubmitStatus.success,
          isTrue,
        );
        expect(submittedValue, 'from form');

        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );

    // A text listener disposes the controller while [operation] writes text.
    void expectSettlesWhenListenerDisposes(
      void Function(AnimalFormController controller) operation,
    ) {
      final key = AnimalFieldKey<String>(debugLabel: 'reentrant');
      final text = TextEditingController(text: 'initial');
      final controller = AnimalFormController();
      controller.registerTextField(key: key, textController: text);
      text.text = 'edited';
      var disposeOnChange = true;
      text.addListener(() {
        if (disposeOnChange) {
          disposeOnChange = false;
          controller.dispose();
        }
      });
      expect(() => operation(controller), returnsNormally);
      expect(controller.values.isEmpty, isTrue);
      text.dispose();
    }

    test('reset settles without effect when a text listener disposes the controller', () {
      expectSettlesWhenListenerDisposes((controller) => controller.reset());
    });

    test('clear settles without effect when a text listener disposes the controller', () {
      expectSettlesWhenListenerDisposes((controller) => controller.clear());
    });

    test('reset leaves later text controllers untouched once a listener disposes the form', () {
      final first = TextEditingController(text: 'a');
      final second = TextEditingController(text: 'b');
      final controller = AnimalFormController();
      controller.registerTextField(
        key: AnimalFieldKey<String>(debugLabel: 'first'),
        textController: first,
      );
      controller.registerTextField(
        key: AnimalFieldKey<String>(debugLabel: 'second'),
        textController: second,
      );
      first.text = 'a2';
      second.text = 'b2';
      var disposeOnChange = true;
      first.addListener(() {
        if (disposeOnChange) {
          disposeOnChange = false;
          controller.dispose();
        }
      });
      controller.reset();
      expect(second.text, 'b2');
      first.dispose();
      second.dispose();
    });

    test(
      'reset never writes a text controller that a disposing listener released',
      () {
        final first = TextEditingController(text: 'a');
        final second = TextEditingController(text: 'b');
        final controller = AnimalFormController();
        controller.registerTextField(
          key: AnimalFieldKey<String>(debugLabel: 'first'),
          textController: first,
        );
        controller.registerTextField(
          key: AnimalFieldKey<String>(debugLabel: 'second'),
          textController: second,
        );
        first.text = 'a2';
        second.text = 'b2';
        var disposeOnChange = true;
        first.addListener(() {
          if (disposeOnChange) {
            disposeOnChange = false;
            controller.dispose();
            second.dispose();
          }
        });
        expect(controller.reset, returnsNormally);
        first.dispose();
      },
    );

    // Runs [rewrite] while a text listener tries every kind of form work.
    Future<void> expectWorkRefusedDuringRewrite(
      void Function(AnimalFormController controller) rewrite,
    ) async {
      final textKey = AnimalFieldKey<String>(debugLabel: 'text');
      final scalarKey = AnimalFieldKey<String>(debugLabel: 'scalar');
      final text = TextEditingController(text: 'a');
      final focusNode = FocusNode();
      final controller = AnimalFormController();
      controller.registerTextField(key: textKey, textController: text);
      final registration = controller.registerField<String>(
        key: scalarKey,
        initialValue: 'base',
        focusNode: focusNode,
      );
      final binding = controller.bindingFor(registration);
      text.text = 'a2';
      final refused = <String, Object?>{};
      final refusedLater = <String, Future<Object?>>{};
      Object? errorOf(void Function() work) {
        try {
          work();
          return null;
        } catch (error) {
          return error;
        }
      }

      var tryOnChange = true;
      text.addListener(() {
        if (!tryOnChange) return;
        tryOnChange = false;
        refused['setValue'] = errorOf(
          () => controller.setValue(scalarKey, 'x'),
        );
        refused['reset'] = errorOf(controller.reset);
        refused['clear'] = errorOf(controller.clear);
        refused['focusFirstError'] = errorOf(controller.focusFirstError);
        refused['binding write'] = errorOf(() => binding.onChanged('y'));
        refused['binding blur'] = errorOf(binding.onBlur);
        refused['registerField'] = errorOf(
          () => controller.registerField<String>(
            key: AnimalFieldKey<String>(debugLabel: 'late'),
          ),
        );
        refused['registerTextField'] = errorOf(
          () => controller.registerTextField(
            key: AnimalFieldKey<String>(debugLabel: 'late text'),
            textController: TextEditingController(),
          ),
        );
        refused['updateFieldRegistration'] = errorOf(
          () => controller.updateFieldRegistration<String>(
            registration,
            rules: const <AnimalRule<String>>[],
            focusNode: focusNode,
          ),
        );
        refusedLater['validateField'] = controller
            .validateField(scalarKey)
            .then<Object?>((_) => null, onError: (Object error) => error);
        refusedLater['validate'] = controller.validate().then<Object?>(
          (_) => null,
          onError: (Object error) => error,
        );
        refusedLater['submit'] = controller.submit().then<Object?>(
          (_) => null,
          onError: (Object error) => error,
        );
      });
      rewrite(controller);
      for (final MapEntry<String, Future<Object?>> entry
          in refusedLater.entries) {
        refused[entry.key] = await entry.value;
      }
      expect(refused, hasLength(12));
      for (final MapEntry<String, Object?> entry in refused.entries) {
        expect(entry.value, isA<StateError>(), reason: entry.key);
      }
      // Nothing the listener tried took effect.
      expect(controller.getFieldStatus(scalarKey), AnimalValidationStatus.idle);
      expect(controller.isSubmitting, isFalse);
      controller.dispose();
      text.dispose();
      focusNode.dispose();
    }

    test('form work started by a listener while reset or clear writes the fields throws', () async {
      await expectWorkRefusedDuringRewrite((controller) => controller.reset());
      await expectWorkRefusedDuringRewrite((controller) => controller.clear());
    });

    test('a field unregistered by a listener during reset drops out and the form is notified once after the write', () {
      final textKey = AnimalFieldKey<String>(debugLabel: 'text');
      final droppedKey = AnimalFieldKey<String>(debugLabel: 'dropped');
      final keptKey = AnimalFieldKey<String>(debugLabel: 'kept');
      final text = TextEditingController(text: 'a');
      final controller = AnimalFormController();
      controller.registerTextField(key: textKey, textController: text);
      final dropped = controller.registerField<String>(
        key: droppedKey,
        initialValue: 'base',
      );
      controller.registerField<String>(key: keptKey, initialValue: 'base');
      controller.setValue(droppedKey, 'edited', validate: false);
      controller.setValue(keptKey, 'edited', validate: false);
      text.text = 'a2';
      final formSaw = <String?>[];
      controller.addListener(() => formSaw.add(controller.valueFor(keptKey)));
      var unregisterOnChange = true;
      text.addListener(() {
        if (unregisterOnChange) {
          unregisterOnChange = false;
          controller.unregisterField(dropped);
        }
      });
      controller.reset();
      expect(formSaw, <String?>['base']);
      expect(controller.values.length, 2);
      expect(controller.valueFor(droppedKey), isNull);
      controller.dispose();
      text.dispose();
    });

    test('listeners notified after reset see the final state and may start new work', () async {
      final key = AnimalFieldKey<String>(debugLabel: 'notified');
      final text = TextEditingController(text: 'base');
      final controller = AnimalFormController();
      final registration = controller.registerTextField(
        key: key,
        textController: text,
        rules: <AnimalRule<String>>[AnimalRule<String>.required()],
      );
      text.text = 'edited';
      final fieldSaw = <String?>[];
      registration.addListener(() => fieldSaw.add(controller.valueFor(key)));
      Future<AnimalSubmitResult>? submitted;
      controller.addListener(() {
        submitted ??= controller.submit(onSubmit: (_) => true);
      });
      controller.reset();
      expect(fieldSaw.last, 'base');
      expect((await submitted!).status, AnimalSubmitStatus.success);
      controller.dispose();
      text.dispose();
    });

    test(
      'a reset by a form listener during touch discards the touch validation',
      () async {
        final key = AnimalFieldKey<String>(debugLabel: 'touched');
        final focusNode = FocusNode();
        final controller = AnimalFormController();
        final registration = controller.registerField<String>(
          key: key,
          rules: <AnimalRule<String>>[AnimalRule<String>.required()],
          focusNode: focusNode,
        );
        var resetOnChange = true;
        controller.addListener(() {
          if (resetOnChange) {
            resetOnChange = false;
            controller.reset();
          }
        });
        controller.bindingFor(registration).onBlur();
        await Future<void>.delayed(Duration.zero);
        expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
        controller.dispose();
        focusNode.dispose();
      },
    );

    test('after dispose new work throws, teardown is idempotent and reads are empty', () async {
      final key = AnimalFieldKey<String>(debugLabel: 'disposed');
      final controller = AnimalFormController();
      controller.registerField<String>(key: key, initialValue: 'value');
      controller.dispose();
      controller.dispose();

      expect(() => controller.setValue(key, 'x'), throwsStateError);
      await expectLater(controller.validate(), throwsStateError);
      await expectLater(controller.validateField(key), throwsStateError);
      await expectLater(controller.submit(), throwsStateError);
      expect(controller.reset, throwsStateError);
      expect(controller.clear, throwsStateError);
      expect(controller.focusFirstError, throwsStateError);

      expect(controller.valueFor(key), isNull);
      expect(controller.getFieldError(key), isNull);
      expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
      expect(controller.isDirty, isFalse);
      expect(controller.isSubmitting, isFalse);
      expect(controller.values.isEmpty, isTrue);
    });

    test(
      'work in flight when the controller is disposed settles without effect',
      () async {
        final key = AnimalFieldKey<String>(debugLabel: 'in-flight');
        final validation = Completer<String?>();
        final controller = AnimalFormController();
        controller.registerField<String>(
          key: key,
          initialValue: 'value',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) => validation.future),
          ],
        );
        var handlerCalls = 0;
        final Future<AnimalSubmitResult> pending = controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );
        controller.dispose();
        validation.complete(null);
        expect(
          (await pending).status,
          AnimalSubmitStatus.changedDuringValidation,
        );
        expect(handlerCalls, 0);
      },
    );
  });
}

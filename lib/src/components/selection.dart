import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/option.dart';
import '../foundation/size.dart';
import '../internal/choice_control.dart';

void _validate<T>(List<IslandOption<T>> options, double? spacing) {
  if (spacing != null && (!spacing.isFinite || spacing < 0)) {
    throw ArgumentError.value(
      spacing,
      'spacing',
      'Must be finite and nonnegative.',
    );
  }
  if (options.map((e) => e.value).toSet().length != options.length)
    throw ArgumentError('Option values must be unique.');
}

class IslandRadioGroup<T> extends StatelessWidget {
  IslandRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.vertical = false,
    this.size = IslandSize.middle,
    this.spacing,
  }) {
    _validate(options, spacing);
  }
  final List<IslandOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool vertical;
  final IslandSize size;

  /// Gap between options; defaults to 16 horizontally and 12 vertically.
  final double? spacing;
  @override
  Widget build(BuildContext context) => _ChoiceGroup<T>(
    options: options,
    selected: {if (value != null) value as T},
    onToggle: onChanged,
    radio: true,
    vertical: vertical,
    size: size,
    spacing: spacing ?? (vertical ? 12 : 16),
  );
}

class IslandCheckboxGroup<T> extends StatelessWidget {
  IslandCheckboxGroup({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.vertical = false,
    this.size = IslandSize.middle,
    this.spacing,
  }) {
    _validate(options, spacing);
  }
  final List<IslandOption<T>> options;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final bool vertical;
  final IslandSize size;

  /// Gap between options; defaults to 16 horizontally and 12 vertically.
  final double? spacing;
  @override
  Widget build(BuildContext context) => _ChoiceGroup<T>(
    options: options,
    selected: values,
    onToggle: onChanged == null
        ? null
        : (v) {
            final next = Set<T>.of(values);
            if (!next.add(v)) next.remove(v);
            onChanged!(Set.unmodifiable(next));
          },
    radio: false,
    vertical: vertical,
    size: size,
    spacing: spacing ?? (vertical ? 12 : 16),
  );
}

class _ChoiceGroup<T> extends StatefulWidget {
  const _ChoiceGroup({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.radio,
    required this.vertical,
    required this.size,
    required this.spacing,
  });
  final List<IslandOption<T>> options;
  final Set<T> selected;
  final ValueChanged<T>? onToggle;
  final bool radio, vertical;
  final IslandSize size;
  final double spacing;
  @override
  State<_ChoiceGroup<T>> createState() => _ChoiceGroupState<T>();
}

class _ChoiceGroupState<T> extends State<_ChoiceGroup<T>> {
  final _nodes = <T, FocusNode>{};
  void sync() {
    final ids = widget.options.map((e) => e.value).toSet();
    for (final key in _nodes.keys.where((key) => !ids.contains(key)).toList()) {
      _nodes.remove(key)!.dispose();
    }
    for (final id in ids) {
      _nodes.putIfAbsent(id, () => FocusNode());
    }
  }

  @override
  void initState() {
    super.initState();
    sync();
  }

  @override
  void didUpdateWidget(covariant _ChoiceGroup<T> old) {
    super.didUpdateWidget(old);
    sync();
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void move(int delta, {bool edge = false}) {
    if (widget.onToggle == null) return;
    final available = widget.options.where((e) => !e.disabled).toList();
    if (available.isEmpty) return;
    var index = available.indexWhere((e) => _nodes[e.value]!.hasFocus);
    if (edge) {
      index = delta < 0 ? 0 : available.length - 1;
    } else {
      index = (index + delta) % available.length;
    }
    final next = available[index].value;
    _nodes[next]!.requestFocus();
    if (widget.radio) widget.onToggle!(next);
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final items = [
      for (final item in widget.options)
        ChoiceControl(
          key: ValueKey(item.value),
          label: item.label,
          checked: widget.selected.contains(item.value),
          radio: widget.radio,
          size: widget.size,
          focusNode: _nodes[item.value],
          onActivate: widget.onToggle == null || item.disabled
              ? null
              : () => widget.onToggle!(item.value),
        ),
    ];
    return Semantics(
      role: widget.radio ? SemanticsRole.radioGroup : null,
      explicitChildNodes: widget.radio,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              move(rtl ? -1 : 1),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              move(rtl ? 1 : -1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => move(1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => move(-1),
          const SingleActivator(LogicalKeyboardKey.home): () =>
              move(-1, edge: true),
          const SingleActivator(LogicalKeyboardKey.end): () =>
              move(1, edge: true),
        },
        child: widget.vertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        top: i == 0 ? 0 : widget.spacing,
                      ),
                      child: items[i],
                    ),
                ],
              )
            : Wrap(
                spacing: widget.spacing,
                runSpacing: widget.spacing,
                children: items,
              ),
      ),
    );
  }
}

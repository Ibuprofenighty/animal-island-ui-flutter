import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/models/option.dart';

/// Freezes options and rejects duplicate identities at each group boundary.
List<AnimalOption<T>> snapshotUniqueOptions<T>(
  List<AnimalOption<T>> options, {
  required String owner,
}) {
  final List<AnimalOption<T>> snapshot = List<AnimalOption<T>>.unmodifiable(
    options,
  );
  final Set<T> identities = <T>{};
  for (final AnimalOption<T> option in snapshot) {
    if (!identities.add(option.value)) {
      throw ArgumentError.value(
        option.value,
        'options',
        '$owner option values must be unique',
      );
    }
  }
  return snapshot;
}

/// Builds the label of a group option the way Select presents an option: its
/// icon (excluded from semantics) before its text, announced by its
/// [AnimalOption.semanticLabel] when one is given.
Widget optionGroupLabel(
  AnimalOption<dynamic> option, {
  required double iconGap,
}) {
  final Widget? icon = option.icon;
  final Widget content = icon == null
      ? Text(option.label)
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(child: icon),
            SizedBox(width: iconGap),
            Flexible(child: Text(option.label)),
          ],
        );
  final String? semanticLabel = option.semanticLabel;
  return semanticLabel == null
      ? content
      : Semantics(label: semanticLabel, excludeSemantics: true, child: content);
}

/// Builds the item of an option attached to the focus node the group owns.
typedef OptionGroupItemBuilder<T> = Widget Function(
  BuildContext context,
  AnimalOption<T> option,
  FocusNode focusNode,
);

class _OptionGroupFocusNode extends FocusNode {
  FocusOnKeyEventCallback? groupKeyHandler;

  _OptionGroupFocusNode(String identity)
    : super(debugLabel: 'OptionGroupFocus($identity)');
}

/// Forwards [event] to the group navigation of an option focus node created
/// by [OptionGroupFocus]; returns [KeyEventResult.ignored] for any other node.
KeyEventResult optionGroupKeyEvent(FocusNode node, KeyEvent event) {
  if (node is _OptionGroupFocusNode) {
    return node.groupKeyHandler?.call(node, event) ?? KeyEventResult.ignored;
  }
  return KeyEventResult.ignored;
}

/// Owns option-keyed focus identity and group navigation, never selection.
class OptionGroupFocus<T> extends StatefulWidget {
  /// Options of the group, keyed by their values.
  final List<AnimalOption<T>> options;

  /// Layout and arrow-key axis: horizontal wraps items and uses Left/Right
  /// (mirrored in right-to-left text), vertical stacks them and uses
  /// Up/Down. Home and End work on both.
  final Axis direction;

  /// Whether only one item is in the tab order and arrow navigation reports
  /// the newly focused value through [onNavigate].
  final bool roving;

  /// Value of the selected option, focused first when it is enabled.
  final T? selectedValue;

  /// Whether every option is disabled and unfocusable.
  final bool disabled;

  /// Gap between items along [direction]. Defaults to 0.
  final double spacing;

  /// Gap between wrapped runs of a horizontal group. Defaults to 0.
  final double runSpacing;

  /// Group focus node owned by the caller; when it gains focus the group
  /// moves focus to the selected or first enabled option. Null omits the
  /// group focus.
  final FocusNode? focusNode;

  /// Called with the value focused by arrow, Home or End navigation in a
  /// [roving] group.
  final ValueChanged<T>? onNavigate;

  /// Builds each option's item.
  final OptionGroupItemBuilder<T> itemBuilder;

  /// Creates a focus group for [options].
  const OptionGroupFocus({
    super.key,
    required this.options,
    required this.direction,
    required this.roving,
    required this.selectedValue,
    required this.disabled,
    required this.itemBuilder,
    this.spacing = 0,
    this.runSpacing = 0,
    this.focusNode,
    this.onNavigate,
  });

  @override
  State<OptionGroupFocus<T>> createState() => _OptionGroupFocusState<T>();
}

class _OptionGroupFocusState<T> extends State<OptionGroupFocus<T>> {
  final Map<T, FocusNode> _focusNodes = <T, FocusNode>{};
  T? _focusedValue;
  bool _hasFocusedValue = false;

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(covariant OptionGroupFocus<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
    final bool activeValueUnavailable =
        _hasFocusedValue &&
        !widget.options.any(
          (AnimalOption<T> option) =>
              option.value == _focusedValue && _isEnabled(option),
        );
    if (activeValueUnavailable) {
      _hasFocusedValue = false;
      _focusedValue = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final AnimalOption<T>? target = _initialFocusableOption;
        if (target != null) _focusNodes[target.value]?.requestFocus();
      }, debugLabel: 'OptionGroupFocus.replaceUnavailableFocus');
    }
  }

  bool _isEnabled(AnimalOption<T> option) =>
      !widget.disabled && !option.disabled;

  void _syncNodes() {
    final Set<T> retained = widget.options
        .map((AnimalOption<T> option) => option.value)
        .toSet();
    final List<T> removed = _focusNodes.keys
        .where((T identity) => !retained.contains(identity))
        .toList(growable: false);
    for (final T identity in removed) {
      _focusNodes.remove(identity)?.dispose();
    }
    for (final AnimalOption<T> option in widget.options) {
      _focusNodes.putIfAbsent(
        option.value,
        () =>
            _OptionGroupFocusNode('${option.value}')
              ..addListener(() => _handleFocusChanged(option.value)),
      );
    }
  }

  void _handleFocusChanged(T identity) {
    final FocusNode? node = _focusNodes[identity];
    if (!mounted || node == null) return;
    if (!node.hasFocus) {
      if (_hasFocusedValue && _focusedValue == identity) {
        setState(() {
          _hasFocusedValue = false;
          _focusedValue = null;
        });
      }
      return;
    }
    if (!_hasFocusedValue || _focusedValue != identity) {
      setState(() {
        _focusedValue = identity;
        _hasFocusedValue = true;
      });
    }
  }

  AnimalOption<T>? get _initialFocusableOption {
    for (final AnimalOption<T> option in widget.options) {
      if (option.value == widget.selectedValue && _isEnabled(option)) {
        return option;
      }
    }
    for (final AnimalOption<T> option in widget.options) {
      if (_isEnabled(option)) return option;
    }
    return null;
  }

  KeyEventResult _handleKeyEvent(T identity, FocusNode node, KeyEvent event) {
    if (!node.hasFocus ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final List<AnimalOption<T>> enabled = widget.options
        .where(_isEnabled)
        .toList(growable: false);
    if (enabled.isEmpty) return KeyEventResult.ignored;

    int targetIndex = enabled.indexWhere(
      (AnimalOption<T> option) => option.value == identity,
    );
    if (targetIndex < 0) targetIndex = 0;
    final bool reverse =
        widget.direction == Axis.horizontal &&
        Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;
    if (widget.direction == Axis.horizontal) {
      if (key == LogicalKeyboardKey.arrowRight) {
        targetIndex += reverse ? -1 : 1;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        targetIndex += reverse ? 1 : -1;
      } else if (key == LogicalKeyboardKey.home) {
        targetIndex = 0;
      } else if (key == LogicalKeyboardKey.end) {
        targetIndex = enabled.length - 1;
      } else {
        return KeyEventResult.ignored;
      }
    } else {
      if (key == LogicalKeyboardKey.arrowDown) {
        targetIndex++;
      } else if (key == LogicalKeyboardKey.arrowUp) {
        targetIndex--;
      } else if (key == LogicalKeyboardKey.home) {
        targetIndex = 0;
      } else if (key == LogicalKeyboardKey.end) {
        targetIndex = enabled.length - 1;
      } else {
        return KeyEventResult.ignored;
      }
    }
    targetIndex %= enabled.length;
    if (targetIndex < 0) targetIndex += enabled.length;
    final T target = enabled[targetIndex].value;
    _focusNodes[target]?.requestFocus();
    if (target != identity && widget.roving) widget.onNavigate?.call(target);
    return KeyEventResult.handled;
  }

  void _focusFirstEnabled() {
    final AnimalOption<T>? target = _initialFocusableOption;
    if (target != null) _focusNodes[target.value]?.requestFocus();
  }

  @override
  void dispose() {
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimalOption<T>? initial = _initialFocusableOption;
    final T? rovingValue = _hasFocusedValue ? _focusedValue : initial?.value;
    final List<Widget> children = <Widget>[];
    for (final AnimalOption<T> option in widget.options) {
      final bool enabled = _isEnabled(option);
      final FocusNode node = _focusNodes[option.value]!;
      node.canRequestFocus = enabled;
      node.skipTraversal =
          widget.roving && (option.value != rovingValue || !enabled);
      (node as _OptionGroupFocusNode).groupKeyHandler = (
        FocusNode currentNode,
        KeyEvent event,
      ) => _handleKeyEvent(option.value, currentNode, event);
      children.add(
        KeyedSubtree(
          key: ValueKey<T>(option.value),
          child: widget.itemBuilder(context, option, node),
        ),
      );
    }
    final Widget content = widget.direction == Axis.horizontal
        ? Wrap(
            spacing: widget.spacing,
            runSpacing: widget.runSpacing,
            children: children,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int index = 0; index < children.length; index++) ...[
                if (index > 0) SizedBox(height: widget.spacing),
                children[index],
              ],
            ],
          );
    final FocusNode? groupNode = widget.focusNode;
    if (groupNode == null) return content;
    return Focus(
      focusNode: groupNode,
      skipTraversal: true,
      canRequestFocus: initial != null,
      onFocusChange: (bool focused) {
        if (focused) _focusFirstEnabled();
      },
      child: content,
    );
  }
}

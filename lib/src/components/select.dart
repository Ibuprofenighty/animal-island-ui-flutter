import 'dart:async';

import '../internal/content_scope.dart';
import '../internal/light_surface_scope.dart';

import 'dart:math' as math;

import '../foundation/theme.dart';
import '../foundation/icon.dart';
import '../internal/option_cursor.dart';
import '../internal/focus_outline.dart';
import '../internal/presentation_focus.dart';

import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/option.dart';
import '../internal/action_surface.dart';
import '../internal/anchored_panel.dart';

int _nextSelectId = 0;

class IslandSelect<T> extends StatefulWidget {
  IslandSelect({
    super.key,
    this.label = '选择',
    required List<IslandOption<T>> options,
    required this.value,
    required this.onChanged,
    this.placeholder = '请选择',
    this.disabled = false,
    this.allowClear = false,
    this.showSearch = false,
    this.onClear,
    this.onSearch,
    this.filter,
    this.filterLocally = true,
    this.notFound = const Text('暂无数据'),
    this.clearLabel = '清除',
    this.width,
    this.focusNode,
  }) : options = List.unmodifiable(options) {
    if (options.map((e) => e.value).toSet().length != options.length)
      throw ArgumentError('Option values must be unique.');
  }
  final String label, placeholder, clearLabel;
  final List<IslandOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final bool disabled, allowClear, showSearch, filterLocally;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSearch;
  final bool Function(String query, IslandOption<T> option)? filter;
  final Widget notFound;
  final double? width;
  final FocusNode? focusNode;
  @override
  State<IslandSelect<T>> createState() => _IslandSelectState<T>();
}

class _IslandSelectState<T> extends State<IslandSelect<T>> {
  late final ownedFocus = FocusNode();
  FocusNode get focus => widget.focusNode ?? ownedFocus;
  final text = TextEditingController();
  final optionKeys = <T, GlobalKey>{};
  late final optionScroll = ScrollController(onAttach: (_) => revealActive());
  final panelId = 'island-select-${_nextSelectId++}';
  bool open = false, hovered = false;
  String? query;
  String? composingPrefix;
  T? active;
  int presentationGeneration = 0;
  int editingGeneration = 0;
  bool completingPresentation = false;
  bool get enabled => !widget.disabled && widget.onChanged != null;
  String get label =>
      widget.options.where((o) => o.value == widget.value).firstOrNull?.label ??
      '';
  List<IslandOption<T>> get visible => widget.options
      .where(
        (option) =>
            !widget.filterLocally ||
            query == null ||
            query!.isEmpty ||
            (widget.filter?.call(query!, option) ??
                option.label.toLowerCase().contains(query!.toLowerCase())),
      )
      .toList();
  @override
  void initState() {
    super.initState();
    text.text = label;
    text.addListener(normalizeEndedComposition);
  }

  void normalizeEndedComposition() {
    final value = text.value;
    final composing = value.composing.isValid && !value.composing.isCollapsed;
    if (composing) {
      if (composingPrefix == null &&
          query == null &&
          label.isNotEmpty &&
          widget.value != null &&
          value.text == label) {
        composingPrefix = label;
      }
      return;
    }
    final prefix = composingPrefix;
    if (prefix == null) return;
    // Focus transfer can finish composition without invoking input formatters.
    // Only reconcile the still-current buffer owned by this editing session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || composingPrefix != prefix || text.value != value) return;
      if (query == null) {
        composingPrefix = null;
        text.value = TextEditingValue(
          text: label,
          selection: TextSelection.collapsed(offset: label.length),
        );
      } else {
        text.value = startQuery(value, value);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didUpdateWidget(IslandSelect<T> old) {
    super.didUpdateWidget(old);
    final editing = ++editingGeneration;
    if (!enabled || old.focusNode != widget.focusNode) {
      presentationGeneration++;
      completingPresentation = false;
    }
    if (!enabled) {
      open = false;
      query = null;
      composingPrefix = null;
    }
    if (query == null && composingPrefix == null && text.text != label) {
      if (enabled) {
        text.text = label;
      } else {
        // Let EditableText retire its client and finish focus teardown before
        // changing a buffer that the native editor still owns this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scheduleMicrotask(() {
            if (!mounted || enabled || editing != editingGeneration) return;
            text.text = label;
          });
        });
      }
    }
    final values = widget.options.map((o) => o.value).toSet();
    optionKeys.removeWhere((value, _) => !values.contains(value));
    if (!visible.any((o) => o.value == active && !o.disabled))
      active = visible.where((o) => !o.disabled).firstOrNull?.value;
    revealActive();
  }

  void completePresentationFocus() {
    final generation = ++presentationGeneration;
    completingPresentation = true;
    bool current() =>
        mounted && enabled && generation == presentationGeneration;
    settlePresentationFocus(
      current: current,
      onComplete: () => setState(() => completingPresentation = false),
    );
  }

  void revealActive() {
    if (!open) return;
    completePresentationFocus();
    final value = active;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !open || active != value) return;
      final context = optionKeys[value]?.currentContext;
      final object = context?.findRenderObject();
      if (object != null && optionScroll.hasClients) {
        optionScroll.position.ensureVisible(
          object,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  void show() {
    if (!enabled || open) return;
    setState(() {
      open = true;
      active =
          visible
              .where((o) => o.value == widget.value && !o.disabled)
              .firstOrNull
              ?.value ??
          visible.where((o) => !o.disabled).firstOrNull?.value;
    });
    focus.requestFocus();
    revealActive();
  }

  void close({bool restore = false}) {
    if (!open && query == null) return;
    presentationGeneration++;
    final hadQuery = query?.isNotEmpty ?? false;
    setState(() {
      open = false;
      query = null;
      composingPrefix = null;
      active = null;
      text.text = label;
    });
    if (hadQuery) widget.onSearch?.call('');
    if (restore && mounted) focus.requestFocus();
    if (mounted) completePresentationFocus();
  }

  void choose(T value) {
    if (!enabled) return;
    widget.onChanged?.call(value);
    if (mounted) close(restore: true);
  }

  void clear() {
    if (!enabled) return;
    widget.onChanged?.call(null);
    widget.onClear?.call();
    if (mounted) {
      focus.requestFocus();
      completePresentationFocus();
    }
  }

  KeyEventResult key(KeyEvent event) {
    if (event is! KeyDownEvent || !enabled || !focus.hasPrimaryFocus)
      return KeyEventResult.ignored;
    final k = event.logicalKey;
    if (widget.showSearch &&
        text.value.composing.isValid &&
        !text.value.composing.isCollapsed) {
      return KeyEventResult.ignored;
    }
    if (k == LogicalKeyboardKey.escape && open) {
      if (widget.showSearch && (query?.isNotEmpty ?? false)) {
        setState(() {
          query = null;
          composingPrefix = null;
          text.text = label;
          reconcileActive();
        });
        widget.onSearch?.call('');
        return KeyEventResult.handled;
      }
      close(restore: true);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.tab) {
      close();
      return KeyEventResult.ignored;
    }
    if (k == LogicalKeyboardKey.enter ||
        !widget.showSearch && k == LogicalKeyboardKey.space) {
      if (!open) {
        show();
      } else if (active != null) {
        choose(active as T);
      }
      return KeyEventResult.handled;
    }
    if (![
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.home,
      LogicalKeyboardKey.end,
    ].contains(k))
      return KeyEventResult.ignored;
    if (!open) {
      show();
      return KeyEventResult.handled;
    }
    final candidates = visible.where((o) => !o.disabled).toList();
    if (candidates.isEmpty) return KeyEventResult.handled;
    final index = candidates.indexWhere((o) => o.value == active);
    final next = k == LogicalKeyboardKey.home
        ? 0
        : k == LogicalKeyboardKey.end
        ? candidates.length - 1
        : (index + (k == LogicalKeyboardKey.arrowUp ? -1 : 1)) %
              candidates.length;
    setState(() => active = candidates[next].value);
    revealActive();
    return KeyEventResult.handled;
  }

  void reconcileActive() {
    final candidates = visible.where((o) => !o.disabled);
    if (candidates.any((o) => o.value == active)) return;
    active =
        candidates.where((o) => o.value == widget.value).firstOrNull?.value ??
        candidates.firstOrNull?.value;
  }

  TextEditingValue startQuery(
    TextEditingValue oldValue,
    TextEditingValue next,
  ) {
    final pendingPrefix = composingPrefix;
    final prefix = pendingPrefix ?? label;
    final startsQuery =
        pendingPrefix != null ||
        query == null &&
            widget.value != null &&
            prefix.isNotEmpty &&
            oldValue.text == prefix &&
            next.text.length > prefix.length;
    if (!startsQuery || prefix.isEmpty || !next.text.startsWith(prefix)) {
      composingPrefix = null;
      return next;
    }
    // The platform owns the active composition buffer and offsets. Rewriting
    // it now can leave Web IME events addressing the old prefix after commit.
    // Search has a separate logical query; normalize only committed text.
    if (next.composing.isValid && !next.composing.isCollapsed) {
      composingPrefix = prefix;
      return next;
    }
    composingPrefix = null;
    final suffix = next.text.substring(prefix.length);
    int shift(int offset) => (offset - prefix.length).clamp(0, suffix.length);
    return next.copyWith(
      text: suffix,
      selection: next.selection.isValid
          ? TextSelection(
              baseOffset: shift(next.selection.baseOffset),
              extentOffset: shift(next.selection.extentOffset),
              affinity: next.selection.affinity,
              isDirectional: next.selection.isDirectional,
            )
          : next.selection,
      composing: next.composing.isValid && next.composing.start >= prefix.length
          ? TextRange(
              start: shift(next.composing.start),
              end: shift(next.composing.end),
            )
          : TextRange.empty,
    );
  }

  void toggle() {
    if (!enabled) return;
    if (open) {
      close();
    } else {
      show();
    }
  }

  @override
  void dispose() {
    editingGeneration++;
    text.removeListener(normalizeEndedComposition);
    presentationGeneration++;
    ownedFocus.dispose();
    optionScroll.dispose();
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.copyWith(
      fontSize: 14,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
      color: const Color(0xff725d42),
    );
    var panelWidth = 80.0;
    for (final option in visible) {
      final painter = TextPainter(
        text: TextSpan(text: option.label, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      panelWidth = math.max(panelWidth, painter.width + 60);
      painter.dispose();
    }
    final panel = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffffeea0),
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        controller: optionScroll,
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: ContentScope(
                  textStyle: style.copyWith(color: IslandTokens.light.muted),
                  child: widget.notFound,
                ),
              ),
            for (final option in visible) _option(option, style),
          ],
        ),
      ),
    );
    final field = widget.showSearch
        ? TextField(
            // Option filtering is not an autofill form. Avoid native form
            // focus changes when the clear slot changes the editing geometry.
            autofillHints: null,
            controller: text,
            inputFormatters: [TextInputFormatter.withFunction(startQuery)],
            focusNode: focus,
            enabled: enabled,
            style: style.copyWith(height: 19 / 14),
            strutStyle: const StrutStyle(
              fontSize: 14,
              height: 19 / 14,
              forceStrutHeight: true,
            ),
            onTap: show,
            onChanged: (value) {
              final prefix = composingPrefix;
              final nextQuery = prefix != null && value.startsWith(prefix)
                  ? value.substring(prefix.length)
                  : value;
              final changed = query != nextQuery;
              setState(() {
                query = nextQuery;
                open = true;
                reconcileActive();
              });
              if (changed) widget.onSearch?.call(nextQuery);
              revealActive();
            },
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintText: widget.placeholder,
              hintStyle: style.copyWith(
                height: 19 / 14,
                color: IslandTokens.light.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : Text(
            label.isEmpty ? widget.placeholder : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: label.isEmpty
                ? style.copyWith(
                    color: IslandTokens.light.muted,
                    fontWeight: FontWeight.w400,
                  )
                : style,
          );
    final visual = AnimatedContainer(
      curve: Curves.ease,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: !enabled
            ? const Color(0xfff5f5f0)
            : hovered && !open
            ? const Color(0xfffffdf7)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
          color: focus.hasFocus
              ? IslandTokens.light.focus
              : IslandTokens.light.outline,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              explicitChildNodes: widget.showSearch,
              button: !widget.showSearch,
              focusable: widget.showSearch ? null : enabled,
              focused: !widget.showSearch && enabled
                  ? focus.hasPrimaryFocus
                  : null,
              onFocus: !widget.showSearch && enabled
                  ? focus.requestFocus
                  : null,
              label: widget.showSearch ? null : widget.label,
              value: widget.showSearch
                  ? null
                  : (label.isEmpty ? widget.placeholder : label),
              expanded: open,
              enabled: enabled,
              controlsNodes: open ? {panelId} : null,
              onTap: !widget.showSearch && enabled ? toggle : null,
              child: widget.showSearch
                  ? Semantics(label: widget.label, child: field)
                  : ExcludeSemantics(child: field),
            ),
          ),
          if (widget.allowClear &&
              widget.value != null &&
              enabled &&
              (hovered || focus.hasFocus || completingPresentation))
            ActionSurface(
              label: widget.clearLabel,
              onActivate: clear,
              builder: (_, states) => Container(
                width: 26,
                height: 20,
                foregroundDecoration: FocusOutline(
                  const CircleBorder(),
                  states.contains(WidgetState.focused)
                      ? IslandTokens.light.focus
                      : Colors.transparent,
                  width: 2,
                  offset: 0,
                ),
                child: const Center(
                  child: IslandIcon(IslandGlyph.close, size: 12),
                ),
              ),
            ),
          AnimatedRotation(
            turns: open ? .5 : 0,
            curve: Curves.ease,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            child: CustomPaint(
              size: const Size(12, 12),
              painter: _SelectChevron(
                open ? IslandTokens.light.link : IslandTokens.light.muted,
              ),
            ),
          ),
        ],
      ),
    );
    final anchor = Focus(
      focusNode: widget.showSearch ? null : focus,
      includeSemantics: false,
      canRequestFocus: !widget.showSearch && enabled,
      onFocusChange: (_) => setState(() {}),
      onKeyEvent: (_, event) => key(event),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: enabled
              ? () {
                  if (open && !widget.showSearch) {
                    close();
                  } else {
                    show();
                  }
                }
              : null,
          child: Opacity(opacity: enabled ? 1 : .5, child: visual),
        ),
      ),
    );
    return SizedBox(
      width: widget.width ?? (widget.showSearch ? 213 : 140),
      child: AnchoredPanel(
        open: open,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: Duration.zero,
        transitionCurve: Curves.ease,
        transitionOffset: Offset.zero,
        onDismiss: close,
        placement: PanelPlacement.beside,
        width: panelWidth,
        estimatedHeight: visible.length * 44 + 24,
        anchor: anchor,
        panel: Semantics(
          container: true,
          explicitChildNodes: true,
          identifier: panelId,
          role: SemanticsRole.list,
          label: widget.label,
          child: LightSurfaceScope(child: panel),
        ),
      ),
    );
  }

  Widget _option(IslandOption<T> option, TextStyle style) {
    final selected = option.value == widget.value;
    return MouseRegion(
      key: optionKeys.putIfAbsent(option.value, GlobalKey.new),
      onEnter: option.disabled
          ? null
          : (_) => setState(() => active = option.value),
      child: ActionSurface(
        onActivate: option.disabled ? null : () => choose(option.value),
        selected: selected,
        builder: (_, states) => Stack(
          clipBehavior: Clip.none,
          children: [
            if (selected ||
                states.contains(WidgetState.focused) ||
                active == option.value)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: FocusOutline(
                    const StadiumBorder(),
                    IslandTokens.light.focus,
                    width:
                        states.contains(WidgetState.focused) ||
                            active == option.value
                        ? 2
                        : 1,
                    offset: 0,
                  ),
                ),
              ),
            if (selected)
              const Positioned.fill(child: CustomPaint(painter: _SelectPill())),
            if (states.contains(WidgetState.hovered))
              Positioned(
                left: -14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: OptionCursor(
                    reduced: MediaQuery.disableAnimationsOf(context),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Center(
                child: Text(
                  option.label,
                  style: style.copyWith(
                    fontWeight: selected || states.contains(WidgetState.hovered)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: option.disabled ? IslandTokens.light.muted : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectPill extends CustomPainter {
  const _SelectPill();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          20,
          size.height * .56 - 7,
          math.max(0, size.width - 40),
          14,
        ),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0x4dffcc00),
    );
  }

  @override
  bool shouldRepaint(_SelectPill oldDelegate) => false;
}

class _SelectChevron extends CustomPainter {
  const _SelectChevron(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(3, 4.5)
        ..lineTo(6, 7.5)
        ..lineTo(9, 4.5),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SelectChevron oldDelegate) => oldDelegate.color != color;
}

import 'dart:async';

import 'package:flutter/material.dart';

/// The input is an explicit text/span contract, never an arbitrary widget tree.
/// Rich spans keep their styles and recognizers; embedded widgets retain identity.
class IslandTypewriter extends StatefulWidget {
  const IslandTypewriter(
    this.text, {
    super.key,
    this.speed = const Duration(milliseconds: 90),
    this.play = true,
    this.trigger,
    this.onDone,
    this.style,
    this.strutStyle,
  }) : span = null,
       builder = null;
  const IslandTypewriter.rich(
    TextSpan this.span, {
    super.key,
    this.speed = const Duration(milliseconds: 90),
    this.play = true,
    this.trigger,
    this.onDone,
    this.style,
    this.strutStyle,
  }) : text = null,
       builder = null;

  /// Composes the visible grapheme prefix; timing and semantics remain owned here.
  const IslandTypewriter.builder(
    String this.text, {
    super.key,
    required Widget Function(BuildContext context, String visibleText) builder,
    this.speed = const Duration(milliseconds: 90),
    this.play = true,
    this.trigger,
    this.onDone,
  }) : builder = builder,
       span = null,
       style = null,
       strutStyle = null;
  final Widget Function(BuildContext context, String visibleText)? builder;
  final String? text;
  final TextSpan? span;
  final Duration speed;
  final bool play;
  final Object? trigger;
  final VoidCallback? onDone;
  final TextStyle? style;

  /// Optional caller-owned line metrics, as on Flutter Text.
  final StrutStyle? strutStyle;
  @override
  State<IslandTypewriter> createState() => _IslandTypewriterState();
}

class _IslandTypewriterState extends State<IslandTypewriter> {
  Timer? _timer;
  int _visible = 0, _generation = 0;
  bool _reduced = false, _initialized = false;
  String get plain =>
      widget.text ?? widget.span!.toPlainText(includeSemanticsLabels: false);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (!_initialized || reduced != _reduced) {
      _initialized = true;
      _reduced = reduced;
      _start();
    }
  }

  @override
  void didUpdateWidget(IslandTypewriter old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text ||
        old.span != widget.span ||
        old.trigger != widget.trigger ||
        old.play != widget.play ||
        old.speed != widget.speed)
      _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = null;
    final generation = ++_generation;
    final count = plain.characters.length;
    _visible = !widget.play || _reduced || widget.speed <= Duration.zero
        ? count
        : 0;
    if (count == 0) return;
    if (_visible == count) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == _generation) widget.onDone?.call();
      });
      return;
    }
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted || generation != _generation) {
        timer.cancel();
        return;
      }
      setState(() => _visible++);
      if (_visible >= count) {
        timer.cancel();
        _timer = null;
        widget.onDone?.call();
      }
    });
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = plain.characters.take(_visible).toString();
    final visual = widget.builder != null
        ? widget.builder!(context, shown)
        : widget.span == null
        ? Text(shown, style: widget.style, strutStyle: widget.strutStyle)
        : Text.rich(
            _SpanSlice(shown.length).take(widget.span!) ?? const TextSpan(),
            style: widget.style,
            strutStyle: widget.strutStyle,
          );
    return Semantics(
      label: widget.span?.toPlainText() ?? widget.text,
      child: ExcludeSemantics(child: visual),
    );
  }
}

class _SpanSlice {
  _SpanSlice(this.remaining);
  int remaining;
  InlineSpan? take(InlineSpan span) {
    if (remaining <= 0) return null;
    if (span is WidgetSpan) {
      remaining--;
      return span;
    }
    if (span is! TextSpan)
      throw ArgumentError('Typewriter supports TextSpan and WidgetSpan.');
    final text = span.text ?? '';
    final amount = remaining.clamp(0, text.length);
    remaining -= amount;
    final children = <InlineSpan>[];
    for (final child in span.children ?? const <InlineSpan>[]) {
      final clipped = take(child);
      if (clipped != null) children.add(clipped);
    }
    return TextSpan(
      text: text.substring(0, amount),
      children: children,
      style: span.style,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }
}

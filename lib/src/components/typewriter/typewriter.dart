import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';

/// Animal Island dialogue typewriter text animation (C03).
///
/// Features:
/// - Zero-jitter layout preservation: renders invisible character reservations for
///   unrevealed text so line-wrapping and container bounds never shift during typing.
/// - Linear O(N) memory architecture: avoids $O(N^2)$ prefix/suffix string caching,
///   processing Unicode grapheme clusters safely with [Characters].
/// - TickerMode aware: pauses typing progression when disabled or obscured.
/// - Accessible screen-reader semantics: announces the complete text once rather than
///   spamming live announcements per typed character.
/// - Guaranteed exactly-once [onComplete] execution.
class AnimalTypewriter extends StatefulWidget {
  /// The full text string to be typed out.
  final String text;

  /// Time delay between revealing each grapheme cluster. Default 40ms.
  final Duration speed;

  /// Text style override. If null, inherits from the active theme's body style.
  final TextStyle? style;

  /// Alignment of text inside the container.
  final TextAlign? textAlign;

  /// Whether to display a blinking cursor at the typing head.
  final bool showCursor;

  /// Optional callback fired once typing is complete.
  final VoidCallback? onComplete;

  const AnimalTypewriter({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 40),
    this.style,
    this.textAlign,
    this.showCursor = false,
    this.onComplete,
  });

  @override
  State<AnimalTypewriter> createState() => _AnimalTypewriterState();
}

class _AnimalTypewriterState extends State<AnimalTypewriter> {
  int _charIndex = 0;
  Timer? _typingTimer;
  Timer? _cursorTimer;
  bool _cursorVisible = true;
  bool _completed = false;
  bool _tickerModeEnabled = true;

  late List<String> _graphemes;

  @override
  void initState() {
    super.initState();
    _initGraphemes();
    _startTyping();
    _initCursor();
  }

  void _initGraphemes() {
    _graphemes = widget.text.characters.toList(growable: false);
    _completed = _graphemes.isEmpty;
  }

  void _initCursor() {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (!mounted) return;
        setState(() => _cursorVisible = !_cursorVisible);
      });
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    _typingTimer = null;

    if (_graphemes.isEmpty) {
      _completed = true;
      widget.onComplete?.call();
      return;
    }

    if (_charIndex >= _graphemes.length) {
      _completed = true;
      return;
    }

    if (!_tickerModeEnabled) return;

    _typingTimer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!_tickerModeEnabled) {
        timer.cancel();
        _typingTimer = null;
        return;
      }

      if (_charIndex < _graphemes.length) {
        setState(() => _charIndex++);
        if (_charIndex >= _graphemes.length && !_completed) {
          _completed = true;
          timer.cancel();
          _typingTimer = null;
          widget.onComplete?.call();
        }
      } else {
        timer.cancel();
        _typingTimer = null;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = AnimalMotionPolicy.shouldAnimate(context);
    if (_tickerModeEnabled != enabled) {
      _tickerModeEnabled = enabled;
      if (_tickerModeEnabled) {
        if (!_completed) _startTyping();
      } else {
        _typingTimer?.cancel();
        _typingTimer = null;
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimalTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showCursor != widget.showCursor) {
      _initCursor();
    }

    if (oldWidget.text != widget.text) {
      _typingTimer?.cancel();
      _charIndex = 0;
      _completed = false;
      _initGraphemes();
      _startTyping();
    } else if (oldWidget.speed != widget.speed) {
      if (!_completed) {
        _startTyping();
      }
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final baseStyle = widget.style ?? theme.typography.body;
    final effectiveStyle = theme.typography
        .resolve(baseStyle)
        .copyWith(color: widget.style?.color ?? theme.colors.text);
    final transparentStyle = effectiveStyle.copyWith(
      color: const Color(0x00000000),
    );

    final totalChars = _graphemes.length;
    final clampedIndex = _charIndex.clamp(0, totalChars);
    final revealed = _graphemes.sublist(0, clampedIndex).join();
    final unrevealed = _graphemes.sublist(clampedIndex).join();
    final isDone = clampedIndex >= totalChars;

    final cursorOpacity = (!isDone && widget.showCursor && _cursorVisible)
        ? 1.0
        : 0.0;

    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            style: effectiveStyle,
            children: [
              TextSpan(text: revealed),
              if (widget.showCursor && !isDone)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Opacity(
                    opacity: cursorOpacity,
                    child: Container(
                      width: 2.0,
                      height: (effectiveStyle.fontSize ?? 16.0) * 1.1,
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: BoxDecoration(
                        color: theme.colors.primary,
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    ),
                  ),
                ),
              // Invisible reservation maintains constant bounding box and wrapping
              if (unrevealed.isNotEmpty)
                TextSpan(text: unrevealed, style: transparentStyle),
            ],
          ),
          textAlign: widget.textAlign ?? TextAlign.start,
        ),
      ),
    );
  }
}

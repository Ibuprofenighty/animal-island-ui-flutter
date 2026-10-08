import 'package:flutter/material.dart';

import '../../foundation/models/clock.dart';
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

  /// Clock used to measure typing elapsed time. Defaults to [SystemClock].
  final AnimalClock clock;

  /// Owner-provided visibility for periodic work; it does not hide layout.
  final bool visible;

  /// Creates a typewriter that reveals [text].
  const AnimalTypewriter({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 40),
    this.style,
    this.textAlign,
    this.showCursor = false,
    this.onComplete,
    this.clock = const SystemClock(),
    this.visible = true,
  });

  @override
  State<AnimalTypewriter> createState() => _AnimalTypewriterState();
}

class _AnimalTypewriterState extends State<AnimalTypewriter> {
  int _charIndex = 0;
  late AnimalMotionScheduler _motionScheduler;
  late AnimalMotionRegistration _typing;
  late AnimalMotionRegistration _cursor;
  Duration _typingElapsed = Duration.zero;
  bool _cursorVisible = true;
  bool _completed = false;
  bool _isFocused = false;
  bool _isHovered = false;

  late List<String> _graphemes;

  @override
  void initState() {
    super.initState();
    _initGraphemes();
    _motionScheduler = AnimalMotionScheduler(clock: widget.clock);
    _typing = _motionScheduler.schedulePeriodic(
      interval: widget.speed,
      work: AnimalScheduledWork.decorative,
      eligible: false,
      onTick: _handleTypingTick,
    );
    _cursor = _motionScheduler.schedulePeriodic(
      interval: const Duration(milliseconds: 500),
      work: AnimalScheduledWork.decorative,
      eligible: false,
      onTick: _toggleCursor,
    );
    if (_graphemes.isEmpty) widget.onComplete?.call();
  }

  void _initGraphemes() {
    _graphemes = widget.text.characters.toList(growable: false);
    _completed = _graphemes.isEmpty;
  }

  void _toggleCursor(DateTime _, Duration _) {
    if (!mounted) return;
    setState(() => _cursorVisible = !_cursorVisible);
  }

  void _handleTypingTick(DateTime _, Duration elapsed) {
    if (!mounted || _completed || _graphemes.isEmpty) return;
    if (widget.speed <= Duration.zero) {
      _revealThrough(_charIndex + 1);
      return;
    }
    _typingElapsed += elapsed;
    final int due =
        _typingElapsed.inMicroseconds ~/ widget.speed.inMicroseconds;
    if (due == 0) return;
    _typingElapsed -= widget.speed * due;
    _revealThrough(_charIndex + due);
  }

  void _revealThrough(int requestedIndex) {
    final int nextIndex = requestedIndex.clamp(0, _graphemes.length);
    if (nextIndex <= _charIndex) return;
    setState(() => _charIndex = nextIndex);
    if (_charIndex == _graphemes.length && !_completed) {
      _completed = true;
      _typing.setEligible(false);
      _cursor.setEligible(false);
      widget.onComplete?.call();
    }
  }

  void _syncEligibility() {
    final bool eligible = AnimalMotionPolicy.decorativeContextEligible(
      context,
      focused: _isFocused,
      hovered: _isHovered,
      visible: widget.visible,
    );
    _typing.setEligible(eligible && !_completed && _graphemes.isNotEmpty);
    _cursor.setEligible(eligible && widget.showCursor && !_completed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEligibility();
  }

  @override
  void didUpdateWidget(covariant AnimalTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showCursor != widget.showCursor) {
      _cursorVisible = true;
    }

    if (oldWidget.text != widget.text) {
      _charIndex = 0;
      _completed = false;
      _typingElapsed = Duration.zero;
      _initGraphemes();
      if (_graphemes.isEmpty) widget.onComplete?.call();
    }
    if (oldWidget.clock != widget.clock) {
      _motionScheduler.updateClock(widget.clock);
    }
    if (oldWidget.speed != widget.speed) _typing.updateInterval(widget.speed);
    _syncEligibility();
  }

  @override
  void dispose() {
    _motionScheduler.dispose();
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

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (bool focused) {
        if (_isFocused == focused) return;
        _isFocused = focused;
        _syncEligibility();
      },
      child: MouseRegion(
        onEnter: (_) {
          if (_isHovered) return;
          _isHovered = true;
          _syncEligibility();
        },
        onExit: (_) {
          if (!_isHovered) return;
          _isHovered = false;
          _syncEligibility();
        },
        child: Semantics(
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
        ),
      ),
    );
  }
}

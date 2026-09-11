import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';

/// Animal Island dialogue typewriter text animation.
///
/// Features:
/// - Zero-jitter layout preservation: pre-allocates exact line wrapping and
///   dimensions using transparent character reservation so surrounding UI never shifts.
/// - Full theme-aware styling.
class AnimalTypewriter extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool showCursor;
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
  Timer? _timer;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  late List<String> _graphemes;
  late List<String> _prefixStrings;
  late List<String> _suffixStrings;

  @override
  void initState() {
    super.initState();
    _initGraphemes();
    _startTyping();
    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (!mounted) return;
        setState(() => _cursorVisible = !_cursorVisible);
      });
    }
  }

  void _initGraphemes() {
    _graphemes = widget.text.characters.toList(growable: false);
    final count = _graphemes.length;
    _prefixStrings = List<String>.generate(count + 1, (i) {
      if (i == 0) return '';
      if (i == count) return widget.text;
      return _graphemes.take(i).join();
    }, growable: false);
    _suffixStrings = List<String>.generate(count + 1, (i) {
      if (i == 0) return widget.text;
      if (i == count) return '';
      return _graphemes.skip(i).join();
    }, growable: false);
  }

  void _startTyping() {
    final totalLength = _graphemes.length;
    _timer?.cancel();
    if (totalLength == 0) {
      widget.onComplete?.call();
      return;
    }
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < totalLength) {
        setState(() => _charIndex++);
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimalTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showCursor != widget.showCursor) {
      _cursorTimer?.cancel();
      _cursorTimer = null;
      if (widget.showCursor) {
        _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (!mounted) return;
          setState(() => _cursorVisible = !_cursorVisible);
        });
      }
    }
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _charIndex = 0;
      _initGraphemes();
      _startTyping();
    } else if (oldWidget.speed != widget.speed) {
      _timer?.cancel();
      _startTyping();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final defaultStyle = AnimalTypography.body.copyWith(color: theme.text);
    final baseStyle = widget.style ?? defaultStyle;
    final textColor = (baseStyle.color == null || (theme.isDark && baseStyle.color == const Color(0xFF4A3E3D)))
        ? theme.text
        : baseStyle.color!;
    final effectiveStyle = baseStyle.copyWith(color: textColor);

    final totalChars = _graphemes.length;
    final clampedIndex = _charIndex.clamp(0, totalChars);
    final revealed = _prefixStrings[clampedIndex];
    final unrevealed = _suffixStrings[clampedIndex];
    final isDone = clampedIndex >= totalChars;

    final cursorOpacity = (!isDone && widget.showCursor && _cursorVisible) ? 1.0 : 0.0;

    return Semantics(
      label: widget.text,
      child: Text.rich(
        TextSpan(
          style: effectiveStyle,
          children: [
            TextSpan(text: revealed),
            if (widget.showCursor && !isDone)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Opacity(
                  opacity: cursorOpacity,
                  child: Container(
                    width: 2.0,
                    height: (effectiveStyle.fontSize ?? 14.0) * 1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    color: theme.primary,
                  ),
                ),
              ),
            TextSpan(
              text: unrevealed,
              style: effectiveStyle.copyWith(
                color: const Color(0x00000000),
              ),
            ),
          ],
        ),
        textAlign: widget.textAlign ?? TextAlign.center,
      ),
    );
  }
}

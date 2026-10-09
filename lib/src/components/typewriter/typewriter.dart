import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/models/clock.dart';
import '../../foundation/theme/components/typewriter_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';

/// Animal Island dialogue typewriter text animation (C03).
///
/// The whole [text] is laid out once, so line breaks and the widget's size
/// never change while it types; typing only reveals more of it, one Unicode
/// grapheme cluster at a time. The cursor is painted over the text and takes
/// no space. The widget keeps one offset per grapheme cluster, so its memory
/// grows linearly with the text.
///
/// Typing pauses while the widget is hidden or hovered, under a disabled
/// [TickerMode] or while the app is in the background, and continues where it
/// stopped. With reduced motion the whole text appears at once.
/// Screen readers read the complete text once instead of every typed
/// character.
class AnimalTypewriter extends StatefulWidget {
  /// The full text to type out.
  final String text;

  /// Time between revealing two grapheme clusters.
  final Duration speed;

  /// Visual overrides for this typewriter. They win over
  /// `AnimalIslandTheme.components.typewriter`.
  final AnimalTypewriterStyle? style;

  /// Alignment of the text inside its box.
  final TextAlign? textAlign;

  /// Whether a blinking cursor marks the typing position until the text is
  /// complete.
  final bool showCursor;

  /// Called once when the whole text is visible: after the last cluster is
  /// typed, after the first frame for an empty text or under reduced motion.
  ///
  /// Changing [text] restarts typing and cancels the pending call for the
  /// previous text; disposing the widget cancels it too.
  final VoidCallback? onComplete;

  /// Clock used to measure typing time. Defaults to [SystemClock].
  final AnimalClock clock;

  /// Owner-provided visibility for typing; it does not hide layout.
  final bool visible;

  /// Creates a typewriter that reveals [text].
  ///
  /// Throws an [ArgumentError] when [speed] is not positive.
  AnimalTypewriter({
    super.key,
    required this.text,
    Duration speed = const Duration(milliseconds: 40),
    this.style,
    this.textAlign,
    this.showCursor = false,
    this.onComplete,
    this.clock = const SystemClock(),
    this.visible = true,
  }) : speed = _checkSpeed(speed);

  static Duration _checkSpeed(Duration speed) {
    if (speed <= Duration.zero) {
      throw ArgumentError.value(speed, 'speed', 'must be positive');
    }
    return speed;
  }

  @override
  State<AnimalTypewriter> createState() => _AnimalTypewriterState();
}

/// Time the cursor stays shown or hidden while it blinks.
const Duration _cursorBlink = Duration(milliseconds: 500);

class _AnimalTypewriterState extends State<AnimalTypewriter> {
  late final AnimalMotionScheduler _scheduler;
  late final AnimalPeriodicRegistration _typing;
  late final AnimalPeriodicRegistration _blink;

  /// UTF-16 end offset of each grapheme cluster of the text.
  late Uint32List _clusterEnds;
  int _revealed = 0;
  Duration _carry = Duration.zero;

  /// Identifies the current text; a deferred completion of an earlier text
  /// is dropped.
  int _generation = 0;
  bool _completed = false;
  bool _cursorShown = true;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _clusterEnds = _endsOf(widget.text);
    _scheduler = AnimalMotionScheduler(clock: widget.clock);
    _typing = _scheduler.schedulePeriodic(
      interval: widget.speed,
      eligible: false,
      onTick: _type,
    );
    _blink = _scheduler.schedulePeriodic(
      interval: _cursorBlink,
      eligible: false,
      onTick: (_) => setState(() => _cursorShown = !_cursorShown),
    );
  }

  static Uint32List _endsOf(String text) {
    final Characters clusters = text.characters;
    final Uint32List ends = Uint32List(clusters.length);
    int index = 0;
    int offset = 0;
    for (final String cluster in clusters) {
      offset += cluster.length;
      ends[index++] = offset;
    }
    return ends;
  }

  void _type(Duration elapsed) {
    _carry += elapsed;
    final int due = _carry.inMicroseconds ~/ widget.speed.inMicroseconds;
    if (due == 0) return;
    _carry -= widget.speed * due;
    setState(() {
      _revealed = math.min(_revealed + due, _clusterEnds.length);
    });
    if (_revealed == _clusterEnds.length) _complete(inBuild: false);
  }

  /// Ends typing of the current text; [inBuild] defers [onComplete] until
  /// the frame ends.
  void _complete({required bool inBuild}) {
    _completed = true;
    _typing.setEligible(false);
    _blink.setEligible(false);
    if (!inBuild) {
      widget.onComplete?.call();
      return;
    }
    final int generation = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) widget.onComplete?.call();
    });
  }

  void _syncMotion({required bool inBuild}) {
    if (!_completed &&
        (_clusterEnds.isEmpty || AnimalMotionPolicy.reducesMotion(context))) {
      _revealed = _clusterEnds.length;
      _complete(inBuild: inBuild);
    }
    final bool eligible =
        !_completed &&
        AnimalMotionPolicy.decorativeContextEligible(
          context,
          hovered: _hovered,
          visible: widget.visible,
        );
    _typing.setEligible(eligible);
    final bool blinking = eligible && widget.showCursor;
    if (!blinking && !_cursorShown) {
      if (inBuild) {
        _cursorShown = true;
      } else {
        setState(() => _cursorShown = true);
      }
    }
    _blink.setEligible(blinking);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion(inBuild: true);
  }

  @override
  void didUpdateWidget(covariant AnimalTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _generation++;
      _clusterEnds = _endsOf(widget.text);
      _revealed = 0;
      _carry = Duration.zero;
      _completed = false;
    }
    if (oldWidget.showCursor != widget.showCursor) _cursorShown = true;
    if (!identical(oldWidget.clock, widget.clock)) {
      _scheduler.updateClock(widget.clock);
    }
    _typing.updateInterval(widget.speed);
    _syncMotion(inBuild: true);
  }

  @override
  void dispose() {
    _scheduler.dispose();
    super.dispose();
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered) return;
    _hovered = hovered;
    _syncMotion(inBuild: false);
  }

  @override
  Widget build(BuildContext context) {
    final _ResolvedTypewriterStyle s = _ResolvedTypewriterStyle.resolve(
      theme: AnimalIslandTheme.of(context),
      style: widget.style,
    );
    final int revealedOffset = _revealed == 0 ? 0 : _clusterEnds[_revealed - 1];

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Semantics(
        label: widget.text,
        child: ExcludeSemantics(
          child: _TypewriterReveal(
            revealedOffset: revealedOffset,
            textLength: widget.text.length,
            cursor: widget.showCursor && !_completed && _cursorShown
                ? _TypewriterCursor(color: s.cursorColor, width: s.cursorWidth)
                : null,
            // Selection is disabled so the text renders as one paragraph
            // that the reveal paints.
            child: SelectionContainer.disabled(
              child: Text.rich(
                TextSpan(text: widget.text),
                style: s.textStyle,
                textAlign: widget.textAlign ?? TextAlign.start,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The one resolution of [AnimalTypewriter] visuals: instance style, then the
/// component theme, then token defaults.
class _ResolvedTypewriterStyle {
  final TextStyle textStyle;
  final Color cursorColor;
  final double cursorWidth;

  const _ResolvedTypewriterStyle._({
    required this.textStyle,
    required this.cursorColor,
    required this.cursorWidth,
  });

  static _ResolvedTypewriterStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalTypewriterStyle? style,
  }) {
    final AnimalTypewriterStyle merged = (style ?? AnimalTypewriterStyle())
        .merge(theme.components.typewriter);
    return _ResolvedTypewriterStyle._(
      textStyle: theme.typography
          .resolve(theme.typography.body.merge(merged.textStyle))
          .copyWith(color: merged.textColor ?? theme.colors.text),
      cursorColor: merged.cursorColor ?? theme.colors.primary,
      cursorWidth: merged.cursorWidth ?? 2,
    );
  }
}

@immutable
class _TypewriterCursor {
  const _TypewriterCursor({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  bool operator ==(Object other) =>
      other is _TypewriterCursor &&
      other.color == color &&
      other.width == width;

  @override
  int get hashCode => Object.hash(color, width);
}

/// Paints its text paragraph only up to [revealedOffset] and draws the
/// cursor there, without changing the paragraph's layout.
class _TypewriterReveal extends SingleChildRenderObjectWidget {
  const _TypewriterReveal({
    required this.revealedOffset,
    required this.textLength,
    required this.cursor,
    required super.child,
  });

  final int revealedOffset;
  final int textLength;
  final _TypewriterCursor? cursor;

  @override
  _RenderTypewriterReveal createRenderObject(BuildContext context) =>
      _RenderTypewriterReveal(
        revealedOffset: revealedOffset,
        textLength: textLength,
        cursor: cursor,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTypewriterReveal renderObject,
  ) {
    renderObject
      ..revealedOffset = revealedOffset
      ..textLength = textLength
      ..cursor = cursor;
  }
}

class _RenderTypewriterReveal extends RenderProxyBox {
  _RenderTypewriterReveal({
    required this._revealedOffset,
    required this._textLength,
    required this._cursor,
  });

  final LayerHandle<ClipPathLayer> _clipLayer = LayerHandle<ClipPathLayer>();

  int _revealedOffset;
  set revealedOffset(int value) {
    if (_revealedOffset == value) return;
    _revealedOffset = value;
    markNeedsPaint();
  }

  int _textLength;
  set textLength(int value) {
    if (_textLength == value) return;
    _textLength = value;
    markNeedsPaint();
  }

  _TypewriterCursor? _cursor;
  set cursor(_TypewriterCursor? value) {
    if (_cursor == value) return;
    _cursor = value;
    markNeedsPaint();
  }

  RenderParagraph get _paragraph => child! as RenderParagraph;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_revealedOffset >= _textLength) {
      _clipLayer.layer = null;
      super.paint(context, offset);
    } else if (_revealedOffset > 0) {
      final Path revealed = Path();
      for (final TextBox box in _paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: _revealedOffset),
        boxHeightStyle: ui.BoxHeightStyle.max,
      )) {
        revealed.addRect(box.toRect());
      }
      _clipLayer.layer = context.pushClipPath(
        needsCompositing,
        offset,
        Offset.zero & size,
        revealed,
        super.paint,
        oldLayer: _clipLayer.layer,
      );
    } else {
      _clipLayer.layer = null;
    }

    final _TypewriterCursor? cursor = _cursor;
    if (cursor == null) return;
    final TextPosition position = TextPosition(
      offset: _revealedOffset,
      affinity: TextAffinity.upstream,
    );
    final double height = _paragraph.getFullHeightForCaret(position);
    final Offset caret = _paragraph.getOffsetForCaret(
      position,
      Rect.fromLTWH(0, 0, cursor.width, height),
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        (offset + caret) & Size(cursor.width, height),
        Radius.circular(cursor.width / 2),
      ),
      Paint()..color = cursor.color,
    );
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }
}

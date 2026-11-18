import '../internal/css_flex.dart';
import '../internal/css_line_box.dart';
import '../internal/surface_motion.dart';
import '../foundation/recipes/time.dart';
import '../foundation/time_value.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Layout of an [IslandTime].
enum IslandTimeVariant {
  /// Clock card: `HH:MM` above one weekday · month-day capsule.
  normal,

  /// Bare vertical HUD: clock, a hairline rule, then the month-day beside a
  /// weekday capsule. No card surface or shadow.
  game,
}

/// Instance styling of one [IslandTime], the counterpart of the reference
/// `className` overrides (`--animal-time-color`, `--animal-primary-color`,
/// `--animal-text-color-secondary`, `--animal-text-color-disabled`,
/// `--animal-primary-color-bg`, `--animal-font-family`,
/// `--animal-font-size-sm`, and the root background, radius, padding and
/// shadow).
///
/// Each non-null field replaces the recipe value of the chosen variant and
/// host brightness; a null field keeps it. Caller colours are caller-owned:
/// the library neither checks nor corrects their contrast.
@immutable
class IslandTimeStyle {
  const IslandTimeStyle({
    this.clockColor,
    this.weekdayColor,
    this.dateColor,
    this.separatorColor,
    this.capsuleColor,
    this.decoration,
    this.padding,
    this.fontFamily,
    this.capsuleFontSize,
  });

  /// Ink of the `HH:MM` digits and the blinking colon, in both variants.
  final Color? clockColor;

  /// Ink of the weekday: inside the card's date capsule, or inside the game
  /// HUD's weekday capsule.
  final Color? weekdayColor;

  /// Ink of the month-day: inside the card's date capsule, or beside the game
  /// HUD's weekday capsule.
  final Color? dateColor;

  /// The card's decorative `·` between weekday and month-day, or the game
  /// HUD's decorative rule under the clock.
  final Color? separatorColor;

  /// Fill of the card's date capsule, or of the game HUD's weekday capsule.
  final Color? capsuleColor;

  /// Surface painted behind the whole clock, replacing the card's soft-shadow
  /// surface (for example with a gradient, another radius or shadow). The game
  /// HUD has no surface by default and paints this one when given.
  final Decoration? decoration;

  /// Space between the surface edge and the content; the card default is
  /// 20/32/15 (top/sides/bottom), the game default 50 on every side.
  final EdgeInsetsGeometry? padding;

  /// Font family of every text in the clock; null inherits the ambient
  /// [DefaultTextStyle] family.
  final String? fontFamily;

  /// Font size of the capsule text: the card's weekday · month-day (default
  /// 12) or the game HUD's weekday (default 15). The clock and the game
  /// month-day keep their sizes.
  final double? capsuleFontSize;
}

/// A wall-clock display. [now] supplies local time and may be replaced for a
/// deterministic preview. This instance owns and cancels its refresh timer,
/// which also steps the reference 1s colon blink (visible, then hidden for
/// half a second); with reduced motion the colon stays visible. Digits never
/// dim.
class IslandTime extends StatefulWidget {
  const IslandTime({
    super.key,
    this.now,
    this.semanticLabel,
    this.variant = IslandTimeVariant.normal,
    this.weekdayFormat = 'dddd',
    this.dateFormat,
    this.locale = IslandTimeLocale.en,
    this.style,
  });

  /// Local time source; null reads [DateTime.now].
  final DateTime Function()? now;

  /// Accessible name of the clock; its value is always the complete reading.
  final String? semanticLabel;

  /// Card or game HUD layout.
  final IslandTimeVariant variant;

  /// Weekday pattern in core date tokens (`dddd`, `ddd`, `dd`, …); the card
  /// shows it upper-cased.
  final String weekdayFormat;

  /// Month-day pattern in core date tokens; null uses `MMM D`, or `M月D日`
  /// for [IslandTimeLocale.zhCn].
  final String? dateFormat;

  /// Language of weekday and month names.
  final IslandTimeLocale locale;

  /// Instance colours, surface, padding and typography; null keeps the
  /// recipe of [variant] and the host brightness.
  final IslandTimeStyle? style;
  @override
  State<IslandTime> createState() => _IslandTimeState();
}

class _IslandTimeState extends State<IslandTime>
    with SingleTickerProviderStateMixin {
  late DateTime current;
  Timer? timer;
  // Reference `animal-time-blink 1s step-end` (opacity 0 from 50%): each
  // 500ms refresh tick flips the decorative colon.
  bool colonShown = true;
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  DateTime read() => widget.now?.call() ?? DateTime.now();
  @override
  void initState() {
    super.initState();
    current = read();
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        current = read();
        colonShown = !colonShown;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = 1;
    } else if (motion.status == AnimationStatus.dismissed) {
      motion.forward();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final locale = widget.locale;
    final weekday = formatDateTokens(
      current,
      widget.weekdayFormat,
      locale: locale,
    );
    final date = formatDateTokens(
      current,
      widget.dateFormat ?? (locale == IslandTimeLocale.zhCn ? 'M月D日' : 'MMM D'),
      locale: locale,
    );
    final clock = '${pad(current.hour)}:${pad(current.minute)}';
    final game = widget.variant == IslandTimeVariant.game;
    final style = widget.style;
    final roles = TimeRoles.resolve(
      game: game,
      brightness: Theme.of(context).brightness,
      clock: style?.clockColor,
      weekday: style?.weekdayColor,
      date: style?.dateColor,
      separator: style?.separatorColor,
      capsule: style?.capsuleColor,
      decoration: style?.decoration,
      padding: style?.padding,
      capsuleFontSize: style?.capsuleFontSize,
    );
    final gameDateStyle = TextStyle(
      color: roles.date,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
    );
    final gameWeekdayStyle = TextStyle(
      color: roles.weekday,
      fontSize: roles.capsuleFontSize,
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: 0,
    );
    const gameWeekdayPadding = EdgeInsets.fromLTRB(16, 7, 16, 5);
    final capsuleStyle = TextStyle(
      fontSize: roles.capsuleFontSize,
      // Reference `line-height: normal`: the fonts' own metrics.
      height: kTextHeightNone,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: roles.date,
    );
    // Blink `line-height: normal` rounds the fonts' ascent and descent
    // separately (Noto Sans SC 15px: 17 + 4 = 21, where Flutter's own line is
    // the rounded 21.72 = 22), so the capsule line box is that sum.
    final capsuleLine = cssNormalLineHeight(
      context,
      '${weekday.toUpperCase()}·$date',
      capsuleStyle.merge(TextStyle(fontFamily: style?.fontFamily)),
    );

    Widget clockRow({
      required double fontSize,
      required double letterSpacing,
      required double colonGap,
      required double colonRise,
    }) => DefaultTextStyle.merge(
      style: TextStyle(
        color: roles.clock,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(pad(current.hour)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: colonGap),
            child: Transform.translate(
              offset: Offset(0, -colonRise),
              child: Opacity(
                opacity: colonShown || MediaQuery.disableAnimationsOf(context)
                    ? 1
                    : 0,
                child: const Text(':'),
              ),
            ),
          ),
          Text(pad(current.minute)),
        ],
      ),
    );
    final content = game
        ? IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                clockRow(
                  fontSize: 40,
                  letterSpacing: 2,
                  colonGap: 1,
                  colonRise: 40 * .08,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 2,
                  child: CustomPaint(painter: _GameRule(roles.separator)),
                ),
                const SizedBox(height: 5),
                // Reference flex items: under a narrow parent both shrink
                // in proportion to their natural widths, but never below
                // their min-content width, so the month-day and CJK capsule
                // text wrap (Nov / 17, 星期 / 二) while `Tuesday` stays whole.
                _CssShrinkRow(
                  gap: 20,
                  children: [
                    Text(date, style: gameDateStyle),
                    Container(
                      // 7 + 15 + 5 = 27px; the extra top pixel lands
                      // CJK ink on the optical centre.
                      padding: gameWeekdayPadding,
                      decoration: BoxDecoration(
                        color: roles.capsule,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(weekday, style: gameWeekdayStyle),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              clockRow(
                fontSize: 44,
                letterSpacing: 1,
                colonGap: 2,
                colonRise: 44 * .11,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roles.capsule,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: DefaultTextStyle.merge(
                  style: capsuleStyle,
                  child: CssLineBox(
                    height: capsuleLine,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekday.toUpperCase(),
                          style: TextStyle(
                            color: roles.weekday,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '·',
                            style: TextStyle(color: roles.separator),
                          ),
                        ),
                        Text(date),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
    final family = style?.fontFamily;
    return Semantics(
      label: widget.semanticLabel,
      value: '$clock $weekday $date',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: motion,
          builder: (_, child) => SurfaceMotion(
            // Reference fade-in timing: .35s cubic-bezier(.4,0,.2,1); readable
            // motion replaces the opacity ramp with an opaque 4px rise.
            progress: const Cubic(.4, 0, .2, 1).transform(motion.value),
            offset: const Offset(0, 4),
            child: child!,
          ),
          child: Container(
            padding: roles.padding,
            decoration: roles.decoration,
            child: family == null
                ? content
                : DefaultTextStyle.merge(
                    style: TextStyle(fontFamily: family),
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Reference `.divider`: a 2px rounded rule spanning the content width plus
/// 5px, centred, so it overhangs 2.5px on each side.
class _GameRule extends CustomPainter {
  const _GameRule(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(-2.5, 0, size.width + 5, size.height),
      const Radius.circular(2),
    ),
    Paint()..color = color,
  );

  @override
  bool shouldRepaint(_GameRule old) => old.color != color;
}

/// CSS flex row (`flex-shrink: 1`, `min-width: auto`) with a fixed [gap]:
/// items keep their max-content widths while they fit; an overflowing row
/// shrinks the items in proportion to those widths, and an item that reaches
/// its min-content width (its longest unbreakable run) freezes there while
/// the rest keep shrinking. Items are vertically centred
/// (`align-items: center`).
class _CssShrinkRow extends MultiChildRenderObjectWidget {
  const _CssShrinkRow({required this.gap, required super.children});
  final double gap;
  @override
  _RenderCssShrinkRow createRenderObject(BuildContext context) =>
      _RenderCssShrinkRow(gap, Directionality.of(context));
  @override
  void updateRenderObject(BuildContext context, _RenderCssShrinkRow render) =>
      render
        ..gap = gap
        ..textDirection = Directionality.of(context);
}

class _CssShrinkRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderCssShrinkRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CssShrinkRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CssShrinkRowParentData> {
  _RenderCssShrinkRow(this._gap, this._textDirection);
  double _gap;
  TextDirection _textDirection;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CssShrinkRowParentData) {
      child.parentData = _CssShrinkRowParentData();
    }
  }

  List<RenderBox> get _children {
    final result = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      result.add(child);
      child = childAfter(child);
    }
    return result;
  }

  double get _gaps => _gap * math.max(0, childCount - 1);

  /// CSS 9.7 "Resolving Flexible Lengths" for shrinking with min-content
  /// floors; overflow below the floors stays (CSS overflow).
  List<double> _widths(double maxWidth) {
    final children = _children;
    return cssShrinkWidths(
      base: [
        for (final child in children)
          child.getMaxIntrinsicWidth(double.infinity),
      ],
      floor: [
        for (final child in children)
          child.getMinIntrinsicWidth(double.infinity),
      ],
      available: maxWidth - _gaps,
    );
  }

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    final children = _children;
    final widths = _widths(constraints.maxWidth);
    final sizes = [
      for (var i = 0; i < children.length; i++)
        dry
            ? children[i].getDryLayout(
                BoxConstraints.tightFor(width: widths[i]),
              )
            : (children[i]..layout(
                    BoxConstraints.tightFor(width: widths[i]),
                    parentUsesSize: true,
                  ))
                  .size,
    ];
    final height = sizes.fold<double>(0, (a, s) => math.max(a, s.height));
    final width = widths.fold<double>(0, (a, b) => a + b) + _gaps;
    if (!dry) {
      var x = 0.0;
      for (var i = 0; i < children.length; i++) {
        (children[i].parentData! as _CssShrinkRowParentData).offset = Offset(
          _textDirection == TextDirection.rtl ? width - x - sizes[i].width : x,
          (height - sizes[i].height) / 2,
        );
        x += sizes[i].width + _gap;
      }
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() => size = _layout(constraints, dry: false);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _layout(constraints, dry: true);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _children.fold<double>(
        0,
        (a, child) => a + child.getMinIntrinsicWidth(double.infinity),
      ) +
      _gaps;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _children.fold<double>(
        0,
        (a, child) => a + child.getMaxIntrinsicWidth(double.infinity),
      ) +
      _gaps;

  double _height(double width) {
    final children = _children;
    final widths = _widths(width);
    var height = 0.0;
    for (var i = 0; i < children.length; i++) {
      height = math.max(height, children[i].getMaxIntrinsicHeight(widths[i]));
    }
    return height;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _height(width);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}

import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/theme/components/countdown_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';

/// Size presets for [AnimalCountdown] (C28).
enum AnimalCountdownSize {
  /// Compact size (40x36px tiles).
  small,

  /// Standard size (54x48px tiles).
  middle,

  /// Hero / display size (68x60px tiles).
  large,
}

/// Visual style variant for [AnimalCountdown].
enum AnimalCountdownVariant {
  /// Clean digit tile with 3D bottom depth.
  standard,

  /// Warm island organic clay tile.
  island,
}

/// Units shown by an [AnimalCountdown], from the largest unit down to
/// seconds.
///
/// The largest unit shows the whole remaining amount in that unit and never
/// wraps, so 30 hours shows as `30` hours under [hoursMinutesSeconds].
enum AnimalCountdownFormat {
  /// Days, hours, minutes and seconds.
  daysHoursMinutesSeconds,

  /// Hours, minutes and seconds.
  hoursMinutesSeconds,

  /// Minutes and seconds.
  minutesSeconds,

  /// Seconds only.
  seconds,
}

/// Animal Island 900-weight digit tile countdown (C28).
///
/// The countdown runs against one deadline: [AnimalCountdown.new] counts down
/// to a wall-clock time, and [AnimalCountdown.duration] fixes its deadline on
/// the clock's monotonic time when it starts. The tiles show the remaining
/// time rounded up to whole seconds, so they read `00` only at the deadline,
/// and [onFinish] runs once when the deadline is reached.
///
/// Changing the target, duration or [clock] starts a new countdown; callbacks
/// of the previous one never run afterwards. The tiles stop refreshing while
/// the countdown is hidden, under a disabled [TickerMode] or while the app is
/// in the background, and show the current remaining time again when they
/// return. [onFinish] still runs at the deadline in those states.
class AnimalCountdown extends StatefulWidget {
  final DateTime? _targetTime;
  final Duration? _duration;

  /// Units shown by the tiles.
  final AnimalCountdownFormat format;

  /// Prefix widget placed before the countdown tiles.
  final Widget? prefix;

  /// Size preset.
  final AnimalCountdownSize size;

  /// Visual style variant.
  final AnimalCountdownVariant variant;

  /// Whether the digit tiles have an outline border.
  final bool bordered;

  /// Visual overrides for this countdown. They win over
  /// `AnimalIslandTheme.components.countdown`.
  final AnimalCountdownStyle? style;

  /// Clock that supplies the current time. Defaults to [SystemClock].
  final AnimalClock clock;

  /// Owner-provided visibility for tile refreshes; it does not hide layout.
  final bool visible;

  /// Called with the remaining whole seconds each time the tiles change to
  /// a value above zero. Reaching zero calls [onFinish] instead.
  final ValueChanged<Duration>? onChange;

  /// Called once when the deadline is reached, including a deadline that has
  /// already passed when the countdown starts.
  final VoidCallback? onFinish;

  /// Creates a countdown to [targetTime] on the wall clock of [clock].
  const AnimalCountdown({
    super.key,
    required this._targetTime,
    this.format = AnimalCountdownFormat.hoursMinutesSeconds,
    this.prefix,
    this.size = AnimalCountdownSize.middle,
    this.variant = AnimalCountdownVariant.standard,
    this.bordered = true,
    this.style,
    this.clock = const SystemClock(),
    this.visible = true,
    this.onChange,
    this.onFinish,
  }) : _duration = null;

  /// Creates a countdown that ends [duration] after it starts.
  ///
  /// The deadline is measured on the monotonic time of [clock], so wall-clock
  /// adjustments do not move it.
  const AnimalCountdown.duration({
    super.key,
    required this._duration,
    this.format = AnimalCountdownFormat.hoursMinutesSeconds,
    this.prefix,
    this.size = AnimalCountdownSize.middle,
    this.variant = AnimalCountdownVariant.standard,
    this.bordered = true,
    this.style,
    this.clock = const SystemClock(),
    this.visible = true,
    this.onChange,
    this.onFinish,
  }) : _targetTime = null;

  @override
  State<AnimalCountdown> createState() => _AnimalCountdownState();
}

const Duration _second = Duration(seconds: 1);

class _AnimalCountdownState extends State<AnimalCountdown> {
  late final AnimalMotionScheduler _scheduler;
  late final AnimalMotionRegistration _readout;
  late final AnimalMotionRegistration _deadline;

  /// Monotonic deadline of a duration countdown; null for a wall target.
  Duration? _monotonicDeadline;

  /// Identifies the current countdown; deferred callbacks of an earlier one
  /// are dropped.
  int _generation = 0;
  late int _seconds;
  bool _finished = false;
  bool _readoutEligible = false;

  @override
  void initState() {
    super.initState();
    _scheduler = AnimalMotionScheduler(clock: widget.clock);
    _begin();
    _readout = _scheduler.scheduleReadout(
      eligible: false,
      nextReadout: _untilTilesChange,
      onReadout: () => _refresh(inBuild: false),
    );
    _deadline = _scheduler.scheduleDeadline(
      eligible: !_finished,
      remaining: _remaining,
      onDue: _handleDue,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReadout();
  }

  @override
  void didUpdateWidget(covariant AnimalCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool clockChanged = !identical(oldWidget.clock, widget.clock);
    if (clockChanged) _scheduler.updateClock(widget.clock);
    if (clockChanged ||
        oldWidget._targetTime != widget._targetTime ||
        oldWidget._duration != widget._duration) {
      _begin();
      // Stop, then start again from the new deadline.
      _deadline.setEligible(false);
      _deadline.setEligible(!_finished);
      _readout.restart();
    }
    _syncReadout();
  }

  @override
  void dispose() {
    _scheduler.dispose();
    super.dispose();
  }

  /// Starts a countdown from the current inputs.
  void _begin() {
    _generation++;
    final Duration? duration = widget._duration;
    _monotonicDeadline = duration == null
        ? null
        : widget.clock.monotonicNow + duration;
    final Duration remaining = _remaining();
    _seconds = _ceilSeconds(remaining);
    _finished = remaining <= Duration.zero;
    if (_finished) _emit(_finishCallback, inBuild: true);
  }

  /// The one remaining-time computation for both kinds of countdown.
  Duration _remaining() {
    final Duration? monotonicDeadline = _monotonicDeadline;
    if (monotonicDeadline != null) {
      return monotonicDeadline - widget.clock.monotonicNow;
    }
    return widget._targetTime!.difference(widget.clock.now());
  }

  static int _ceilSeconds(Duration remaining) {
    if (remaining <= Duration.zero) return 0;
    return (remaining.inMicroseconds + _second.inMicroseconds - 1) ~/
        _second.inMicroseconds;
  }

  /// Delay until the tiles next change, or null once the deadline passed.
  Duration? _untilTilesChange() {
    final Duration remaining = _remaining();
    if (remaining <= Duration.zero) return null;
    final int partial = remaining.inMicroseconds % _second.inMicroseconds;
    return partial == 0 ? _second : Duration(microseconds: partial);
  }

  void _syncReadout() {
    final bool visible = AnimalMotionPolicy.functionalTimeContextEligible(
      context,
      visible: widget.visible,
    );
    // Tiles that become visible show the current time first; that refresh
    // can finish the countdown.
    if (visible && !_finished && !_readoutEligible) _refresh(inBuild: true);
    _readoutEligible = visible && !_finished;
    _readout.setEligible(_readoutEligible);
  }

  /// Shows the current remaining time; [inBuild] defers callbacks until the
  /// frame ends.
  void _refresh({required bool inBuild}) {
    final Duration remaining = _remaining();
    if (remaining <= Duration.zero) {
      _finish(inBuild: inBuild);
      return;
    }
    final int seconds = _ceilSeconds(remaining);
    if (seconds == _seconds) return;
    _setSeconds(seconds, inBuild: inBuild);
    final ValueChanged<Duration>? onChange = widget.onChange;
    if (onChange != null) {
      _emit(() => onChange(Duration(seconds: seconds)), inBuild: inBuild);
    }
  }

  void _handleDue() => _finish(inBuild: false);

  void _finish({required bool inBuild}) {
    if (_finished) return;
    _finished = true;
    _setSeconds(0, inBuild: inBuild);
    _readoutEligible = false;
    _readout.setEligible(false);
    // The deadline may be reached first by a readout or a refresh.
    _deadline.setEligible(false);
    _emit(_finishCallback, inBuild: inBuild);
  }

  void _finishCallback() => widget.onFinish?.call();

  void _setSeconds(int seconds, {required bool inBuild}) {
    if (inBuild) {
      _seconds = seconds;
    } else {
      setState(() => _seconds = seconds);
    }
  }

  /// Runs [event] now, or after the current frame when raised while the
  /// widget is being built, unless a newer countdown has started by then.
  void _emit(VoidCallback event, {required bool inBuild}) {
    if (!inBuild) {
      event();
      return;
    }
    final int generation = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) event();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AnimalLocalizations.of(context)!;
    final _ResolvedCountdownStyle s = _ResolvedCountdownStyle.resolve(
      theme: AnimalIslandTheme.of(context),
      size: widget.size,
      variant: widget.variant,
      style: widget.style,
    );
    final int total = _seconds;
    final (List<int> values, List<String> labels) = switch (widget.format) {
      AnimalCountdownFormat.daysHoursMinutesSeconds => (
        <int>[total ~/ 86400, total ~/ 3600 % 24, total ~/ 60 % 60, total % 60],
        <String>[
          localizations.countdownUnitDays,
          localizations.countdownUnitHours,
          localizations.countdownUnitMinutes,
          localizations.countdownUnitSeconds,
        ],
      ),
      AnimalCountdownFormat.hoursMinutesSeconds => (
        <int>[total ~/ 3600, total ~/ 60 % 60, total % 60],
        <String>[
          localizations.countdownUnitHours,
          localizations.countdownUnitMinutes,
          localizations.countdownUnitSeconds,
        ],
      ),
      AnimalCountdownFormat.minutesSeconds => (
        <int>[total ~/ 60, total % 60],
        <String>[
          localizations.countdownUnitMinutes,
          localizations.countdownUnitSeconds,
        ],
      ),
      AnimalCountdownFormat.seconds => (
        <int>[total],
        <String>[localizations.countdownUnitSeconds],
      ),
    };

    final List<Widget> tiles = <Widget>[];
    for (int i = 0; i < values.length; i++) {
      if (i > 0) tiles.add(_buildSeparator(s));
      tiles.add(_buildTile(values[i].toString().padLeft(2, '0'), labels[i], s));
    }

    return Semantics(
      container: true,
      label: localizations.countdownRemaining(total),
      // Tiles wrap onto further lines rather than overflow a narrow box.
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            SizedBox(width: s.prefixGap),
          ],
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildTile(String value, String label, _ResolvedCountdownStyle s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(minWidth: s.width, minHeight: s.height),
          decoration: BoxDecoration(
            color: s.backgroundColor,
            borderRadius: s.borderRadius,
            border: widget.bordered
                ? Border.all(color: s.borderColor, width: s.borderWidth)
                : null,
            boxShadow: [s.shadow],
          ),
          // Centers the digits and lets them widen the tile.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(value, style: s.digitTextStyle),
          ),
        ),
        SizedBox(height: s.labelGap),
        Text(label, style: s.labelTextStyle),
      ],
    );
  }

  Widget _buildSeparator(_ResolvedCountdownStyle s) {
    return Padding(
      padding: s.separatorPadding,
      child: Text(':', style: s.digitTextStyle),
    );
  }
}

/// The one resolution of [AnimalCountdown] visuals: instance style, then the
/// size style and general style of the component theme, then token defaults.
class _ResolvedCountdownStyle {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final BoxShadow shadow;
  final TextStyle digitTextStyle;
  final TextStyle labelTextStyle;
  final double labelGap;
  final EdgeInsetsGeometry separatorPadding;
  final double prefixGap;

  const _ResolvedCountdownStyle._({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.shadow,
    required this.digitTextStyle,
    required this.labelTextStyle,
    required this.labelGap,
    required this.separatorPadding,
    required this.prefixGap,
  });

  static _ResolvedCountdownStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalCountdownSize size,
    required AnimalCountdownVariant variant,
    required AnimalCountdownStyle? style,
  }) {
    final AnimalCountdownThemeData? themed = theme.components.countdown;
    final AnimalCountdownStyle? sized = switch (size) {
      AnimalCountdownSize.small => themed?.smallStyle,
      AnimalCountdownSize.middle => themed?.middleStyle,
      AnimalCountdownSize.large => themed?.largeStyle,
    };
    final AnimalCountdownStyle merged = (style ?? AnimalCountdownStyle())
        .merge(sized)
        .merge(themed?.style);

    final colors = theme.colors;
    final spacing = theme.spacing;
    final bool dark = colors.brightness == Brightness.dark;
    final bool island = variant == AnimalCountdownVariant.island;
    // Registered preset geometry: tile width, height, digit and label ratios.
    final (
      double w,
      double h,
      double digitFactor,
      double labelFactor,
    ) = switch (size) {
      AnimalCountdownSize.small => (40.0, 36.0, 15 / 28, 9 / 12),
      AnimalCountdownSize.middle => (54.0, 48.0, 22 / 28, 10 / 12),
      AnimalCountdownSize.large => (68.0, 60.0, 1.0, 11 / 12),
    };

    return _ResolvedCountdownStyle._(
      width: merged.width ?? w,
      height: merged.height ?? h,
      backgroundColor:
          merged.backgroundColor ??
          (island ? colors.surfaceAlt : colors.bgContent),
      borderColor:
          merged.borderColor ??
          (island
              ? colors.primary.withValues(alpha: dark ? 0.5 : 0.35)
              : (dark ? colors.border : colors.borderLight)),
      borderWidth: merged.borderWidth ?? 1.5,
      borderRadius:
          merged.borderRadius ??
          BorderRadius.circular(
            theme.radii.sm * (size == AnimalCountdownSize.large ? 1.5 : 7 / 6),
          ),
      shadow: merged.shadow ?? theme.shadows.input3d,
      digitTextStyle: theme.typography
          .resolve(
            theme.typography.countdown
                .apply(fontSizeFactor: digitFactor)
                .merge(merged.digitTextStyle),
          )
          .copyWith(color: merged.digitTextColor ?? colors.text),
      labelTextStyle: theme.typography
          .resolve(
            theme.typography.caption
                .apply(fontSizeFactor: labelFactor)
                .copyWith(fontWeight: FontWeight.w700)
                .merge(merged.labelTextStyle),
          )
          .copyWith(color: merged.labelTextColor ?? colors.textSecondary),
      labelGap: merged.labelGap ?? spacing.sm - spacing.xxs,
      separatorPadding:
          merged.separatorPadding ??
          EdgeInsets.symmetric(
            horizontal: size == AnimalCountdownSize.small
                ? spacing.xxs * 1.5
                : spacing.sm - spacing.xxs,
            vertical: spacing.sm,
          ),
      prefixGap: merged.prefixGap ?? spacing.sm,
    );
  }
}

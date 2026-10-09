import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/theme/components/time_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/timing/motion_policy.dart';

/// Cozy Animal Island clock card (C29).
///
/// [AnimalTime.new] shows a given time and never changes it.
/// [AnimalTime.live] shows the current time of its clock and moves to the
/// next second exactly when the wall clock does. A live card stops refreshing
/// while it is hidden, under a disabled [TickerMode] or while the app is in
/// the background, and shows the current time again when it returns.
///
/// The time is formatted for the mounted locale. Screen readers read it when
/// they reach the card; see [liveRegion] for announcements.
class AnimalTime extends StatefulWidget {
  final DateTime? _time;
  final AnimalClock? _clock;

  /// Whether screen readers announce time changes as a live region.
  ///
  /// Defaults to false, so the time is read only when the card is focused or
  /// read. When true, the announced value has minute precision, so a live
  /// card is announced at most once a minute.
  final bool liveRegion;

  /// Owner-provided visibility for live refreshes; it does not hide layout.
  final bool visible;

  /// Visual overrides for this card. They win over
  /// `AnimalIslandTheme.components.time`.
  final AnimalTimeStyle? style;

  /// Creates a card that shows [time].
  const AnimalTime({
    super.key,
    required this._time,
    this.liveRegion = false,
    this.style,
  }) : _clock = null,
       visible = true;

  /// Creates a card that shows the current time of [clock].
  const AnimalTime.live({
    super.key,
    AnimalClock this._clock = const SystemClock(),
    this.liveRegion = false,
    this.visible = true,
    this.style,
  }) : _time = null;

  @override
  State<AnimalTime> createState() => _AnimalTimeState();
}

class _AnimalTimeState extends State<AnimalTime> {
  late DateTime _shown;
  AnimalMotionScheduler? _scheduler;
  AnimalMotionRegistration? _readout;
  bool _readoutEligible = false;

  @override
  void initState() {
    super.initState();
    _syncSource();
  }

  /// Creates or drops the live readout to match the widget's source.
  void _syncSource() {
    final AnimalClock? clock = widget._clock;
    if (clock == null) {
      _scheduler?.dispose();
      _scheduler = null;
      _readout = null;
      _readoutEligible = false;
      _shown = widget._time!;
      return;
    }
    _shown = clock.now();
    final AnimalMotionScheduler? scheduler = _scheduler;
    if (scheduler != null) {
      scheduler.updateClock(clock);
      return;
    }
    final AnimalMotionScheduler created = AnimalMotionScheduler(clock: clock);
    _scheduler = created;
    _readout = created.scheduleReadout(
      eligible: false,
      nextReadout: _untilNextSecond,
      onReadout: _showNow,
    );
  }

  /// Delay until the wall clock reaches its next whole second.
  Duration _untilNextSecond() {
    final DateTime now = widget._clock!.now();
    final int intoSecond = now.millisecond * 1000 + now.microsecond;
    return Duration(microseconds: 1000000 - intoSecond);
  }

  void _showNow() {
    setState(() => _shown = widget._clock!.now());
  }

  void _syncReadout() {
    final AnimalMotionRegistration? readout = _readout;
    if (readout == null) return;
    final bool eligible = AnimalMotionPolicy.functionalTimeContextEligible(
      context,
      visible: widget.visible,
    );
    // A card that becomes visible shows the current time in this frame.
    if (eligible && !_readoutEligible) _shown = widget._clock!.now();
    _readoutEligible = eligible;
    readout.setEligible(eligible);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReadout();
  }

  @override
  void didUpdateWidget(covariant AnimalTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._time != widget._time ||
        !identical(oldWidget._clock, widget._clock)) {
      _syncSource();
    }
    _syncReadout();
  }

  @override
  void dispose() {
    _scheduler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();
    final String timeText = DateFormat.Hms(locale).format(_shown);
    final _ResolvedTimeStyle s = _ResolvedTimeStyle.resolve(
      theme: theme,
      style: widget.style,
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      liveRegion: widget.liveRegion,
      label: localizations.currentTimeLabel,
      value: widget.liveRegion
          ? DateFormat.Hm(locale).format(_shown)
          : timeText,
      child: Container(
        padding: s.padding,
        decoration: BoxDecoration(
          color: s.backgroundColor,
          borderRadius: s.borderRadius,
          border: Border.all(color: s.borderColor, width: s.borderWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimalIcon(
              data: AnimalIcons.clock,
              size: s.iconSize,
              color: s.iconColor,
            ),
            SizedBox(width: s.iconGap),
            Flexible(child: Text(timeText, style: s.textStyle)),
          ],
        ),
      ),
    );
  }
}

/// The one resolution of [AnimalTime] visuals: instance style, then the
/// component theme, then token defaults.
class _ResolvedTimeStyle {
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final TextStyle textStyle;
  final Color iconColor;
  final double iconSize;
  final double iconGap;

  const _ResolvedTimeStyle._({
    required this.padding,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.textStyle,
    required this.iconColor,
    required this.iconSize,
    required this.iconGap,
  });

  static _ResolvedTimeStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalTimeStyle? style,
  }) {
    final AnimalTimeStyle merged = (style ?? AnimalTimeStyle()).merge(
      theme.components.time,
    );
    final colors = theme.colors;
    final spacing = theme.spacing;
    return _ResolvedTimeStyle._(
      padding:
          merged.padding ??
          EdgeInsets.symmetric(
            horizontal: spacing.lg + spacing.xxs,
            vertical: spacing.md,
          ),
      backgroundColor: merged.backgroundColor ?? colors.bgContent,
      borderColor: merged.borderColor ?? colors.border,
      borderWidth: merged.borderWidth ?? 1.5,
      borderRadius: merged.borderRadius ?? theme.radii.cardBorder,
      textStyle: theme.typography
          .resolve(
            theme.typography.heading
                .apply(fontSizeFactor: 0.9)
                .merge(merged.textStyle),
          )
          .copyWith(color: merged.textColor ?? colors.text),
      iconColor: merged.iconColor ?? colors.primaryText,
      iconSize: merged.iconSize ?? 20,
      iconGap: merged.iconGap ?? spacing.sm,
    );
  }
}

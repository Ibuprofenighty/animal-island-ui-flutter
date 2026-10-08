import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/timing/motion_policy.dart';

/// Cozy Animal Island clock card (C29).
///
/// Features:
/// - Static time display or real-time live ticking ([live] = true).
/// - Injectable [AnimalClock] for deterministic tests without artificial async delays.
/// - Accessible screen-reader governance: [liveRegion] defaults to false to prevent
///   interrupting screen-reader users with announcements every second.
class AnimalTime extends StatefulWidget {
  /// Explicit timestamp to display. If null, defaults to current time from [clock].
  final DateTime? time;

  /// Whether the clock ticks every second. Default false.
  final bool live;

  /// Optional clock source for testing. Defaults to [SystemClock].
  final AnimalClock clock;

  /// Whether to announce time changes to screen readers as an accessibility live region.
  /// Defaults to false to prevent accessibility spam.
  final bool liveRegion;

  /// Owner-provided visibility for periodic updates; it does not hide layout.
  final bool visible;

  /// Creates a time display.
  const AnimalTime({
    super.key,
    this.time,
    this.live = false,
    this.clock = const SystemClock(),
    this.liveRegion = false,
    this.visible = true,
  });

  @override
  State<AnimalTime> createState() => _AnimalTimeState();
}

class _AnimalTimeState extends State<AnimalTime> {
  late DateTime _currentTime;
  late AnimalMotionScheduler _motionScheduler;
  late AnimalMotionRegistration _readout;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.time ?? widget.clock.now();
    _motionScheduler = AnimalMotionScheduler(clock: widget.clock);
    _readout = _motionScheduler.schedulePeriodic(
      interval: const Duration(seconds: 1),
      work: AnimalScheduledWork.functionalTime,
      eligible: false,
      onTick: (_, _) => _refreshFromWallClock(),
      onResume: _refreshFromWallClock,
    );
  }

  void _refreshFromWallClock() {
    if (!mounted) return;
    setState(() => _currentTime = widget.clock.now());
  }

  void _syncEligibility() {
    _readout.setEligible(
      widget.live &&
          AnimalMotionPolicy.functionalTimeContextEligible(
            context,
            visible: widget.visible,
          ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEligibility();
  }

  @override
  void didUpdateWidget(covariant AnimalTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live != widget.live ||
        oldWidget.time != widget.time ||
        oldWidget.clock != widget.clock) {
      if (oldWidget.clock != widget.clock) {
        _motionScheduler.updateClock(widget.clock);
      }
      _currentTime = widget.time ?? widget.clock.now();
    }
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
    final localizations = AnimalLocalizations.of(context)!;
    final timeText = DateFormat.Hms(Localizations.localeOf(context).toString())
        .format(_currentTime);

    return Semantics(
      container: true,
      excludeSemantics: true,
      liveRegion: widget.liveRegion,
      label: localizations.currentTimeLabel,
      value: timeText,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg + theme.spacing.xxs,
          vertical: theme.spacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.colors.bgContent,
          borderRadius: theme.radii.cardBorder,
          border: Border.all(color: theme.colors.border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimalIcon(
              data: AnimalIcons.clock,
              size: 20,
              color: theme.colors.primaryText,
            ),
            SizedBox(width: theme.spacing.sm),
            Text(
              timeText,
              style: theme.typography.heading
                  .apply(fontSizeFactor: 0.9)
                  .copyWith(color: theme.colors.text),
            ),
          ],
        ),
      ),
    );
  }
}

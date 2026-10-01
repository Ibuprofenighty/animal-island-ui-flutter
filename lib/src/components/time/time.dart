import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../foundation/models/clock.dart';

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

  const AnimalTime({
    super.key,
    this.time,
    this.live = false,
    this.clock = const SystemClock(),
    this.liveRegion = false,
  });

  @override
  State<AnimalTime> createState() => _AnimalTimeState();
}

class _AnimalTimeState extends State<AnimalTime> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.time ?? widget.clock.now();
    _syncTimer();
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.live) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _currentTime = widget.clock.now());
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimalTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live != widget.live ||
        oldWidget.time != widget.time ||
        oldWidget.clock != widget.clock) {
      _currentTime = widget.time ?? widget.clock.now();
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
              style: theme.typography.heading.copyWith(
                fontSize: theme.typography.heading.fontSize! * 0.9,
                color: theme.colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

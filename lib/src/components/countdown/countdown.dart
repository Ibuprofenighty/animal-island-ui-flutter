import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../foundation/models/clock.dart';

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

/// SOTA Animal Island 900-weight digit tile countdown (C28).
///
/// Features:
/// - Unified deadline and duration scheduling with monotonic decrement.
/// - Deterministic [AnimalClock] integration (defaults to [SystemClock], injectable with [FakeClock]).
/// - Exactly-once [onFinish] execution guarantee across initial zero, deadline expiration, and widget updates.
/// - Flexible format templating ('DD:HH:mm:ss', 'HH:mm:ss', 'mm:ss', 'ss').
class AnimalCountdown extends StatefulWidget {
  /// The future target time to count down to.
  final DateTime? targetTime;

  /// Initial duration remaining. Either [targetTime] or [remaining] must be supplied.
  final Duration? remaining;

  /// Display format template (e.g. 'DD:HH:mm:ss', 'HH:mm:ss', 'mm:ss', 'ss'). Default 'HH:mm:ss'.
  final String format;

  /// Prefix widget placed to the left of the countdown tiles.
  final Widget? prefix;

  /// Size preset.
  final AnimalCountdownSize size;

  /// Visual style variant.
  final AnimalCountdownVariant variant;

  /// Whether the digit tile has a solid outline border.
  final bool bordered;

  /// Optional clock source for deterministic scheduling and testing.
  final AnimalClock clock;

  /// Callback triggered on each second tick with remaining duration.
  final ValueChanged<Duration>? onChange;

  /// Callback triggered once when the countdown reaches zero.
  final VoidCallback? onFinish;

  const AnimalCountdown({
    super.key,
    this.targetTime,
    this.remaining,
    this.format = 'HH:mm:ss',
    this.prefix,
    this.size = AnimalCountdownSize.middle,
    this.variant = AnimalCountdownVariant.standard,
    this.bordered = true,
    this.clock = const SystemClock(),
    this.onChange,
    this.onFinish,
  }) : assert(
         targetTime != null || remaining != null,
         'Either targetTime or remaining must be non-null',
       );

  @override
  State<AnimalCountdown> createState() => _AnimalCountdownState();
}

class _AnimalCountdownState extends State<AnimalCountdown> {
  Timer? _timer;
  late Duration _remaining;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    if (_remaining.inSeconds > 0) {
      _startTimer();
    } else {
      _finished = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFinish?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimalCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime ||
        oldWidget.remaining != widget.remaining ||
        oldWidget.clock != widget.clock) {
      _timer?.cancel();
      _remaining = _calculateRemaining();
      if (_remaining.inSeconds <= 0) {
        if (!_finished) {
          _finished = true;
          widget.onFinish?.call();
        }
      } else {
        _finished = false;
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateRemaining() {
    if (widget.targetTime != null) {
      final now = widget.clock.now();
      final diff = widget.targetTime!.difference(now);
      if (diff.inMilliseconds <= 0) return Duration.zero;
      final roundedSec = ((diff.inMilliseconds + 500) ~/ 1000);
      return Duration(seconds: roundedSec);
    }
    if (widget.remaining != null) {
      return widget.remaining!;
    }
    return Duration.zero;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (widget.targetTime != null) {
        final current = _calculateRemaining();
        if (current.inSeconds <= 0) {
          _timer?.cancel();
          setState(() {
            _remaining = Duration.zero;
          });
          if (!_finished) {
            _finished = true;
            widget.onFinish?.call();
          }
        } else {
          setState(() {
            _remaining = current;
          });
          widget.onChange?.call(_remaining);
        }
      } else {
        // Remaining mode: monotonically decrement by 1 second
        if (_remaining.inSeconds <= 1) {
          _timer?.cancel();
          setState(() {
            _remaining = Duration.zero;
          });
          if (!_finished) {
            _finished = true;
            widget.onFinish?.call();
          }
        } else {
          setState(() {
            _remaining = _remaining - const Duration(seconds: 1);
          });
          widget.onChange?.call(_remaining);
        }
      }
    });
  }

  (double width, double height, double fontSize, double labelSize)
  _resolveSizes(AnimalIslandTheme theme) {
    switch (widget.size) {
      case AnimalCountdownSize.small:
        return (
          40.0,
          36.0,
          theme.typography.countdown.fontSize! * (15 / 28),
          theme.typography.caption.fontSize! * (9 / 12),
        );
      case AnimalCountdownSize.middle:
        return (
          54.0,
          48.0,
          theme.typography.countdown.fontSize! * (22 / 28),
          theme.typography.caption.fontSize! * (10 / 12),
        );
      case AnimalCountdownSize.large:
        return (
          68.0,
          60.0,
          theme.typography.countdown.fontSize!,
          theme.typography.caption.fontSize! * (11 / 12),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AnimalLocalizations.of(context)!;
    final theme = AnimalIslandTheme.of(context);
    final hasDays = widget.format.contains('DD');
    final hasHours = widget.format.contains('HH');
    final hasMins = widget.format.contains('mm');
    final hasSecs = widget.format.contains('ss');

    final int days;
    final int hours;
    final int minutes;
    final int seconds;

    if (hasDays) {
      days = _remaining.inDays;
      hours = _remaining.inHours % 24;
      minutes = _remaining.inMinutes % 60;
      seconds = _remaining.inSeconds % 60;
    } else if (hasHours) {
      days = 0;
      hours = _remaining.inHours;
      minutes = _remaining.inMinutes % 60;
      seconds = _remaining.inSeconds % 60;
    } else if (hasMins) {
      days = 0;
      hours = 0;
      minutes = _remaining.inMinutes;
      seconds = _remaining.inSeconds % 60;
    } else {
      days = 0;
      hours = 0;
      minutes = 0;
      seconds = _remaining.inSeconds;
    }

    final tiles = <Widget>[];

    if (hasDays) {
      tiles.add(
        _buildTile(
          days.toString().padLeft(2, '0'),
          localizations.countdownUnitDays,
          theme,
        ),
      );
    }
    if (hasHours) {
      if (tiles.isNotEmpty) tiles.add(_buildSeparator(theme));
      tiles.add(
        _buildTile(
          hours.toString().padLeft(2, '0'),
          localizations.countdownUnitHours,
          theme,
        ),
      );
    }
    if (hasMins) {
      if (tiles.isNotEmpty) tiles.add(_buildSeparator(theme));
      tiles.add(
        _buildTile(
          minutes.toString().padLeft(2, '0'),
          localizations.countdownUnitMinutes,
          theme,
        ),
      );
    }
    if (hasSecs || tiles.isEmpty) {
      if (tiles.isNotEmpty) tiles.add(_buildSeparator(theme));
      tiles.add(
        _buildTile(
          seconds.toString().padLeft(2, '0'),
          localizations.countdownUnitSeconds,
          theme,
        ),
      );
    }

    return Semantics(
      container: true,
      label: localizations.countdownRemaining(_remaining.inSeconds),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            SizedBox(width: theme.spacing.sm),
          ],
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildTile(String value, String label, AnimalIslandTheme theme) {
    final (w, h, fontSz, labelSz) = _resolveSizes(theme);
    final isDark = theme.colors.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colors.border : theme.colors.borderLight;
    final tileBg = widget.variant == AnimalCountdownVariant.island
        ? theme.colors.surfaceAlt
        : theme.colors.bgContent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(
              theme.radii.sm *
                  (widget.size == AnimalCountdownSize.large ? 1.5 : 7 / 6),
            ),
            border: widget.bordered
                ? Border.all(
                    color: widget.variant == AnimalCountdownVariant.island
                        ? (isDark
                              ? theme.colors.primary.withValues(alpha: 0.5)
                              : theme.colors.primary.withValues(alpha: 0.35))
                        : borderColor,
                    width: 1.5,
                  )
                : null,
            boxShadow: [theme.shadows.input3d],
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: theme.typography.countdown.copyWith(
              fontSize: fontSz,
              color: theme.colors.text,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.sm - theme.spacing.xxs),
        Text(
          label,
          style: theme.typography.caption.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: labelSz,
            color: theme.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(AnimalIslandTheme theme) {
    final (_, _, fontSz, _) = _resolveSizes(theme);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.size == AnimalCountdownSize.small
            ? theme.spacing.xxs + theme.spacing.xxs / 2
            : theme.spacing.sm - theme.spacing.xxs,
        vertical: theme.spacing.sm,
      ),
      child: Text(
        ':',
        style: theme.typography.countdown.copyWith(
          fontSize: fontSz,
          fontWeight: FontWeight.w900,
          color: theme.colors.text,
        ),
      ),
    );
  }
}

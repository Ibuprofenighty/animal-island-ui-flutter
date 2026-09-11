import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../tokens/colors.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';

/// Size presets for [AnimalCountdown].
enum AnimalCountdownSize {
  /// Compact size (36x34px tiles).
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

/// SOTA Animal Island 900-weight digit tile countdown.
///
/// Features a self-driven real-time ticker, [onFinish] completion callback,
/// format template customization, and responsive dark mode support.
class AnimalCountdown extends StatefulWidget {
  /// The future target time to count down to.
  final DateTime? targetTime;

  /// Initial duration remaining. Either [targetTime] or [remaining] must be supplied.
  final Duration? remaining;

  /// Display format (e.g. 'DD:HH:mm:ss', 'HH:mm:ss', 'mm:ss', 'ss'). Default 'HH:mm:ss'.
  final String format;

  /// Prefix widget placed to the left of the countdown tiles.
  final Widget? prefix;

  /// Size preset.
  final AnimalCountdownSize size;

  /// Visual style variant.
  final AnimalCountdownVariant variant;

  /// Whether the digit tile has a solid outline border.
  final bool bordered;

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
    this.onChange,
    this.onFinish,
  }) : assert(targetTime != null || remaining != null, 'Either targetTime or remaining must be non-null');

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
    _remaining = _calculateInitialRemaining();
    if (_remaining.inSeconds > 0) {
      _startTimer();
    } else {
      _finished = true;
    }
  }

  @override
  void didUpdateWidget(AnimalCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime ||
        oldWidget.remaining != widget.remaining) {
      _timer?.cancel();
      _remaining = _calculateInitialRemaining();
      _finished = _remaining.inSeconds <= 0;
      if (!_finished) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateInitialRemaining() {
    if (widget.targetTime != null) {
      final diff = widget.targetTime!.difference(DateTime.now());
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (widget.targetTime != null) {
        final current = _calculateInitialRemaining();
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

  (double width, double height, double fontSize, double labelSize) _resolveSizes() {
    switch (widget.size) {
      case AnimalCountdownSize.small:
        return (40.0, 36.0, 15.0, 9.0);
      case AnimalCountdownSize.middle:
        return (54.0, 48.0, 22.0, 10.0);
      case AnimalCountdownSize.large:
        return (68.0, 60.0, 28.0, 11.0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      tiles.add(_buildTile(days.toString().padLeft(2, '0'), 'DAYS', theme));
    }
    if (hasHours) {
      if (tiles.isNotEmpty) tiles.add(_buildSeparator(theme));
      tiles.add(_buildTile(hours.toString().padLeft(2, '0'), 'HOURS', theme));
    }
    if (hasMins) {
      if (tiles.isNotEmpty) tiles.add(_buildSeparator(theme));
      tiles.add(_buildTile(minutes.toString().padLeft(2, '0'), 'MINS', theme));
    }
    if (hasSecs || tiles.isEmpty) {
      if (tiles.isNotEmpty) tiles.add(_buildSeparator(theme));
      tiles.add(_buildTile(seconds.toString().padLeft(2, '0'), 'SECS', theme));
    }

    return Semantics(
      liveRegion: true,
      label: 'Countdown remaining: ${_remaining.inSeconds} seconds',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            const SizedBox(width: 8.0),
          ],
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildTile(String value, String label, AnimalIslandTheme theme) {
    final (w, h, fontSz, labelSz) = _resolveSizes();
    final isDark = theme.isDark;
    final borderColor = isDark ? theme.border : AnimalColors.borderLight;
    final tileBg = widget.variant == AnimalCountdownVariant.island
        ? (isDark ? theme.surfaceHeader : const Color(0xFFFFFDF8))
        : theme.bgContent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(widget.size == AnimalCountdownSize.large ? 18.0 : 14.0),
            border: widget.bordered
                ? Border.all(
                    color: widget.variant == AnimalCountdownVariant.island
                        ? (isDark ? theme.primary.withValues(alpha: 0.5) : theme.primary.withValues(alpha: 0.35))
                        : borderColor,
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x33000000) : AnimalColors.shadowInput,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AnimalTypography.countdown.copyWith(
              fontSize: fontSz,
              color: theme.text,
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          label,
          style: AnimalTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: labelSz,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(AnimalIslandTheme theme) {
    final (_, _, fontSz, _) = _resolveSizes();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.size == AnimalCountdownSize.small ? 3.0 : 6.0,
        vertical: 8.0,
      ),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: fontSz,
          fontWeight: FontWeight.w900,
          color: theme.text,
        ),
      ),
    );
  }
}

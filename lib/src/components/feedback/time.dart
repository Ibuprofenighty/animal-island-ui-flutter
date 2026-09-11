import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';

/// Animal Island clock display card.
class AnimalTime extends StatefulWidget {
  final DateTime? time;
  final bool live;

  const AnimalTime({
    super.key,
    this.time,
    this.live = false,
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
    _currentTime = widget.time ?? DateTime.now();
    if (widget.live) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _currentTime = DateTime.now());
      });
    }
  }

  @override
  void didUpdateWidget(AnimalTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live != widget.live || oldWidget.time != widget.time) {
      _timer?.cancel();
      _currentTime = widget.time ?? DateTime.now();
      if (widget.live) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => _currentTime = DateTime.now());
        });
      }
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
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final min = _currentTime.minute.toString().padLeft(2, '0');
    final sec = _currentTime.second.toString().padLeft(2, '0');

    return Semantics(
      liveRegion: widget.live,
      label: '当前时间',
      value: '$hour:$min:$sec',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.bgContent,
          borderRadius: AnimalRadii.cardBorder,
          border: Border.all(
            color: theme.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClockIcon(size: 20, color: theme.primary),
            const SizedBox(width: 8.0),
            Text(
              '$hour:$min:$sec',
              style: AnimalTypography.heading.copyWith(
                fontSize: 18.0,
                color: theme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

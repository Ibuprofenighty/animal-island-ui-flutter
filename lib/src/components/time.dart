import '../internal/surface_motion.dart';
import '../foundation/theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';

/// A wall-clock display. [now] supplies local time and may be replaced for a
/// deterministic preview. This instance owns and cancels its refresh timer.
class IslandTime extends StatefulWidget {
  const IslandTime({super.key, this.now, this.semanticLabel});
  final DateTime Function()? now;
  final String? semanticLabel;
  @override
  State<IslandTime> createState() => _IslandTimeState();
}

class _IslandTimeState extends State<IslandTime>
    with SingleTickerProviderStateMixin {
  late DateTime current;
  Timer? timer;
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
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String pad(int n) => n.toString().padLeft(2, '0');
    final date = '${months[current.month - 1]} ${current.day}';
    final clock = '${pad(current.hour)}:${pad(current.minute)}';
    return Semantics(
      label: widget.semanticLabel,
      value: '$clock ${days[current.weekday - 1]} $date',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: motion,
          builder: (_, child) => SurfaceMotion(
            progress: Curves.ease.transform(motion.value),
            offset: const Offset(0, 4),
            child: child!,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 15),
            decoration: BoxDecoration(
              color: const Color(0xfff8f8f0),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0f3d3428),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: Color(0xff794f27),
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pad(current.hour)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Transform.translate(
                          offset: const Offset(0, -4.84),
                          child: const Text(':'),
                        ),
                      ),
                      Text(pad(current.minute)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffe6f9f6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      color: IslandTokens.light.muted,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          days[current.weekday - 1],
                          style: TextStyle(
                            color: IslandTokens.light.link,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '·',
                            style: TextStyle(color: IslandTokens.light.muted),
                          ),
                        ),
                        Text(date),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

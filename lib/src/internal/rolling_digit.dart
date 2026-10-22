import 'package:flutter/material.dart';

/// A downward odometer transition; each digit owns only its visual interpolation.
class RollingDigit extends StatefulWidget {
  const RollingDigit({super.key, required this.digit, required this.style});
  final int digit;
  final TextStyle style;
  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late double from = widget.digit.toDouble(), to = from;
  double get position =>
      from + (to - from) * Curves.fastOutSlowIn.transform(controller.value);
  bool reduced = false;
  void settle() {
    controller.stop();
    from = to = widget.digit.toDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) settle();
  }

  @override
  void didUpdateWidget(RollingDigit old) {
    super.didUpdateWidget(old);
    if (reduced) {
      settle();
    } else if (old.digit != widget.digit) {
      from = position;
      final normalized = from % 10;
      to = from - ((normalized - widget.digit + 10) % 10);
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: widget.style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    final height = painter.height;
    painter.dispose();
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, _) {
            final value = MediaQuery.disableAnimationsOf(context)
                ? widget.digit.toDouble()
                : position;
            final base = value.floor();
            final fraction = value - base;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < 2; i++)
                  Positioned(
                    top: (i - fraction) * height,
                    left: 0,
                    right: 0,
                    height: height,
                    child: Text(
                      ((base + i) % 10).toString(),
                      style: widget.style,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../internal/content_scope.dart';
import '../foundation/theme.dart';
import '../internal/number_plate.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/size.dart';
import '../internal/number_surface.dart';
import '../internal/rolling_digit.dart';

enum IslandCountdownVariant { normal, island }

class IslandCountdown extends StatefulWidget {
  const IslandCountdown({
    super.key,
    required this.value,
    this.format = 'HH:mm:ss',
    this.prefix,
    this.size = IslandSize.middle,
    this.variant = IslandCountdownVariant.normal,
    this.bordered = false,
    this.onChange,
    this.onFinish,
    this.now,
  });
  final DateTime value;
  final String format;
  final Widget? prefix;
  final IslandSize size;
  final IslandCountdownVariant variant;
  final bool bordered;
  final ValueChanged<Duration>? onChange;
  final VoidCallback? onFinish;
  final DateTime Function()? now;
  @override
  State<IslandCountdown> createState() => _IslandCountdownState();
}

class _IslandCountdownState extends State<IslandCountdown> {
  Timer? timer;
  int generation = 0;
  bool finished = false;
  late int remaining = read();
  int read() => math.max(
    0,
    widget.value
        .difference(widget.now?.call() ?? DateTime.now())
        .inMilliseconds,
  );
  @override
  void initState() {
    super.initState();
    restart();
  }

  @override
  void didUpdateWidget(IslandCountdown old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value || old.now != widget.now) restart();
  }

  void restart() {
    timer?.cancel();
    final token = ++generation;
    finished = false;
    remaining = read();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || token != generation) return;
      update();
      if (mounted && token == generation && !finished) {
        timer = Timer.periodic(
          const Duration(milliseconds: 250),
          (_) => update(),
        );
      }
    });
  }

  void update() {
    final token = generation;
    final next = read();
    if (next != remaining) setState(() => remaining = next);
    final completes = next == 0 && !finished;
    if (completes) {
      finished = true;
      timer?.cancel();
    }
    widget.onChange?.call(Duration(milliseconds: next));
    if (!mounted || token != generation) return;
    if (completes) widget.onFinish?.call();
  }

  @override
  void dispose() {
    generation++;
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = (remaining / 1000).ceil();
    final values = <String, int>{
      'DD': seconds ~/ 86400,
      'HH': widget.format.contains('DD')
          ? (seconds % 86400) ~/ 3600
          : seconds ~/ 3600,
      'mm': (seconds % 3600) ~/ 60,
      'ss': seconds % 60,
    };
    final parts = <(bool, String)>[];
    var end = 0;
    for (final match in RegExp('DD|HH|mm|ss').allMatches(widget.format)) {
      if (match.start > end)
        parts.add((false, widget.format.substring(end, match.start)));
      parts.add((true, values[match[0]]!.toString().padLeft(2, '0')));
      end = match.end;
    }
    if (end < widget.format.length)
      parts.add((false, widget.format.substring(end)));
    final font = switch (widget.size) {
      IslandSize.small => 20.0,
      IslandSize.middle => 26.0,
      IslandSize.large => 34.0,
    };
    final bodyFont = switch (widget.size) {
      IslandSize.small => 13.0,
      IslandSize.middle => 14.0,
      IslandSize.large => 16.0,
    };
    final island = widget.variant == IslandCountdownVariant.island;
    final digitStyle = DefaultTextStyle.of(context).style.copyWith(
      color: IslandTokens.light.ink,
      fontSize: font,
      height: 1.2,
      letterSpacing: 0,
      fontWeight: FontWeight.w900,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget group = OverflowBox(
      minWidth: 0,
      maxWidth: double.infinity,
      fit: OverflowBoxFit.deferToChild,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < parts.length; index++) ...[
            if (index != 0) const SizedBox(width: 6),
            if (parts[index].$1)
              NumberPlate(
                island: island,
                bordered: widget.bordered,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var d = 0; d < parts[index].$2.length; d++) ...[
                      if (d != 0) const SizedBox(width: 3),
                      RollingDigit(
                        key: ValueKey((index, d)),
                        digit: int.parse(parts[index].$2[d]),
                        style: digitStyle,
                      ),
                    ],
                  ],
                ),
              )
            else
              Transform.translate(
                offset: Offset(
                  0,
                  parts[index].$2.contains(RegExp('[:：]')) ? -font * .08 : 0,
                ),
                child: Text(
                  parts[index].$2,
                  style: digitStyle.copyWith(
                    fontSize: parts[index].$2.contains(RegExp('[:：]'))
                        ? font
                        : bodyFont,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
    group = Semantics(
      value: parts.map((p) => p.$2).join(),
      child: ExcludeSemantics(child: group),
    );
    return NumberSurface(
      island: island,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (widget.prefix != null)
            ContentScope(
              textStyle: TextStyle(
                color: IslandTokens.light.muted,
                fontSize: bodyFont,
                fontWeight: FontWeight.w600,
              ),
              child: widget.prefix!,
            ),
          group,
        ],
      ),
    );
  }
}

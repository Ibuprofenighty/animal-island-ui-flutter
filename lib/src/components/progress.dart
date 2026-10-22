import '../foundation/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/size.dart';
import '../foundation/scene.dart';

class IslandProgress extends StatelessWidget {
  const IslandProgress({
    super.key,
    required this.percent,
    required this.label,
    this.size = IslandSize.middle,
    this.scene,
    this.showInfo = true,
    this.infoBuilder,
    this.semanticValue,
    this.duration = const Duration(milliseconds: 600),
  });
  final double percent;
  final String label;
  final IslandSize size;
  final IslandScene? scene;
  final bool showInfo;
  final Widget Function(double percent)? infoBuilder;
  final String Function(double percent)? semanticValue;
  final Duration duration;
  double get safePercent => percent.isNaN ? 0 : percent.clamp(0, 100);
  @override
  Widget build(BuildContext context) {
    final value = safePercent;
    final height = switch (size) {
      IslandSize.small => 14.0,
      IslandSize.middle => 24.0,
      IslandSize.large => 32.0,
    };
    return Semantics(
      label: label,
      value: semanticValue?.call(value) ?? '${value.round()}%',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xfff8f8f0),
                  border: Border.all(
                    color: IslandTokens.light.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LayoutBuilder(
                    builder: (_, constraints) => CustomPaint(
                      painter: const _TrackDots(),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: value / 100),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : duration,
                        curve: Curves.fastOutSlowIn,
                        builder: (_, fraction, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: constraints.maxWidth * fraction,
                            height: height,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (scene == null)
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: value.round() == 100
                                              ? const [
                                                  Color(0xff7fe0d5),
                                                  Color(0xff3dd4c6),
                                                ]
                                              : const [
                                                  Color(0xff3dd4c6),
                                                  Color(0xff19c8b9),
                                                  Color(0xff14b6a8),
                                                ],
                                          stops: value.round() == 100
                                              ? null
                                              : const [0, .6, 1],
                                        ),
                                      ),
                                    )
                                  else
                                    OverflowBox(
                                      alignment: Alignment.topLeft,
                                      minWidth: constraints.maxWidth,
                                      maxWidth: constraints.maxWidth,
                                      child: SvgPicture.asset(
                                        'assets/scenes/${scene!.assetName}.svg',
                                        package: 'animal_island_ui',
                                        width: constraints.maxWidth,
                                        fit: BoxFit.fitWidth,
                                        alignment: Alignment.topLeft,
                                      ),
                                    ),
                                  const Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 2,
                                    child: ColoredBox(color: Color(0x73ffffff)),
                                  ),
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: IslandTokens.light.onLeaf,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: IslandTheme.of(context).ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1,
                    letterSpacing: .32,
                  ),
                  textAlign: TextAlign.right,
                  child: infoBuilder?.call(value) ?? Text('${value.round()}%'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackDots extends CustomPainter {
  const _TrackDots();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x1ac4b89e);
    for (double x = 0; x < size.width; x += 14) {
      for (double y = 0; y < size.height; y += 14) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_TrackDots old) => false;
}

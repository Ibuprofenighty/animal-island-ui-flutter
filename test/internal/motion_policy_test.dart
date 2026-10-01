import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/src/internal/timing/motion_policy.dart';

import '../support/fake_clock.dart';

void main() {
  group('Timing & MotionPolicy Tests (S04 / T04.03)', () {
    test('FakeClock allows deterministic time progression', () {
      final base = DateTime(2026, 9, 12, 12, 0, 0);
      final clock = FakeClock(base);

      expect(clock.now(), base);
      clock.advance(const Duration(seconds: 42));
      expect(clock.now(), base.add(const Duration(seconds: 42)));
      expect(clock.elapsed(base), const Duration(seconds: 42));
    });

    testWidgets('MotionPolicy respects disableAnimations MediaQuery flag', (
      tester,
    ) async {
      bool? animatedNormal;
      bool? animatedDisabled;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              animatedNormal = AnimalMotionPolicy.shouldAnimate(context);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              animatedDisabled = AnimalMotionPolicy.shouldAnimate(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(animatedNormal, isTrue);
      expect(animatedDisabled, isFalse);
    });
  });
}

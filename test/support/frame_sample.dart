import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Time and value are observed inside the same completed frame. This works
/// with both fake and live clocks without assuming pump-request duration.
Future<({Duration stamp, T value})> sampleFrame<T>(
  WidgetTester tester,
  T Function() read,
) async {
  final result = Completer<({Duration stamp, T value})>();
  tester.binding.addPostFrameCallback((stamp) {
    try {
      result.complete((stamp: stamp, value: read()));
    } catch (error, stack) {
      result.completeError(error, stack);
    }
  });
  tester.binding.scheduleFrame();
  await tester.pump();
  return result.future;
}

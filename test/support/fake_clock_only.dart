import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// True when tests run on the real engine (integration binding).
///
/// Pass as `skip:` for oracles that sample an animation at exact elapsed
/// times. They need the fake clock of `flutter test`; on the real engine
/// `pump(duration)` waits real time, so the sampled phase drifts and the
/// oracle measures the host, not the component. The same files run under
/// the fake clock in the root and Gallery test steps, which keep these
/// oracles enforced. Use it only for exact-time sampling, never to hide a
/// behaviour failure.
bool get fakeClockOnly {
  try {
    return WidgetsBinding.instance is LiveTestWidgetsFlutterBinding;
  } catch (_) {
    return false;
  }
}

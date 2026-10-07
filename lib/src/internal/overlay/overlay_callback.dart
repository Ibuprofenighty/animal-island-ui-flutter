import 'package:flutter/foundation.dart';

/// Runs a caller-supplied overlay [callback] and reports what it throws
/// through [FlutterError.reportError], so one failing callback never stops
/// the settlement of the other occurrences or resources in the same batch.
///
/// [action] completes the diagnostic, for example `running an overlay onClose
/// callback`.
void runOverlayCallback(VoidCallback callback, String action) {
  try {
    callback();
  } catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'animal_island_ui',
        context: ErrorDescription('while $action'),
      ),
    );
  }
}

part of 'upload.dart';

enum IslandUploadStatus { uploading, done, error, removed }

enum IslandUploadListType { text, picture, pictureCard }

/// Where an uploading file shows its [IslandUploadProgress].
enum IslandUploadProgressType {
  /// A separate small progress bar: below the file name in a row, under the
  /// percentage inside a picture card.
  bar,

  /// The whole row or card backing fills from the left; it takes no layout
  /// space.
  background,
}

/// Appearance of upload progress. The percentage always comes from the file.
///
/// Only uploading files show it; done and failed files keep their status
/// icons.
@immutable
class IslandUploadProgress {
  const IslandUploadProgress({
    this.type = IslandUploadProgressType.bar,
    this.color,
    this.wave = false,
    this.animated = true,
    this.showInfo = true,
    this.duration = const Duration(milliseconds: 600),
  });

  /// Separate bar or background fill.
  final IslandUploadProgressType type;

  /// Fill colour; null keeps the mint bar gradient or the mint background.
  final Color? color;

  /// Overlays the double-layer ocean wave on the fill.
  final bool wave;

  /// Whether the [wave] drifts; it is still at 0% and 100%.
  final bool animated;

  /// Shows the percentage text.
  final bool showInfo;

  /// Fill width transition; zero disables it.
  final Duration duration;
}

typedef IslandUploadPreviewBuilder = Widget Function(
  BuildContext context,
  BoxFit fit,
);

@immutable
class IslandUploadSource {
  const IslandUploadSource({
    required this.name,
    required this.size,
    required this.openRead,
    this.mimeType = '',
    this.thumbnail,
    this.thumbnailBuilder,
  });
  final String name, mimeType;
  final int size;
  final Stream<List<int>> Function() openRead;
  final ImageProvider? thumbnail;

  /// Opaque preview content. The builder receives bounded thumbnail/lightbox constraints.
  final IslandUploadPreviewBuilder? thumbnailBuilder;
}

@immutable
class IslandUploadFile {
  const IslandUploadFile({
    required this.id,
    required this.name,
    this.size,
    this.mimeType = '',
    this.status = IslandUploadStatus.uploading,
    this.percent = 0,
    this.source,
    this.thumbnail,
    this.thumbnailBuilder,
    this.response,
    this.error,
  });
  final String id, name, mimeType;

  /// File size in bytes; null when unknown, and the list then shows no size.
  final int? size;
  final IslandUploadStatus status;
  final double percent;
  final IslandUploadSource? source;
  final ImageProvider? thumbnail;

  /// Opaque preview content. The builder receives bounded thumbnail/lightbox constraints.
  final IslandUploadPreviewBuilder? thumbnailBuilder;
  final Object? response, error;
  IslandUploadFile copyWith({
    IslandUploadStatus? status,
    double? percent,
    Object? response,
    Object? error,
  }) => IslandUploadFile(
    id: id,
    name: name,
    size: size,
    mimeType: mimeType,
    status: status ?? this.status,
    percent: percent ?? this.percent,
    source: source,
    thumbnail: thumbnail,
    thumbnailBuilder: thumbnailBuilder,
    response: response ?? this.response,
    error: error ?? this.error,
  );
}

@immutable
class IslandUploadChange {
  IslandUploadChange(this.file, List<IslandUploadFile> files)
    : files = List.unmodifiable(files);
  final IslandUploadFile file;
  final List<IslandUploadFile> files;
}

class IslandUploadCancellation {
  bool _cancelled = false;
  final _listeners = <VoidCallback>{};
  bool get isCancelled => _cancelled;
  void addListener(VoidCallback listener) {
    if (_cancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _cancel() {
    if (_cancelled) return;
    _cancelled = true;
    final listeners = List.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      try {
        listener();
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'animal_island_ui Upload cancellation',
          ),
        );
      }
    }
  }
}

class IslandUploadTransfer {
  const IslandUploadTransfer({
    required this.file,
    required this.onProgress,
    required this.cancellation,
  });
  final IslandUploadSource file;
  final ValueChanged<double> onProgress;
  final IslandUploadCancellation cancellation;
}

typedef IslandUploadRequest = Future<Object?> Function(
  IslandUploadTransfer transfer,
);
typedef IslandUploadPicker = Future<List<IslandUploadSource>> Function({
  required bool multiple,
  required String accept,
});
typedef IslandUploadDropBuilder = Widget Function(
  BuildContext context,
  Widget child,
  bool enabled,
  ValueChanged<List<IslandUploadSource>> onDrop,
  ValueChanged<bool> onHover,
);
typedef IslandUploadBefore = FutureOr<IslandUploadSource?> Function(
  IslandUploadSource file,
  List<IslandUploadSource> batch,
);

/// Explicit demo transport. It creates no network request and cancels its timer.
IslandUploadRequest islandSimulatedUpload({
  Duration interval = const Duration(milliseconds: 200),
  double step = 20,
}) {
  if (interval <= Duration.zero || step <= 0 || !step.isFinite)
    throw ArgumentError('Simulation interval and step must be positive.');
  return (transfer) {
    final result = Completer<Object?>();
    Timer? timer;
    void cancel() {
      timer?.cancel();
      if (!result.isCompleted) result.complete(null);
    }

    if (transfer.cancellation.isCancelled) return Future.value(null);
    transfer.cancellation.addListener(cancel);
    var percent = 0.0;
    timer = Timer.periodic(interval, (_) {
      if (transfer.cancellation.isCancelled) {
        cancel();
        return;
      }
      percent = (percent + step).clamp(0, 100);
      transfer.onProgress(percent);
      if (percent >= 100) {
        timer?.cancel();
        transfer.cancellation.removeListener(cancel);
        if (!result.isCompleted) result.complete(null);
      }
    });
    return result.future;
  };
}

class _UploadJob {
  _UploadJob(this.file, this.request);
  final IslandUploadFile file;
  final IslandUploadRequest request;
  final cancellation = IslandUploadCancellation();
  double? pendingProgress;
  bool flushingProgress = false, finishing = false;
}

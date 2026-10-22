/// Optional Windows/Web IO adapters. Core widgets depend only on typed callbacks.
library;

import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'animal_island_ui.dart';
import 'src/internal/upload_http_client.dart';

/// Reads only a file explicitly selected or dropped by the host user.
Future<IslandUploadSource> islandUploadSource(XFile file) async {
  final mime =
      file.mimeType ??
      MultipartFile.lookupMediaType(file.name)?.toString() ??
      '';
  return IslandUploadSource(
    name: file.name,
    size: await file.length(),
    mimeType: mime,
    openRead: file.openRead,
    thumbnailBuilder: mime.startsWith('image/')
        ? (_, fit) => _FilePreview(
            file: file,
            vector: mime == 'image/svg+xml',
            fit: fit,
          )
        : null,
  );
}

/// Platform filter is a convenience; IslandUpload also enforces accept on ingestion.
Future<List<IslandUploadSource>> islandPickFiles({
  required bool multiple,
  required String accept,
}) async {
  final patterns = accept
      .split(',')
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toList();
  const types = <String, List<String>>{
    'image/*': [
      'png',
      'jpg',
      'jpeg',
      'gif',
      'webp',
      'svg',
      'bmp',
      'ico',
      'avif',
    ],
    'application/pdf': ['pdf'],
    'text/plain': ['txt'],
    'text/csv': ['csv'],
    'image/png': ['png'],
    'image/jpeg': ['jpg', 'jpeg'],
    'image/svg+xml': ['svg'],
    'audio/*': ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'],
    'video/*': ['mp4', 'webm', 'mov', 'avi', 'mkv'],
  };
  final extensions = <String>{};
  var fullyMapped = true;
  for (final p in patterns) {
    if (p.startsWith('.')) {
      extensions.add(p.substring(1));
    } else if (types.containsKey(p)) {
      extensions.addAll(types[p]!);
    } else {
      fullyMapped = false;
    }
  }
  final groups = <XTypeGroup>[
    if (patterns.isNotEmpty && (kIsWeb || fullyMapped))
      XTypeGroup(
        label: accept,
        extensions: extensions.isEmpty ? null : extensions.toList(),
        mimeTypes: kIsWeb
            ? patterns.where((p) => !p.startsWith('.')).toList()
            : null,
      ),
  ];
  final selected = multiple
      ? await openFiles(acceptedTypeGroups: groups)
      : [if (await openFile(acceptedTypeGroups: groups) case final file?) file];
  return Future.wait(selected.map(islandUploadSource));
}

Widget islandFileDrop(
  BuildContext context,
  Widget child,
  bool enabled,
  ValueChanged<List<IslandUploadSource>> onDrop,
  ValueChanged<bool> onHover,
) =>
    _FileDrop(enabled: enabled, onDrop: onDrop, onHover: onHover, child: child);

class _FileDrop extends StatefulWidget {
  const _FileDrop({
    required this.enabled,
    required this.onDrop,
    required this.onHover,
    required this.child,
  });
  final bool enabled;
  final ValueChanged<List<IslandUploadSource>> onDrop;
  final ValueChanged<bool> onHover;
  final Widget child;
  @override
  State<_FileDrop> createState() => _FileDropState();
}

class _FileDropState extends State<_FileDrop> {
  int generation = 0;
  @override
  void didUpdateWidget(_FileDrop old) {
    super.didUpdateWidget(old);
    if (old.enabled && !widget.enabled) generation++;
  }

  @override
  void dispose() {
    generation++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DropTarget(
    enable: widget.enabled,
    onDragEntered: (_) => widget.onHover(true),
    onDragExited: (_) => widget.onHover(false),
    onDragDone: (details) async {
      widget.onHover(false);
      final ticket = generation;
      try {
        // Directory selection is not part of this file-only adapter contract.
        final files = await Future.wait(
          details.files.whereType<DropItemFile>().map(islandUploadSource),
        );
        if (mounted && widget.enabled && ticket == generation)
          widget.onDrop(files);
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'IslandUpload file drop',
          ),
        );
      }
    },
    child: widget.child,
  );
}

/// Real multipart request. Each transfer owns its client; removal/disposal aborts it.
IslandUploadRequest islandHttpUpload({
  required FutureOr<Uri> Function(IslandUploadSource file) endpoint,
  String method = 'POST',
  Map<String, String> headers = const {},
  FutureOr<Map<String, Object?>> Function(IslandUploadSource file)? data,
  String fieldName = 'file',
  bool withCredentials = false,
}) {
  final verb = method.toUpperCase();
  if (!const ['POST', 'PUT', 'PATCH'].contains(verb) || fieldName.isEmpty) {
    throw ArgumentError(
      'Upload requires POST, PUT or PATCH and a nonempty field name.',
    );
  }
  final requestHeaders = Map<String, String>.unmodifiable(headers);
  return (transfer) async {
    final client = createUploadClient(withCredentials);
    final cancel = CancelToken();
    void abort() => cancel.cancel('Upload removed or owner disposed.');
    transfer.cancellation.addListener(abort);
    try {
      if (cancel.isCancelled) return null;
      final uri = await endpoint(transfer.file);
      if (cancel.isCancelled) return null;
      if (!const ['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
        throw ArgumentError.value(
          uri,
          'endpoint',
          'Expected an absolute HTTP(S) URL',
        );
      }
      final fields = data == null
          ? <String, Object?>{}
          : await data(transfer.file);
      if (cancel.isCancelled) return null;
      final form = FormData.fromMap(fields);
      form.files.add(
        MapEntry(
          fieldName,
          MultipartFile.fromStream(
            transfer.file.openRead,
            transfer.file.size,
            filename: transfer.file.name,
            contentType: transfer.file.mimeType.isEmpty
                ? null
                : DioMediaType.parse(transfer.file.mimeType),
          ),
        ),
      );
      final response = await client.request<Object?>(
        uri.toString(),
        data: form,
        options: Options(method: verb, headers: requestHeaders),
        cancelToken: cancel,
        onSendProgress: (sent, total) {
          if (total > 0 && !cancel.isCancelled)
            transfer.onProgress(sent / total * 100);
        },
      );
      return response.data;
    } finally {
      transfer.cancellation.removeListener(abort);
      client.close(force: true);
    }
  };
}

class _FilePreview extends StatefulWidget {
  const _FilePreview({
    required this.file,
    required this.vector,
    required this.fit,
  });
  final XFile file;
  final bool vector;
  final BoxFit fit;
  @override
  State<_FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<_FilePreview> {
  late Future<Uint8List> bytes = widget.file.readAsBytes();
  @override
  void didUpdateWidget(_FilePreview old) {
    super.didUpdateWidget(old);
    if (old.file != widget.file) bytes = widget.file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: bytes,
    builder: (context, snapshot) {
      if (!snapshot.hasData)
        return const Center(child: IslandIcon(IslandGlyph.file, size: 18));
      if (widget.vector)
        return SvgPicture.memory(snapshot.data!, fit: widget.fit);
      return Image.memory(
        snapshot.data!,
        fit: widget.fit,
        errorBuilder: (_, _, _) =>
            const Center(child: IslandIcon(IslandGlyph.file, size: 18)),
      );
    },
  );
}

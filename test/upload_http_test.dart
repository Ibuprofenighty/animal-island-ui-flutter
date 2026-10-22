@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/animal_island_upload_platform.dart';

void main() {
  test(
    'real multipart adapter streams bytes, fields, method and server response',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final received = server.first.then((request) async {
        expect(request.method, 'PUT');
        expect(request.headers.value('x-island-test'), 'yes');
        final body = await utf8.decoder.bind(request).join();
        expect(body, contains('name="asset"; filename="sample.txt"'));
        expect(body, contains('SYNTHETIC-UPLOAD'));
        expect(body, contains('demo'));
        request.response.headers.contentType = ContentType.json;
        request.response.write('{"ok":true}');
        await request.response.close();
      });
      final progress = <double>[];
      final response =
          await islandHttpUpload(
            endpoint: (_) async =>
                Uri.parse('http://127.0.0.1:${server.port}/upload'),
            method: 'PUT',
            headers: {'x-island-test': 'yes'},
            data: (_) async => {'source': 'demo'},
            fieldName: 'asset',
          )(
            IslandUploadTransfer(
              file: IslandUploadSource(
                name: 'sample.txt',
                size: 16,
                mimeType: 'text/plain',
                openRead: () => Stream.value(utf8.encode('SYNTHETIC-UPLOAD')),
              ),
              onProgress: progress.add,
              cancellation: IslandUploadCancellation(),
            ),
          );
      await received;
      expect(response, {'ok': true});
      expect(progress.last, 100);
    },
  );
  test(
    'invalid endpoint and HTTP failures do not report simulated success',
    () async {
      final source = IslandUploadSource(
        name: 'sample.txt',
        size: 1,
        openRead: () => Stream.value([65]),
      );
      final transfer = IslandUploadTransfer(
        file: source,
        onProgress: (_) {},
        cancellation: IslandUploadCancellation(),
      );
      await expectLater(
        islandHttpUpload(endpoint: (_) => Uri.parse('file:///tmp/private'))(
          transfer,
        ),
        throwsArgumentError,
      );
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final received = server.first.then((r) async {
        await r.drain<void>();
        r.response.statusCode = 503;
        await r.response.close();
      });
      await expectLater(
        islandHttpUpload(
          endpoint: (_) => Uri.parse('http://127.0.0.1:${server.port}/upload'),
        )(transfer),
        throwsA(isA<Exception>()),
      );
      await received;
    },
  );
}

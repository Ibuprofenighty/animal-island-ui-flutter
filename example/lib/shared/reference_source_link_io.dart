import 'dart:io';

/// Opens [url] in the default browser (Windows desktop host).
Future<void> openExternalUrl(String url) async {
  await Process.start('rundll32.exe', [
    'url.dll,FileProtocolHandler',
    url,
  ], mode: ProcessStartMode.detached);
}

Future<void> openReferenceSource() =>
    openExternalUrl('https://github.com/guokaigdg/animal-island-ui');

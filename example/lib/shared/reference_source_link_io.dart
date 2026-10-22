import 'dart:io';

Future<void> openReferenceSource() async {
  await Process.start('rundll32.exe', [
    'url.dll,FileProtocolHandler',
    'https://github.com/guokaigdg/animal-island-ui',
  ], mode: ProcessStartMode.detached);
}

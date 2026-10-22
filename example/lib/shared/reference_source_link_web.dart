import 'dart:js_interop';

@JS('window.open')
external JSAny? _open(String url, String target, String features);

void openReferenceSource() {
  _open(
    'https://github.com/guokaigdg/animal-island-ui',
    '_blank',
    'noopener,noreferrer',
  );
}

import 'dart:js_interop';

@JS('window.open')
external JSAny? _open(String url, String target, String features);

/// Opens [url] in a new tab, like the reference `target="_blank"` links.
void openExternalUrl(String url) {
  _open(url, '_blank', 'noopener,noreferrer');
}

void openReferenceSource() =>
    openExternalUrl('https://github.com/guokaigdg/animal-island-ui');

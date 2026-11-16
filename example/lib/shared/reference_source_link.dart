// The observed Home footer action opens the pinned reference project's source;
// Gallery labels open their reference links through the same host helper.
export 'reference_source_link_io.dart'
    if (dart.library.js_interop) 'reference_source_link_web.dart';

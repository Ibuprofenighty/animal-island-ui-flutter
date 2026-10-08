import 'dart:collection';

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;

/// Maximum UTF-8 size accepted for one SVG icon.
const int maxSvgBytes = 256 * 1024;

/// Maximum number of elements accepted for one SVG icon.
const int maxSvgElements = 2000;

/// Maximum nested element depth accepted for one SVG icon.
const int maxSvgDepth = 64;

/// Structural identity for one transformed SVG.
///
/// The source string is retained in full. The tint and width fields use the
/// exact canonical text values emitted by the transformer, so values that
/// render differently cannot alias in the cache.
@immutable
final class SvgTransformKey {
  /// Creates the key of [rawSvg] tinted with [strokeColor] and stroked with
  /// [strokeWidth]; a null value leaves that attribute untransformed.
  SvgTransformKey({
    required this.rawSvg,
    Color? strokeColor,
    double? strokeWidth,
  }) : strokeColorHex = strokeColor == null ? null : _colorToHex6(strokeColor),
       strokeOpacity = strokeColor == null
           ? null
           : _formatOpacity(_opacityMilli(strokeColor.a)),
       strokeWidthText = strokeWidth == null ? null : _formatWidth(strokeWidth);

  /// Complete, unmodified SVG input; hashes are never used as identity.
  final String rawSvg;

  /// Lowercase `#rrggbb` tint text used by the XML writer.
  final String? strokeColorHex;

  /// Canonical opacity text used by the XML writer.
  final String? strokeOpacity;

  /// Canonical width text used by the XML writer.
  final String? strokeWidthText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SvgTransformKey &&
          rawSvg == other.rawSvg &&
          strokeColorHex == other.strokeColorHex &&
          strokeOpacity == other.strokeOpacity &&
          strokeWidthText == other.strokeWidthText;

  @override
  int get hashCode =>
      Object.hash(rawSvg, strokeColorHex, strokeOpacity, strokeWidthText);
}

/// One least-recently-used cache for transformed SVG markup.
final class SvgTransformCache {
  /// Maximum number of cached results.
  static const int maxEntries = 128;
  static final LinkedHashMap<SvgTransformKey, String> _cache =
      LinkedHashMap<SvgTransformKey, String>();

  /// Retrieves a cached value and marks its complete structural key recent.
  static String? get(SvgTransformKey key) {
    final String? value = _cache.remove(key);
    if (value != null) _cache[key] = value;
    return value;
  }

  /// Stores a result, evicting the least-recently-used key when full.
  static void set(SvgTransformKey key, String value) {
    _cache.remove(key);
    if (_cache.length >= maxEntries) _cache.remove(_cache.keys.first);
    _cache[key] = value;
  }

  /// Clears the one cache. Used by isolated tests.
  static void clear() => _cache.clear();

  /// Current number of cached transforms.
  static int get length => _cache.length;
}

/// Validates an SVG against the renderer's restricted, non-fetching XML subset.
///
/// Accepted documents have one balanced `<svg>` root, allowlisted SVG elements
/// and attributes, no non-whitespace text, local fragment references only, and
/// at most [maxSvgBytes], [maxSvgElements], and [maxSvgDepth]. DTDs, entity
/// declarations, processing instructions, scripts, style sheets, event
/// handlers, and external resources are rejected with [ArgumentError].
void validateSvgMarkup(String svg) {
  _parseRestrictedSvg(_boundedSvgSource(svg));
}

/// Applies optional stroke tint and width to a validated SVG.
///
/// The same canonical tint, opacity, width, and full raw markup used to build
/// the XML output also form the bounded cache key. `stroke="none"` remains
/// invisible; inherited and explicit strokes, including `currentColor`, can be
/// tinted. Existing stroke opacity is replaced by the requested tint alpha.
String transformSvg({
  required String rawSvg,
  Color? strokeColor,
  double? strokeWidth,
}) {
  final _BoundedSvgSource source = _boundedSvgSource(rawSvg);

  final SvgTransformKey key = SvgTransformKey(
    rawSvg: source.text,
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
  );
  final String? cached = SvgTransformCache.get(key);
  if (cached != null) return cached;

  final _SvgNode root = _parseRestrictedSvg(source);
  if (strokeColor == null && strokeWidth == null) {
    SvgTransformCache.set(key, source.text);
    return source.text;
  }

  _transformNode(
    root,
    inheritedStroke: false,
    strokeColorHex: key.strokeColorHex,
    strokeOpacity: key.strokeOpacity,
    strokeWidth: key.strokeWidthText,
  );
  final String transformed = _serializeNode(root);
  SvgTransformCache.set(key, transformed);
  return transformed;
}

void _transformNode(
  _SvgNode node, {
  required bool inheritedStroke,
  required String? strokeColorHex,
  required String? strokeOpacity,
  required String? strokeWidth,
}) {
  bool hasStroke = inheritedStroke;
  final String? stroke = node.attributes['stroke'];
  if (stroke != null) {
    hasStroke = stroke.toLowerCase() != 'none';
    if (hasStroke && strokeColorHex != null) {
      node.attributes['stroke'] = strokeColorHex;
    }
  }

  if (strokeColorHex != null && hasStroke) {
    if (strokeOpacity == '1') {
      node.attributes.remove('stroke-opacity');
    } else {
      node.attributes['stroke-opacity'] = strokeOpacity!;
    }
  }
  if (strokeWidth != null && node.attributes.containsKey('stroke-width')) {
    node.attributes['stroke-width'] = strokeWidth;
  }

  for (final _SvgPart part in node.children) {
    if (part is _SvgNode) {
      _transformNode(
        part,
        inheritedStroke: hasStroke,
        strokeColorHex: strokeColorHex,
        strokeOpacity: strokeOpacity,
        strokeWidth: strokeWidth,
      );
    }
  }
}

int _colorChannel(double value) => (value * 255).round().clamp(0, 255).toInt();

String _colorToHex6(Color color) {
  final String red = _colorChannel(color.r).toRadixString(16).padLeft(2, '0');
  final String green = _colorChannel(color.g).toRadixString(16).padLeft(2, '0');
  final String blue = _colorChannel(color.b).toRadixString(16).padLeft(2, '0');
  return '#$red$green$blue';
}

int _opacityMilli(double value) =>
    (value.clamp(0.0, 1.0) * 1000).round().clamp(0, 1000).toInt();

String _formatOpacity(int milli) {
  if (milli == 1000) return '1';
  final String fractional = (milli % 1000).toString().padLeft(3, '0');
  final String shortened = fractional.replaceFirst(RegExp(r'0+$'), '');
  if (shortened.isEmpty) return '0';
  return '${milli ~/ 1000}.$shortened';
}

String _formatWidth(double width) {
  if (!width.isFinite) {
    throw ArgumentError.value(width, 'strokeWidth', 'must be finite');
  }
  if (width <= 0) return '0';
  return width.toStringAsFixed(2);
}

final class _BoundedSvgSource {
  const _BoundedSvgSource(this.text, this.utf8ByteLength);

  final String text;
  final int utf8ByteLength;
}

_BoundedSvgSource _boundedSvgSource(String source) {
  int byteLength = 0;
  for (int index = 0; index < source.length; index++) {
    final int unit = source.codeUnitAt(index);
    if (unit <= 0x7F) {
      byteLength++;
    } else if (unit <= 0x7FF) {
      byteLength += 2;
    } else if (unit >= 0xD800 && unit <= 0xDBFF) {
      if (index + 1 >= source.length) {
        throw ArgumentError.value(
          source.length,
          'svg',
          'contains an unpaired UTF-16 surrogate',
        );
      }
      final int low = source.codeUnitAt(index + 1);
      if (low < 0xDC00 || low > 0xDFFF) {
        throw ArgumentError.value(
          source.length,
          'svg',
          'contains an unpaired UTF-16 surrogate',
        );
      }
      byteLength += 4;
      index++;
    } else if (unit >= 0xDC00 && unit <= 0xDFFF) {
      throw ArgumentError.value(
        source.length,
        'svg',
        'contains an unpaired UTF-16 surrogate',
      );
    } else {
      byteLength += 3;
    }

    if (byteLength > maxSvgBytes) {
      throw ArgumentError.value(
        byteLength,
        'svg',
        'exceeds the 256 KiB SVG limit',
      );
    }
  }
  if (source.isEmpty) {
    throw ArgumentError.value(
      source.length,
      'svg',
      'must contain one SVG root',
    );
  }
  return _BoundedSvgSource(source, byteLength);
}

_SvgNode _parseRestrictedSvg(_BoundedSvgSource source) {
  assert(source.utf8ByteLength <= maxSvgBytes);
  return _RestrictedSvgParser(source.text).parse();
}

final class _RestrictedSvgParser {
  _RestrictedSvgParser(this.source);

  static const String _svgNamespace = 'http://www.w3.org/2000/svg';
  static const String _xlinkNamespace = 'http://www.w3.org/1999/xlink';

  static const Map<String, Set<String>> _elementAttributes =
      <String, Set<String>>{
        'svg': <String>{
          'id',
          'viewBox',
          'width',
          'height',
          'preserveAspectRatio',
          'xmlns',
          'xmlns:xlink',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
        'g': <String>{
          'id',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
        'defs': <String>{'id', 'transform'},
        'path': <String>{
          'id',
          'd',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
        'circle': <String>{
          'id',
          'cx',
          'cy',
          'r',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
        'ellipse': <String>{
          'id',
          'cx',
          'cy',
          'rx',
          'ry',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
        'rect': <String>{
          'id',
          'x',
          'y',
          'width',
          'height',
          'rx',
          'ry',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
        'use': <String>{
          'id',
          'href',
          'xlink:href',
          'x',
          'y',
          'width',
          'height',
          'fill',
          'fill-opacity',
          'stroke',
          'stroke-opacity',
          'stroke-width',
          'stroke-linecap',
          'stroke-linejoin',
          'opacity',
          'color',
          'transform',
        },
      };

  static final RegExp _xmlDeclaration = RegExp(
    r"""^<\?xml\s+version\s*=\s*(['"])1\.0\1(?:\s+encoding\s*=\s*(['"])[A-Za-z][A-Za-z0-9._-]*\2)?(?:\s+standalone\s*=\s*(['"])(?:yes|no)\3)?\s*\?>$""",
  );
  static final RegExp _localId = RegExp(r'^[A-Za-z_][A-Za-z0-9_.:-]*$');
  static final RegExp _hexColor = RegExp(
    r'^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
  );
  static final RegExp _namedColor = RegExp(r'^[A-Za-z][A-Za-z0-9-]*$');
  static const List<String> _transformFunctions = <String>[
    'matrix',
    'translate',
    'scale',
    'rotate',
    'skewX',
    'skewY',
  ];

  final String source;
  int _offset = 0;
  int _elementCount = 0;

  _SvgNode parse() {
    if (source.codeUnitAt(0) == 0xFEFF) _offset++;
    if (_startsWith('<?xml')) _parseDeclaration();
    _skipWhitespaceAndComments();
    if (_offset >= source.length || source[_offset] != '<') {
      _fail('must start with one <svg> root');
    }
    final _SvgNode root = _parseElement(1);
    if (root.name != 'svg') _fail('root element must be <svg>');
    _skipWhitespaceAndComments();
    if (_offset != source.length) _fail('has content after the SVG root');
    _validateReferences(root);
    return root;
  }

  _SvgNode _parseElement(int depth) {
    if (depth > maxSvgDepth) {
      _fail('element nesting exceeds $maxSvgDepth levels');
    }
    _expect('<');
    if (_offset >= source.length ||
        source[_offset] == '/' ||
        source[_offset] == '!' ||
        source[_offset] == '?') {
      _fail('expected an allowlisted element');
    }

    final String name = _readName();
    final Set<String>? allowedAttributes = _elementAttributes[name];
    if (allowedAttributes == null) _fail('element <$name> is not allowed');
    _elementCount++;
    if (_elementCount > maxSvgElements) {
      _fail('element count exceeds $maxSvgElements');
    }

    final LinkedHashMap<String, String> attributes =
        LinkedHashMap<String, String>();
    bool selfClosing = false;
    while (true) {
      final int tokenStart = _offset;
      _skipWhitespace();
      final bool separatedFromPreviousToken = _offset > tokenStart;
      if (_startsWith('/>')) {
        _offset += 2;
        selfClosing = true;
        break;
      }
      if (_startsWith('>')) {
        _offset++;
        break;
      }
      if (_offset >= source.length) _fail('has an unclosed <$name> start tag');
      if (!separatedFromPreviousToken) {
        _fail('attributes on <$name> must be separated by whitespace');
      }

      final String attributeName = _readName();
      if (!allowedAttributes.contains(attributeName)) {
        _fail('attribute $attributeName is not allowed on <$name>');
      }
      if (attributes.containsKey(attributeName)) {
        _fail('attribute $attributeName occurs more than once');
      }
      _skipWhitespace();
      _expect('=');
      _skipWhitespace();
      if (_offset >= source.length ||
          (source[_offset] != '"' && source[_offset] != "'")) {
        _fail('attribute $attributeName must use a quoted value');
      }
      final String quote = source[_offset++];
      final int valueStart = _offset;
      while (_offset < source.length && source[_offset] != quote) {
        if (source[_offset] == '<') {
          _fail('attribute $attributeName contains an unescaped <');
        }
        _offset++;
      }
      if (_offset >= source.length) {
        _fail('attribute $attributeName is unclosed');
      }
      final String rawValue = source.substring(valueStart, _offset++);
      final String value =
          _decodeEntities(rawValue, attributeName: attributeName)
              .replaceAll('\r\n', ' ')
              .replaceAll('\n', ' ')
              .replaceAll('\r', ' ')
              .replaceAll('\t', ' ');
      _validateAttribute(name, attributeName, value);
      attributes[attributeName] = value;
    }

    final _SvgNode node = _SvgNode(
      name: name,
      attributes: attributes,
      selfClosing: selfClosing,
    );
    if (selfClosing) return node;

    while (_offset < source.length) {
      if (_startsWith('</')) {
        _offset += 2;
        final String closingName = _readName();
        _skipWhitespace();
        _expect('>');
        if (closingName != name) {
          _fail('closing </$closingName> does not match <$name>');
        }
        return node;
      }
      if (_startsWith('<!--')) {
        node.children.add(_parseComment());
        continue;
      }
      if (source[_offset] == '<') {
        node.children.add(_parseElement(depth + 1));
        continue;
      }
      final int textStart = _offset;
      while (_offset < source.length && source[_offset] != '<') {
        _offset++;
      }
      final String text = _decodeEntities(source.substring(textStart, _offset));
      if (!_isXmlWhitespace(text)) {
        _fail('text nodes are not supported in the restricted SVG subset');
      }
      if (text.isNotEmpty) node.children.add(_SvgText(text));
    }
    _fail('element <$name> is not closed');
  }

  void _validateAttribute(String element, String name, String value) {
    if (name == 'xmlns') {
      if (element != 'svg' || value != _svgNamespace) {
        _fail('xmlns must declare the SVG namespace on the root');
      }
      return;
    }
    if (name == 'xmlns:xlink') {
      if (element != 'svg' || value != _xlinkNamespace) {
        _fail('xmlns:xlink must declare the standard namespace on the root');
      }
      return;
    }
    if (name == 'id' && !_localId.hasMatch(value)) {
      _fail('id must be a local XML name');
    }
    if (name == 'href' || name == 'xlink:href') {
      if (element != 'use' || !_isLocalReference(value)) {
        _fail('links must be local fragment references on <use>');
      }
    }
    if (name == 'fill' || name == 'stroke') {
      final String color = value.trim();
      if (!_hexColor.hasMatch(color) &&
          !_namedColor.hasMatch(color) &&
          color != 'none' &&
          color != 'currentColor' &&
          color != 'inherit') {
        _fail('$name must be a plain color value without a URL');
      }
    }
    if (name == 'stroke-linecap' &&
        !const <String>{'butt', 'round', 'square', 'inherit'}.contains(value)) {
      _fail('stroke-linecap has an unsupported value');
    }
    if (name == 'stroke-linejoin' &&
        !const <String>{
          'miter',
          'round',
          'bevel',
          'arcs',
          'inherit',
        }.contains(value)) {
      _fail('stroke-linejoin has an unsupported value');
    }
    if (name == 'transform' && !_isSupportedTransform(value)) {
      _fail('transform contains an unsupported operation');
    }
  }

  bool _isSupportedTransform(String value) {
    int offset = 0;
    int operations = 0;

    void skipWhitespace() {
      while (offset < value.length) {
        final int unit = value.codeUnitAt(offset);
        if (unit != 0x20 && unit != 0x09 && unit != 0x0A && unit != 0x0D) {
          break;
        }
        offset++;
      }
    }

    while (true) {
      skipWhitespace();
      if (offset == value.length) return operations > 0;

      String? functionName;
      for (final String candidate in _transformFunctions) {
        if (value.startsWith(candidate, offset)) {
          functionName = candidate;
          break;
        }
      }
      if (functionName == null) return false;
      offset += functionName.length;
      skipWhitespace();
      if (offset >= value.length || value.codeUnitAt(offset) != 0x28) {
        return false;
      }
      offset++;

      bool hasArgumentText = false;
      while (offset < value.length && value.codeUnitAt(offset) != 0x29) {
        final int unit = value.codeUnitAt(offset);
        final bool whitespace =
            unit == 0x20 || unit == 0x09 || unit == 0x0A || unit == 0x0D;
        final bool numberPunctuation =
            (unit >= 0x30 && unit <= 0x39) ||
            unit == 0x2B ||
            unit == 0x2D ||
            unit == 0x2E ||
            unit == 0x45 ||
            unit == 0x65 ||
            unit == 0x2C;
        if (!whitespace && !numberPunctuation) return false;
        hasArgumentText = true;
        offset++;
      }
      if (!hasArgumentText ||
          offset >= value.length ||
          value.codeUnitAt(offset) != 0x29) {
        return false;
      }
      offset++;
      operations++;
    }
  }

  bool _isLocalReference(String value) =>
      value.startsWith('#') && _localId.hasMatch(value.substring(1));

  void _validateReferences(_SvgNode root) {
    final bool hasXlinkNamespace =
        root.attributes['xmlns:xlink'] == _xlinkNamespace;
    final Set<String> ids = <String>{};
    final Map<String, _SvgNode> nodesById = <String, _SvgNode>{};
    final List<String> references = <String>[];
    void visit(_SvgNode node) {
      final String? id = node.attributes['id'];
      if (id != null) {
        if (!ids.add(id)) _fail('id $id is duplicated');
        nodesById[id] = node;
      }
      for (final String name in const <String>['href', 'xlink:href']) {
        final String? reference = node.attributes[name];
        if (reference != null) {
          if (name == 'xlink:href' && !hasXlinkNamespace) {
            _fail(
              'xlink:href requires the standard root xmlns:xlink declaration',
            );
          }
          references.add(reference.substring(1));
        }
      }
      for (final _SvgPart part in node.children) {
        if (part is _SvgNode) visit(part);
      }
    }

    visit(root);
    for (final String id in references) {
      final _SvgNode? target = nodesById[id];
      if (target == null) _fail('local link #$id has no matching id');
      if (!const <String>{
        'path',
        'circle',
        'ellipse',
        'rect',
      }.contains(target.name)) {
        _fail('local links must target a drawable shape, not <${target.name}>');
      }
    }
  }

  void _parseDeclaration() {
    final int end = source.indexOf('?>', _offset);
    if (end < 0) _fail('XML declaration is not closed');
    final String declaration = source.substring(_offset, end + 2);
    if (!_xmlDeclaration.hasMatch(declaration)) {
      _fail('only a standard XML 1.0 declaration is supported');
    }
    _offset = end + 2;
  }

  _SvgComment _parseComment() {
    _offset += 4;
    final int end = source.indexOf('-->', _offset);
    if (end < 0) _fail('XML comment is not closed');
    final String content = source.substring(_offset, end);
    if (content.contains('--') || content.endsWith('-')) {
      _fail('XML comment contains an invalid -- sequence');
    }
    _offset = end + 3;
    return _SvgComment(content);
  }

  String _readName() {
    final int start = _offset;
    if (_offset >= source.length || !_isNameStart(source.codeUnitAt(_offset))) {
      _fail('expected an XML name');
    }
    _offset++;
    while (_offset < source.length && _isNamePart(source.codeUnitAt(_offset))) {
      _offset++;
    }
    return source.substring(start, _offset);
  }

  String _decodeEntities(String text, {String? attributeName}) {
    if (!text.contains('&')) return text;
    final StringBuffer output = StringBuffer();
    int start = 0;
    while (true) {
      final int ampersand = text.indexOf('&', start);
      if (ampersand < 0) {
        output.write(text.substring(start));
        break;
      }
      output.write(text.substring(start, ampersand));
      final int semicolon = text.indexOf(';', ampersand + 1);
      if (semicolon < 0) _fail('contains an unterminated entity reference');
      final String entity = text.substring(ampersand + 1, semicolon);
      switch (entity) {
        case 'amp':
          output.write('&');
        case 'lt':
          output.write('<');
        case 'gt':
          output.write('>');
        case 'quot':
          output.write('"');
        case 'apos':
          output.write("'");
        default:
          if (!entity.startsWith('#')) {
            _fail('contains a non-predefined entity reference');
          }
          final int? codePoint = _parseCharacterReference(entity);
          if (codePoint == null || !_isXmlCodePoint(codePoint)) {
            _fail('contains an invalid numeric character reference');
          }
          output.writeCharCode(codePoint);
      }
      start = semicolon + 1;
    }
    return output.toString();
  }

  int? _parseCharacterReference(String entity) {
    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      return int.tryParse(entity.substring(2), radix: 16);
    }
    if (entity.startsWith('#')) return int.tryParse(entity.substring(1));
    return null;
  }

  bool _isXmlCodePoint(int value) =>
      value == 0x9 ||
      value == 0xA ||
      value == 0xD ||
      (value >= 0x20 && value <= 0xD7FF) ||
      (value >= 0xE000 && value <= 0xFFFD) ||
      (value >= 0x10000 && value <= 0x10FFFF);

  bool _isNameStart(int unit) =>
      (unit >= 0x41 && unit <= 0x5A) ||
      (unit >= 0x61 && unit <= 0x7A) ||
      unit == 0x5F ||
      unit == 0x3A;

  bool _isNamePart(int unit) =>
      _isNameStart(unit) ||
      (unit >= 0x30 && unit <= 0x39) ||
      unit == 0x2D ||
      unit == 0x2E;

  bool _isXmlWhitespace(String value) {
    for (final int unit in value.codeUnits) {
      if (unit != 0x20 && unit != 0x9 && unit != 0xA && unit != 0xD) {
        return false;
      }
    }
    return true;
  }

  void _skipWhitespace() {
    while (_offset < source.length) {
      final int unit = source.codeUnitAt(_offset);
      if (unit != 0x20 && unit != 0x9 && unit != 0xA && unit != 0xD) break;
      _offset++;
    }
  }

  void _skipWhitespaceAndComments() {
    while (true) {
      _skipWhitespace();
      if (!_startsWith('<!--')) return;
      _parseComment();
    }
  }

  bool _startsWith(String value) => source.startsWith(value, _offset);

  void _expect(String value) {
    if (!_startsWith(value)) _fail('expected $value');
    _offset += value.length;
  }

  Never _fail(String message) =>
      throw ArgumentError.value(source, 'svg', 'Invalid SVG: $message.');
}

sealed class _SvgPart {}

final class _SvgNode extends _SvgPart {
  _SvgNode({
    required this.name,
    required this.attributes,
    required this.selfClosing,
  });

  final String name;
  final LinkedHashMap<String, String> attributes;
  final bool selfClosing;
  final List<_SvgPart> children = <_SvgPart>[];
}

final class _SvgText extends _SvgPart {
  _SvgText(this.value);

  final String value;
}

final class _SvgComment extends _SvgPart {
  _SvgComment(this.value);

  final String value;
}

String _serializeNode(_SvgNode node) {
  final StringBuffer output = StringBuffer('<${node.name}');
  for (final MapEntry<String, String> attribute in node.attributes.entries) {
    output
      ..write(' ${attribute.key}="')
      ..write(_escapeAttribute(attribute.value))
      ..write('"');
  }
  if (node.selfClosing && node.children.isEmpty) {
    output.write('/>');
    return output.toString();
  }
  output.write('>');
  for (final _SvgPart part in node.children) {
    switch (part) {
      case _SvgNode child:
        output.write(_serializeNode(child));
      case _SvgText text:
        output.write(text.value);
      case _SvgComment comment:
        output.write('<!--${comment.value}-->');
    }
  }
  output.write('</${node.name}>');
  return output.toString();
}

String _escapeAttribute(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;');

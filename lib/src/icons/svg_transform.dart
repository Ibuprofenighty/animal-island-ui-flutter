import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

/// Bounded cache for transformed SVG markup to prevent unbounded memory leaks.
final class SvgTransformCache {
  static const int maxEntries = 128;
  static final LinkedHashMap<int, String> _cache = LinkedHashMap<int, String>();

  /// Retrieves a cached transformation result if present.
  static String? get(int key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to most recently used
    }
    return value;
  }

  /// Stores a transformation result, evicting the oldest entry if [maxEntries] is reached.
  static void set(int key, String value) {
    if (_cache.length >= maxEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Clears the cache. Primarily used in testing.
  static void clear() {
    _cache.clear();
  }

  /// Current entry count in the cache.
  static int get length => _cache.length;
}

/// Validates raw SVG markup against enterprise security and complexity bounds (ICO05 / North Star 7.6).
///
/// Throws [ArgumentError] if the markup:
/// - Exceeds 256 KiB in UTF-8 byte length
/// - Contains more than 2,000 XML elements
/// - Exceeds a tag nesting depth of 64
/// - Contains external entity references (`<!ENTITY`, `<!DOCTYPE`)
/// - Contains dangerous external URIs or executable scripts (`<script`, `data:`, external `http/https`)
void validateSvgMarkup(String svg) {
  final bytes = utf8.encode(svg);
  if (bytes.length > 256 * 1024) {
    throw ArgumentError.value(
      bytes.length,
      'svg',
      'SVG byte length (${bytes.length} bytes) exceeds maximum allowable bound (262,144 bytes / 256 KiB).',
    );
  }

  // Check for dangerous entities or scripts
  final lower = svg.toLowerCase();
  if (lower.contains('<!entity') ||
      lower.contains('<!doctype') ||
      lower.contains('<script') ||
      lower.contains('data:text/html') ||
      lower.contains('data:application/')) {
    throw ArgumentError(
      'SVG markup contains disallowed entity declarations, DOCTYPE, or script references.',
    );
  }

  // Check for external URI fetches outside standard namespaces
  final uriRegex = RegExp(
    r'''(?:href|xlink:href|src)\s*=\s*['"](https?://[^'"]+)['"]''',
    caseSensitive: false,
  );
  if (uriRegex.hasMatch(svg)) {
    throw ArgumentError('SVG markup contains external URI references.');
  }

  // Count elements and verify nesting depth
  final tagRegex = RegExp(r'<(/?[a-zA-Z][a-zA-Z0-9\-_:]*)(\s+[^>]*)?(/?)>');
  int elementCount = 0;
  int currentDepth = 0;
  int maxDepth = 0;

  for (final match in tagRegex.allMatches(svg)) {
    final rawTag = match.group(1)!;
    final isClosing = rawTag.startsWith('/');
    final isSelfClosing = match.group(3) == '/' || rawTag.endsWith('/');

    if (!isClosing) {
      elementCount++;
      if (!isSelfClosing) {
        currentDepth++;
        if (currentDepth > maxDepth) {
          maxDepth = currentDepth;
        }
      }
    } else {
      if (currentDepth > 0) {
        currentDepth--;
      }
    }
  }

  if (elementCount == 0 ||
      !lower.contains('<svg') ||
      !lower.contains('</svg>')) {
    throw ArgumentError(
      'Malformed SVG markup: missing required <svg>...</svg> root elements.',
    );
  }

  if (elementCount > 2000) {
    throw ArgumentError.value(
      elementCount,
      'svg',
      'SVG element count ($elementCount) exceeds maximum allowable bound (2,000 elements).',
    );
  }

  if (maxDepth > 64) {
    throw ArgumentError.value(
      maxDepth,
      'svg',
      'SVG tag nesting depth ($maxDepth) exceeds maximum allowable bound (64 levels).',
    );
  }
}

/// Converts a [Color] to a 6-character hex string without leading `#`.
String _colorToHex6(Color c) {
  final r = (c.r * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final g = (c.g * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final b = (c.b * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  return '$r$g$b';
}

/// Safely transforms SVG markup, applying custom stroke colors (preserving alpha),
/// custom stroke widths, and bounded caching.
///
/// **Fixes Defect F05**: Retains alpha transparency via `stroke-opacity` attribute
/// rather than truncating colors to opaque 6-digit hex.
String transformSvg({
  required String rawSvg,
  Color? strokeColor,
  double? strokeWidth,
}) {
  if (rawSvg.isEmpty) return '';

  final cacheKey = Object.hash(rawSvg, strokeColor?.toARGB32(), strokeWidth);

  final cached = SvgTransformCache.get(cacheKey);
  if (cached != null) return cached;

  // Validate security and bounds
  validateSvgMarkup(rawSvg);

  var transformed = rawSvg;

  // 1. Apply strokeWidth
  if (strokeWidth != null) {
    if (strokeWidth <= 0) {
      transformed = transformed.replaceAll(
        RegExp(r'stroke-width="[^"]+"'),
        'stroke-width="0"',
      );
    } else {
      transformed = transformed.replaceAll(
        RegExp(r'stroke-width="[^"]+"'),
        'stroke-width="${strokeWidth.toStringAsFixed(2)}"',
      );
    }
  }

  // 2. Apply strokeColor with ALPHA PRESERVATION (Defect F05 fix)
  if (strokeColor != null) {
    final hex6 = _colorToHex6(strokeColor);
    final alpha = strokeColor.a;

    if (alpha < 1.0) {
      final opacityStr = alpha.toStringAsFixed(3);
      // Replace stroke color and inject/update stroke-opacity
      transformed = transformed.replaceAllMapped(
        RegExp(r'stroke="#[0-9a-fA-F]{3,8}"(\s+stroke-opacity="[^"]*")?'),
        (_) => 'stroke="#$hex6" stroke-opacity="$opacityStr"',
      );
    } else {
      transformed = transformed.replaceAllMapped(
        RegExp(r'stroke="#[0-9a-fA-F]{3,8}"(\s+stroke-opacity="[^"]*")?'),
        (_) => 'stroke="#$hex6"',
      );
    }
  }

  SvgTransformCache.set(cacheKey, transformed);
  return transformed;
}

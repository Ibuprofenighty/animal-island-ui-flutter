import '../foundation/localizations.dart';

import 'dart:async';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../internal/action_surface.dart';
import '../internal/focus_outline.dart';
import '../foundation/recipes/code_block.dart';
import '../foundation/recipes/cursor.dart';
import '../foundation/theme.dart';

/// Syntax highlighting languages supported by [IslandCodeBlock].
enum IslandCodeLanguage {
  /// Dart source code.
  dart,

  /// JavaScript or TypeScript source code.
  javascript,

  /// Shell command and terminal snippets.
  shell,

  /// Unhighlighted plain text.
  plain,
}

/// Semantic roles emitted by the single lexer. Unknown source uses foreground.
enum IslandCodeToken {
  /// Line or block comments.
  comment,

  /// String, numeric, or subcommand literals.
  literal,

  /// CLI executable commands in shell snippets.
  command,

  /// Language keywords.
  keyword,

  /// Type names and file names.
  type,

  /// Function or method invocations.
  function,

  /// Operators, brackets, flags, and punctuation.
  punctuation,
}

/// Visual styling overrides for an [IslandCodeBlock].
@immutable
class IslandCodeBlockStyle {
  const IslandCodeBlockStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.textStyle,
    this.syntaxColors = const {},
    this.copyForegroundColor,
    this.copyBackgroundColor,
    this.copyBorderColor,
  });
  final Color? backgroundColor, foregroundColor, borderColor;

  /// Typography and explicit caller Paint. foregroundColor owns default Color
  /// ink; explicit foreground Paint keeps Flutter precedence over span colors.
  final TextStyle? textStyle;
  final Map<IslandCodeToken, Color> syntaxColors;

  /// State sets include copy error and disabled, without replacing focus/hover.
  final WidgetStateProperty<Color?>? copyForegroundColor,
      copyBackgroundColor,
      copyBorderColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IslandCodeBlockStyle &&
          backgroundColor == other.backgroundColor &&
          foregroundColor == other.foregroundColor &&
          borderColor == other.borderColor &&
          textStyle == other.textStyle &&
          mapEquals(syntaxColors, other.syntaxColors) &&
          copyForegroundColor == other.copyForegroundColor &&
          copyBackgroundColor == other.copyBackgroundColor &&
          copyBorderColor == other.copyBorderColor;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    foregroundColor,
    borderColor,
    textStyle,
    Object.hashAllUnordered(
      syntaxColors.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    copyForegroundColor,
    copyBackgroundColor,
    copyBorderColor,
  );
}

/// Theme extension supplying default styling for [IslandCodeBlock] widgets.
@immutable
class IslandCodeBlockTheme extends ThemeExtension<IslandCodeBlockTheme> {
  const IslandCodeBlockTheme({this.style = const IslandCodeBlockStyle()});
  final IslandCodeBlockStyle style;
  @override
  IslandCodeBlockTheme copyWith({IslandCodeBlockStyle? style}) =>
      IslandCodeBlockTheme(style: style ?? this.style);
  @override
  IslandCodeBlockTheme lerp(covariant IslandCodeBlockTheme? other, double t) =>
      other == null || t < .5 ? this : other;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IslandCodeBlockTheme && style == other.style;

  @override
  int get hashCode => style.hashCode;
}

const _syntaxRecipe = <IslandCodeToken, Color>{
  IslandCodeToken.comment: CodeBlockColors.comment,
  IslandCodeToken.literal: CodeBlockColors.literal,
  IslandCodeToken.command: CodeBlockColors.command,
  IslandCodeToken.keyword: CodeBlockColors.keyword,
  IslandCodeToken.type: CodeBlockColors.type,
  IslandCodeToken.function: CodeBlockColors.function,
  IslandCodeToken.punctuation: CodeBlockColors.punctuation,
};

class IslandCodeBlock extends StatefulWidget {
  const IslandCodeBlock({
    super.key,
    required this.code,
    this.language = IslandCodeLanguage.dart,
    this.copyable = true,
    this.onCopied,
    this.onCopyError,
    this.style,
    this.padding,
    this.borderRadius,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });
  final String code;
  final IslandCodeLanguage language;
  final bool copyable;
  final ValueChanged<String>? onCopied;
  final ValueChanged<Object>? onCopyError;
  final IslandCodeBlockStyle? style;

  /// Explicit content padding inside the horizontal scroll region, as the
  /// reference `<pre>` padding; null retains the default copy-action reserve
  /// at the scroll end, so code at rest runs under the copy button.
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  /// Outer spacing; defaults to the reference `.wrapper { margin: 1em 0 }`
  /// at the Gallery's 16px root font size.
  final EdgeInsetsGeometry margin;
  @override
  State<IslandCodeBlock> createState() => _IslandCodeBlockState();
}

enum _CopyStatus { idle, copied, failed }

class _IslandCodeBlockState extends State<IslandCodeBlock> {
  IslandLocalizations get strings => IslandLocalizations.of(context);
  _CopyStatus status = _CopyStatus.idle;
  bool copying = false;
  Timer? reset;

  // Selection changes repaint the selected-ink pass; SelectableText owns the
  // selection itself, so the code span (and its selection) never rebuilds.
  final selectionChanged = ValueNotifier(0);
  late final FocusNode focus = FocusNode(skipTraversal: true)
    ..addListener(() {
      // SelectableText clears its selection when it loses focus while the
      // app is resumed; the repaint reads that cleared selection.
      if (!focus.hasFocus) selectionChanged.value++;
    });
  Future<void> copy() async {
    if (copying) return;
    final code = widget.code;
    setState(() => copying = true);
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (!mounted) return;
      setState(() => status = _CopyStatus.copied);
      widget.onCopied?.call(code);
    } catch (error) {
      if (!mounted) return;
      setState(() => status = _CopyStatus.failed);
      widget.onCopyError?.call(error);
    } finally {
      if (mounted) {
        setState(() => copying = false);
        reset?.cancel();
        reset = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => status = _CopyStatus.idle);
        });
      }
    }
  }

  @override
  void didUpdateWidget(IslandCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new code span resets SelectableText's selection; the selected-ink
    // pass sits above its repaint boundary, so it repaints explicitly.
    selectionChanged.value++;
  }

  String? cachedCode;
  IslandCodeLanguage? cachedLanguage;
  Map<IslandCodeToken, Color>? cachedSyntax;
  TextSpan? cachedSpan;

  TextSpan highlightedSpan(Map<IslandCodeToken, Color> syntax) {
    if (cachedSpan != null &&
        cachedCode == widget.code &&
        cachedLanguage == widget.language &&
        mapEquals(cachedSyntax, syntax)) {
      return cachedSpan!;
    }
    cachedCode = widget.code;
    cachedLanguage = widget.language;
    cachedSyntax = Map<IslandCodeToken, Color>.unmodifiable(syntax);
    return cachedSpan = _highlight(widget.code, widget.language, syntax);
  }

  @override
  void dispose() {
    reset?.cancel();
    focus.dispose();
    selectionChanged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.style;
    final themed = Theme.of(context).extension<IslandCodeBlockTheme>()?.style;
    final roles = (
      background:
          local?.backgroundColor ??
          themed?.backgroundColor ??
          CodeBlockColors.background,
      foreground:
          local?.foregroundColor ??
          themed?.foregroundColor ??
          CodeBlockColors.foreground,
      border:
          local?.borderColor ?? themed?.borderColor ?? CodeBlockColors.border,
      syntax: <IslandCodeToken, Color>{
        for (final role in IslandCodeToken.values)
          role:
              local?.syntaxColors[role] ??
              themed?.syntaxColors[role] ??
              _syntaxRecipe[role]!,
      },
    );
    final textStyle =
        TextStyle(
              fontFamily: IslandTheme.codeFontFamily,
              fontFamilyFallback: DefaultTextStyle.of(context)
                  .style
                  .fontFamilyFallback,
              letterSpacing: 0,
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w600,
            )
            .merge(themed?.textStyle)
            .merge(local?.textStyle)
            .copyWith(color: roles.foreground);
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: roles.background,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: roles.border),
      ),
      child: Stack(
        children: [
          // Reference `<pre>` padding sits inside its `overflow: auto` box:
          // at rest the code runs under the copy button to the block edge,
          // and the copy reserve only shows at the end of the scroll.
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  widget.padding ??
                  EdgeInsetsDirectional.fromSTEB(
                    24,
                    20,
                    widget.copyable ? 96 : 24,
                    20,
                  ),
              child: _SelectedInk(
                // Reference `.animal-cursor ::selection` also forces the
                // selected text to #2b2620; on the light Cursor highlight the
                // light syntax inks would read 1.1-1.6:1. An explicit caller
                // foreground Paint keeps owning the ink.
                enabled:
                    DefaultSelectionStyle.of(context).selectionColor ==
                        CursorColors.selection(Brightness.light) &&
                    textStyle.foreground == null,
                ink: CodeBlockColors.selectedInk,
                highlight: CursorColors.selection(Brightness.light),
                repaint: selectionChanged,
                child: SelectableText.rich(
                  highlightedSpan(roles.syntax),
                  focusNode: focus,
                  onSelectionChanged: (_, _) => selectionChanged.value++,
                  style: textStyle,
                  // Reference line-height 1.7 is one line box per line: a
                  // forced strut keeps CJK fallback runs from growing it.
                  strutStyle: StrutStyle.fromTextStyle(
                    textStyle,
                    forceStrutHeight: true,
                  ),
                ),
              ),
            ),
          ),
          if (widget.copyable)
            PositionedDirectional(
              top: 12,
              end: 12,
              child: Semantics(
                liveRegion: status != _CopyStatus.idle,
                child: ActionSurface(
                  label: switch (status) {
                    _CopyStatus.idle => strings.copyCode,
                    _CopyStatus.copied => strings.codeCopied,
                    _CopyStatus.failed => strings.codeCopyFailed,
                  },
                  onActivate: copying ? null : copy,
                  builder: (_, actionStates) {
                    final states = <WidgetState>{
                      ...actionStates,
                      if (status == _CopyStatus.failed) WidgetState.error,
                    };
                    final copyRoles = (
                      foreground: ActionSurface.resolveStyleValue(
                        states,
                        local?.copyForegroundColor,
                        themed?.copyForegroundColor,
                        CodeBlockColors.copyForeground,
                      ),
                      background: ActionSurface.resolveStyleValue(
                        states,
                        local?.copyBackgroundColor,
                        themed?.copyBackgroundColor,
                        states.contains(WidgetState.hovered)
                            ? CodeBlockColors.copyBackgroundHover
                            : CodeBlockColors.copyBackground,
                      ),
                      border: ActionSurface.resolveStyleValue(
                        states,
                        local?.copyBorderColor,
                        themed?.copyBorderColor,
                        CodeBlockColors.copyBorder,
                      ),
                      // Reference focus-visible: a 2px ring 2px outside the
                      // pill. A caller's focused copyBorderColor also colours
                      // the ring so custom recipes keep one focus colour.
                      ring: ActionSurface.resolveStyleValue(
                        states,
                        local?.copyBorderColor,
                        themed?.copyBorderColor,
                        CodeBlockColors.copyFocusRing,
                      ),
                    );
                    final focused = states.contains(WidgetState.focused);
                    // Reference hover lifts 1px; :active returns to rest.
                    final lift =
                        states.contains(WidgetState.hovered) &&
                        !states.contains(WidgetState.pressed);
                    return TweenAnimationBuilder<double>(
                      tween: Tween(end: lift ? -1 : 0),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      curve: const Cubic(.4, 0, .2, 1),
                      builder: (_, dy, child) => Transform(
                        transform: Matrix4.translationValues(0, dy, 0),
                        filterQuality: FilterQuality.low,
                        child: child,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 62,
                          minHeight: 32,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundDecoration: focused
                            ? FocusOutline(
                                const StadiumBorder(),
                                copyRoles.ring,
                                width: 2,
                                offset: 2,
                              )
                            : null,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: copyRoles.background,
                          border: Border.all(color: copyRoles.border),
                        ),
                        child: ExcludeSemantics(
                          child: Text(
                            switch (status) {
                              _CopyStatus.idle => strings.copy,
                              _CopyStatus.copied => strings.copied,
                              _CopyStatus.failed => strings.copyFailed,
                            },
                            style: TextStyle(
                              color: copyRoles.foreground,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Paints the selected range of the [SelectableText] below it again in [ink]
/// over the [highlight], as CSS `::selection { color }` does. It reads the
/// child's own [RenderEditable] (text, layout inputs, selection boxes), so the
/// code span and the selection are never rebuilt; nothing is painted while
/// the selection is collapsed.
class _SelectedInk extends SingleChildRenderObjectWidget {
  const _SelectedInk({
    required this.enabled,
    required this.ink,
    required this.highlight,
    required this.repaint,
    required super.child,
  });
  final bool enabled;
  final Color ink, highlight;
  final Listenable repaint;
  @override
  _RenderSelectedInk createRenderObject(BuildContext context) =>
      _RenderSelectedInk(enabled, ink, highlight, repaint);
  @override
  void updateRenderObject(BuildContext context, _RenderSelectedInk render) =>
      render
        ..enabled = enabled
        ..ink = ink
        ..highlight = highlight
        ..repaint = repaint;
}

class _RenderSelectedInk extends RenderProxyBox {
  _RenderSelectedInk(this._enabled, this._ink, this._highlight, this._repaint);
  bool _enabled;
  Color _ink, _highlight;
  Listenable _repaint;
  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    markNeedsPaint();
  }

  set ink(Color value) {
    if (value == _ink) return;
    _ink = value;
    markNeedsPaint();
  }

  set highlight(Color value) {
    if (value == _highlight) return;
    _highlight = value;
    markNeedsPaint();
  }

  set repaint(Listenable value) {
    if (identical(value, _repaint)) return;
    if (attached) _repaint.removeListener(markNeedsPaint);
    _repaint = value;
    if (attached) _repaint.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _repaint.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _repaint.removeListener(markNeedsPaint);
    super.detach();
  }

  static RenderEditable? _editable(RenderObject? node) {
    if (node == null || node is RenderEditable) return node as RenderEditable?;
    RenderEditable? found;
    node.visitChildren((child) => found ??= _editable(child));
    return found;
  }

  static InlineSpan _inked(InlineSpan span, Color ink) => span is TextSpan
      ? TextSpan(
          text: span.text,
          style: span.style?.foreground != null
              ? span.style
              : (span.style ?? const TextStyle()).copyWith(color: ink),
          children: [
            for (final child in span.children ?? const <InlineSpan>[])
              _inked(child, ink),
          ],
          semanticsLabel: span.semanticsLabel,
          locale: span.locale,
          spellOut: span.spellOut,
        )
      : span;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!_enabled) return;
    final editable = _editable(child);
    final selection = editable?.selection;
    final text = editable?.text;
    if (editable == null ||
        !editable.hasSize ||
        text == null ||
        selection == null ||
        !selection.isValid ||
        selection.isCollapsed) {
      return;
    }
    final boxes = editable.getBoxesForSelection(selection);
    if (boxes.isEmpty) return;
    final painter = TextPainter(
      text: _inked(text, _ink),
      textAlign: editable.textAlign,
      textDirection: editable.textDirection,
      textScaler: editable.textScaler,
      locale: editable.locale,
      strutStyle: editable.strutStyle,
      textWidthBasis: editable.textWidthBasis,
      textHeightBehavior: editable.textHeightBehavior,
    )..layout();
    // RenderEditable paints its text at its scroll paint offset, which the
    // selection boxes already include.
    final scroll = editable.offset.hasPixels ? editable.offset.pixels : 0.0;
    final paintOffset = editable.maxLines == 1
        ? Offset(-scroll, 0)
        : Offset(0, -scroll);
    final origin = MatrixUtils.transformPoint(
      editable.getTransformTo(this),
      Offset.zero,
    );
    final bounds = (origin + paintOffset) & painter.size;
    final clip = Path();
    for (final box in boxes) {
      clip.addRect(box.toRect().shift(origin).intersect(bounds));
    }
    context.canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..clipPath(clip)
      ..drawPaint(Paint()..color = _highlight);
    painter.paint(context.canvas, origin + paintOffset);
    context.canvas.restore();
    painter.dispose();
  }
}

final RegExp _shellLexer = RegExp(
  r'''((?<!\S)#[^\n]*|/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[├└]──|│|~/[\w./-]*|(?<!\S)--?[A-Za-z][\w-]*|[\w.-]*[\w-]/[\w./-]*|\b[\w-]+(?:\.[\w-]+)*\.(?:md|dart|yaml|yml|json|lock|ts|tsx|js|less|css|html|txt)\b|\b\d+(?:\.\d+)?\b|\b[A-Za-z_$][\w$]*(?:-[\w$]+)*|[{}()\[\];,:=<>!+*/%-])''',
);
final RegExp _codeLexer = RegExp(
  r'''(/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b\d+(?:\.\d+)?\b|\b[A-Za-z_$][\w$]*\b|[{}()\[\];,:=<>!+*/%-])''',
);
final RegExp _shellFileName = RegExp(
  r'\.(?:md|dart|yaml|yml|json|lock|ts|tsx|js|less|css|html|txt)$',
);
final RegExp _startsDigit = RegExp(r'^\d');
final RegExp _startsUpper = RegExp(r'^[A-Z]');
final RegExp _wordChar = RegExp(r'\w');
const _shellCommands = {'flutter', 'dart', 'npm', 'git', 'yarn', 'pnpm', 'npx'};
const _shellSubcommands = {
  'pub',
  'add',
  'get',
  'run',
  'build',
  'test',
  'install',
  'analyze',
};

TextSpan _highlight(
  String code,
  IslandCodeLanguage language,
  Map<IslandCodeToken, Color> colors,
) {
  if (language == IslandCodeLanguage.plain) return TextSpan(text: code);
  final shell = language == IslandCodeLanguage.shell;
  // Shell adds the reference shell vocabulary to the same lexer: `#`
  // comments (at line start or after whitespace), tree connectors, `~/`
  // paths, `-x`/`--flag` options, paths and file names, and hyphenated words
  // kept whole so `ui-flutter` never highlights an embedded `flutter`.
  final matcher = shell ? _shellLexer : _codeLexer;
  const keywords = {
    'import',
    'export',
    'from',
    'as',
    'class',
    'extends',
    'implements',
    'mixin',
    'with',
    'const',
    'final',
    'var',
    'let',
    'function',
    'return',
    'if',
    'else',
    'for',
    'while',
    'switch',
    'case',
    'break',
    'continue',
    'try',
    'catch',
    'finally',
    'throw',
    'new',
    'async',
    'await',
    'true',
    'false',
    'null',
    'void',
    'default',
    'required',
    'super',
    'this',
    'static',
    'get',
    'set',
  };
  final spans = <TextSpan>[];
  var offset = 0;
  for (final match in matcher.allMatches(code)) {
    if (match.start > offset)
      spans.add(TextSpan(text: code.substring(offset, match.start)));
    final token = match[0]!;
    final comment =
        token.startsWith('//') ||
        token.startsWith('/*') ||
        (shell && token.startsWith('#'));
    final string =
        token.startsWith("'") ||
        token.startsWith('"') ||
        (shell && token.startsWith('~/'));
    final shellPath = shell && token.contains('/') && token.length > 1;
    final shellFile = shell && _shellFileName.hasMatch(token);
    final shellMark =
        shell &&
        (token.startsWith('-') && token.length > 1 ||
            token.startsWith('├') ||
            token.startsWith('└') ||
            token == '│');
    final number = _startsDigit.hasMatch(token);
    final shellCommand =
        language == IslandCodeLanguage.shell && _shellCommands.contains(token);
    final shellSub =
        language == IslandCodeLanguage.shell &&
        _shellSubcommands.contains(token);
    final upper = _startsUpper.hasMatch(token);
    final call = code.substring(match.end).trimLeft().startsWith('(');
    final role = comment
        ? IslandCodeToken.comment
        : string || number || shellSub
        ? IslandCodeToken.literal
        : shellFile
        ? IslandCodeToken.type
        : shellPath
        ? null
        : shellMark
        ? IslandCodeToken.punctuation
        : shellCommand
        ? IslandCodeToken.command
        : keywords.contains(token)
        ? IslandCodeToken.keyword
        : upper
        ? IslandCodeToken.type
        : call
        ? IslandCodeToken.function
        : token.length == 1 && !_wordChar.hasMatch(token)
        ? IslandCodeToken.punctuation
        : null;
    // Reference highlightShell marks its `//` comments italic at weight 400.
    // It has no `#` comment, and the reference Skill page draws `#` comments
    // upright, as highlightJSX does every comment (owner decisions
    // 2026-11-18 and 2026-11-19).
    final slanted = shell && token.startsWith('//');
    spans.add(
      TextSpan(
        text: token,
        style: role == null
            ? null
            : TextStyle(
                color: colors[role],
                fontStyle: slanted ? FontStyle.italic : null,
                fontWeight: slanted ? FontWeight.w400 : null,
              ),
      ),
    );
    offset = match.end;
  }
  if (offset < code.length) spans.add(TextSpan(text: code.substring(offset)));
  return TextSpan(children: spans);
}

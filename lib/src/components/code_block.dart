import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../internal/action_surface.dart';
import '../internal/focus_outline.dart';
import '../foundation/recipes/code_block.dart';
import '../foundation/recipes/cursor.dart';
import '../foundation/theme.dart';

enum IslandCodeLanguage { dart, javascript, shell, plain }

/// Semantic roles emitted by the single lexer. Unknown source uses foreground.
enum IslandCodeToken {
  comment,
  literal,
  command,
  keyword,
  type,
  function,
  punctuation,
}

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
}

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

class _IslandCodeBlockState extends State<IslandCodeBlock> {
  String status = '复制';
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
      setState(() => status = '已复制');
      widget.onCopied?.call(code);
    } catch (error) {
      if (!mounted) return;
      setState(() => status = '复制失败');
      widget.onCopyError?.call(error);
    } finally {
      if (mounted) {
        setState(() => copying = false);
        reset?.cancel();
        reset = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => status = '复制');
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
                  EdgeInsets.fromLTRB(24, 20, widget.copyable ? 96 : 24, 20),
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
                  _highlight(widget.code, widget.language, roles.syntax),
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
            Positioned(
              top: 12,
              right: 12,
              child: ActionSurface(
                label: status == '复制'
                    ? '复制代码'
                    : status == '已复制'
                    ? '代码已复制'
                    : '代码复制失败',
                onActivate: copying ? null : copy,
                builder: (_, actionStates) {
                  final states = <WidgetState>{
                    ...actionStates,
                    if (status == '复制失败') WidgetState.error,
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
                      height: 32,
                      constraints: const BoxConstraints(minWidth: 62),
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
                          status,
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
  final matcher = RegExp(
    shell
        ? r'''((?<!\S)#[^\n]*|/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[├└]──|│|~/[\w./-]*|(?<!\S)--?[A-Za-z][\w-]*|[\w.-]*[\w-]/[\w./-]*|\b[\w-]+(?:\.[\w-]+)*\.(?:md|dart|yaml|yml|json|lock|ts|tsx|js|less|css|html|txt)\b|\b\d+(?:\.\d+)?\b|\b[A-Za-z_$][\w$]*(?:-[\w$]+)*|[{}()\[\];,:=<>!+*/%-])'''
        : r'''(/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b\d+(?:\.\d+)?\b|\b[A-Za-z_$][\w$]*\b|[{}()\[\];,:=<>!+*/%-])''',
  );
  final fileName = RegExp(
    r'\.(?:md|dart|yaml|yml|json|lock|ts|tsx|js|less|css|html|txt)$',
  );
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
    final shellFile = shell && fileName.hasMatch(token);
    final shellMark =
        shell &&
        (token.startsWith('-') && token.length > 1 ||
            token.startsWith('├') ||
            token.startsWith('└') ||
            token == '│');
    final number = RegExp(r'^\d').hasMatch(token);
    final shellCommand =
        language == IslandCodeLanguage.shell &&
        {
          'flutter',
          'dart',
          'npm',
          'git',
          'yarn',
          'pnpm',
          'npx',
        }.contains(token);
    final shellSub =
        language == IslandCodeLanguage.shell &&
        {
          'pub',
          'add',
          'get',
          'run',
          'build',
          'test',
          'install',
          'analyze',
        }.contains(token);
    final upper = RegExp(r'^[A-Z]').hasMatch(token);
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
        : token.length == 1 && !RegExp(r'\w').hasMatch(token)
        ? IslandCodeToken.punctuation
        : null;
    // Reference highlightShell marks its comments italic at weight 400;
    // highlightJSX leaves comments upright (owner decision 2026-11-18).
    final slanted = shell && role == IslandCodeToken.comment;
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

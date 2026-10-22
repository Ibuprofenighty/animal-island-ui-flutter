import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/action_surface.dart';
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
  IslandCodeToken.comment: Color(0xff9d8f7e),
  IslandCodeToken.literal: Color(0xffa8d4a0),
  IslandCodeToken.command: Color(0xfff0a870),
  IslandCodeToken.keyword: Color(0xffd4a0e0),
  IslandCodeToken.type: Color(0xff80c0e0),
  IslandCodeToken.function: Color(0xff61afef),
  IslandCodeToken.punctuation: Color(0xffd4b896),
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
    this.margin = const EdgeInsets.symmetric(vertical: 14),
  });
  final String code;
  final IslandCodeLanguage language;
  final bool copyable;
  final ValueChanged<String>? onCopied;
  final ValueChanged<Object>? onCopyError;
  final IslandCodeBlockStyle? style;

  /// Explicit content padding; null retains the default copy-action reserve.
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry margin;
  @override
  State<IslandCodeBlock> createState() => _IslandCodeBlockState();
}

class _IslandCodeBlockState extends State<IslandCodeBlock> {
  String status = '复制';
  bool copying = false;
  Timer? reset;
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
  void dispose() {
    reset?.cancel();
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
          const Color(0xff2b2118),
      foreground:
          local?.foregroundColor ??
          themed?.foregroundColor ??
          const Color(0xffe8d5bc),
      border:
          local?.borderColor ?? themed?.borderColor ?? const Color(0xff3d3028),
      syntax: <IslandCodeToken, Color>{
        for (final role in IslandCodeToken.values)
          role:
              local?.syntaxColors[role] ??
              themed?.syntaxColors[role] ??
              _syntaxRecipe[role]!,
      },
    );
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: roles.background,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: roles.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding:
                widget.padding ??
                EdgeInsets.fromLTRB(24, 20, widget.copyable ? 96 : 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText.rich(
                  _highlight(widget.code, widget.language, roles.syntax),
                  style:
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
                          .copyWith(color: roles.foreground),
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
                      const Color(0xffe8d5bc),
                    ),
                    background: ActionSurface.resolveStyleValue(
                      states,
                      local?.copyBackgroundColor,
                      themed?.copyBackgroundColor,
                      states.contains(WidgetState.hovered)
                          ? const Color(0xff4b3b31)
                          : const Color(0xf03d3028),
                    ),
                    border: ActionSurface.resolveStyleValue(
                      states,
                      local?.copyBorderColor,
                      themed?.copyBorderColor,
                      states.contains(WidgetState.focused)
                          ? const Color(0xff19c8b9)
                          : const Color(0x4de8d5bc),
                    ),
                  );
                  return Container(
                    height: 32,
                    constraints: const BoxConstraints(minWidth: 62),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

TextSpan _highlight(
  String code,
  IslandCodeLanguage language,
  Map<IslandCodeToken, Color> colors,
) {
  if (language == IslandCodeLanguage.plain) return TextSpan(text: code);
  final matcher = RegExp(
    r'''(/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b\d+(?:\.\d+)?\b|\b[A-Za-z_$][\w$]*\b|[{}()\[\];,:=<>!+*/%-])''',
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
    final comment = token.startsWith('//') || token.startsWith('/*');
    final string = token.startsWith("'") || token.startsWith('"');
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
    spans.add(
      TextSpan(
        text: token,
        style: role == null ? null : TextStyle(color: colors[role]),
      ),
    );
    offset = match.end;
  }
  if (offset < code.length) spans.add(TextSpan(text: code.substring(offset)));
  return TextSpan(children: spans);
}

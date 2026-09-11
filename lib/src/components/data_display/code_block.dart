import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../icons/icon_widget.dart';

/// Animal Island Code Block component with one-click copy.
class AnimalCodeBlock extends StatefulWidget {
  final String code;
  final String? language;

  const AnimalCodeBlock({
    super.key,
    required this.code,
    this.language,
  });

  @override
  State<AnimalCodeBlock> createState() => _AnimalCodeBlockState();
}

class _AnimalCodeBlockState extends State<AnimalCodeBlock> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.lightImpact();
    final view = View.maybeOf(context);
    if (view != null) {
      SemanticsService.sendAnnouncement(view, 'Code copied to clipboard', TextDirection.ltr);
    }
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final bgColor = theme.isDark ? theme.surfaceHeader : theme.bgInput;
    final borderColor = theme.isDark ? theme.border : theme.borderLight;
    final metaColor = theme.textSecondary;
    final codeColor = theme.text;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AnimalRadii.cardBorder,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.language ?? 'dart',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: metaColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                ),
              ),
              _CodeBlockCopyButton(
                copied: _copied,
                onCopy: _copy,
                theme: theme,
                metaColor: metaColor,
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              widget.code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.0,
                color: codeColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlockCopyButton extends StatefulWidget {
  final bool copied;
  final VoidCallback onCopy;
  final AnimalIslandTheme theme;
  final Color metaColor;

  const _CodeBlockCopyButton({
    required this.copied,
    required this.onCopy,
    required this.theme,
    required this.metaColor,
  });

  @override
  State<_CodeBlockCopyButton> createState() => _CodeBlockCopyButtonState();
}

class _CodeBlockCopyButtonState extends State<_CodeBlockCopyButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _isFocused = f),
      mouseCursor: SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onCopy(),
        ),
      },
      child: Semantics(
        button: true,
        label: widget.copied ? 'Code copied' : 'Copy code to clipboard',
        child: GestureDetector(
          onTap: widget.onCopy,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: AnimalRadii.pillBorder,
              border: Border.all(
                color: _isFocused ? widget.theme.focusYellow : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.theme.focusYellow.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.copied
                    ? CheckIcon(size: 14, color: widget.theme.success)
                    : FileIcon(size: 14, color: widget.metaColor),
                const SizedBox(width: 4.0),
                Text(
                  widget.copied ? 'Copied!' : 'Copy',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: widget.copied ? widget.theme.success : widget.metaColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


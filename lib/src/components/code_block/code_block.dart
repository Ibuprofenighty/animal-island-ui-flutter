import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icon_data.dart';
import '../../icons/icons.g.dart';

/// Animal Island Code Block component with one-click copy and resilient async feedback.
///
/// Features:
/// - Asynchronous clipboard integration: awaits [Clipboard.setData] and only reports success when confirmed
/// - Monotonic copy epoch to eliminate rapid-click race conditions and stale timer resets
/// - Graceful error feedback when clipboard permissions or platform operations fail
/// - Proper typography boundaries: monospace restricted strictly to code content, UI typography for headers
/// - Smooth horizontal scrolling for wide code statements
class AnimalCodeBlock extends StatefulWidget {
  /// Source code content to display.
  final String code;

  /// Optional programming language descriptor (e.g. 'dart', 'json'). Defaults to 'dart'.
  final String? language;

  /// Creates a code block showing [code] with a copy action.
  const AnimalCodeBlock({super.key, required this.code, this.language});

  @override
  State<AnimalCodeBlock> createState() => _AnimalCodeBlockState();
}

class _AnimalCodeBlockState extends State<AnimalCodeBlock> {
  bool _copied = false;
  bool _copyFailed = false;
  int _copyEpoch = 0;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    final epoch = ++_copyEpoch;
    final localizations = AnimalLocalizations.of(context)!;
    try {
      await Clipboard.setData(ClipboardData(text: widget.code));
      if (!mounted || epoch != _copyEpoch) return;

      HapticFeedback.lightImpact();
      final view = View.maybeOf(context);
      if (view != null) {
        final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
        SemanticsService.sendAnnouncement(
          view,
          localizations.codeCopiedSemanticLabel,
          direction,
        );
      }

      setState(() {
        _copied = true;
        _copyFailed = false;
      });

      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && epoch == _copyEpoch) {
          setState(() => _copied = false);
        }
      });
    } catch (_) {
      if (!mounted || epoch != _copyEpoch) return;

      setState(() {
        _copied = false;
        _copyFailed = true;
      });

      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && epoch == _copyEpoch) {
          setState(() => _copyFailed = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AnimalLocalizations.of(context)!;
    final theme = AnimalIslandTheme.of(context);
    final bgColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.surfaceHeader
        : theme.colors.bgInput;
    final borderColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.border
        : theme.colors.borderLight;
    final metaColor = theme.colors.textSecondary;
    final codeColor = theme.colors.text;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: theme.radii.cardBorder,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.language ?? localizations.codeDefaultLanguage,
                style: theme.typography.caption.copyWith(
                  color: metaColor,
                  fontWeight: FontWeight.w700,
                  fontSize: theme.typography.caption.fontSize,
                ),
              ),
              _CodeBlockCopyButton(
                copied: _copied,
                failed: _copyFailed,
                onCopy: _handleCopy,
                localizations: localizations,
                theme: theme,
                metaColor: metaColor,
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md - theme.spacing.xxs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              widget.code,
              style: theme.typography
                  .resolve(theme.typography.code)
                  .copyWith(
                    color: codeColor,
                    height: theme.typography.code.height,
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
  final bool failed;
  final VoidCallback onCopy;
  final AnimalLocalizations localizations;
  final AnimalIslandTheme theme;
  final Color metaColor;

  const _CodeBlockCopyButton({
    required this.copied,
    required this.failed,
    required this.onCopy,
    required this.localizations,
    required this.theme,
    required this.metaColor,
  });

  @override
  State<_CodeBlockCopyButton> createState() => _CodeBlockCopyButtonState();
}

class _CodeBlockCopyButtonState extends State<_CodeBlockCopyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color buttonColor;
    final String label;
    final AnimalIconData iconData;

    if (widget.copied) {
      buttonColor = widget.theme.colors.success;
      label = widget.localizations.copied;
      iconData = AnimalIcons.check;
    } else if (widget.failed) {
      buttonColor = widget.theme.colors.error;
      label = widget.localizations.copyFailed;
      iconData = AnimalIcons.close;
    } else {
      buttonColor = _isHovered ? widget.theme.colors.text : widget.metaColor;
      label = widget.localizations.codeCopyLabel;
      iconData = AnimalIcons.edit;
    }

    return InteractiveRegion(
      onPressed: widget.onCopy,
      enableHaptics: false,
      semanticLabel: widget.failed
          ? widget.localizations.copyFailed
          : widget.copied
          ? widget.localizations.codeCopiedSemanticLabel
          : widget.localizations.codeCopySemanticLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: widget.theme.motion.fast,
          padding: EdgeInsets.symmetric(
            horizontal: widget.theme.spacing.md - widget.theme.spacing.xxs,
            vertical: widget.theme.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.theme.colors.surfaceAlt
                : Colors.transparent,
            borderRadius: widget.theme.radii.pillBorder,
            border: Border.all(
              color: _isHovered
                  ? widget.theme.colors.borderLight
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimalIcon(data: iconData, size: 13, color: buttonColor),
              SizedBox(width: widget.theme.spacing.xs),
              Text(
                label,
                style: widget.theme.typography.caption.copyWith(
                  color: buttonColor,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.theme.typography.caption.fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

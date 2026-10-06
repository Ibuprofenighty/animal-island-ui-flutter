import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../internal/overlay/animal_localized_dialog_route.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../button/button.dart';
import '../typewriter/typewriter.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'modal_surface.dart';

/// Animal Island Organic Blob Modal dialog (C21).
///
/// Features:
/// - Organic SVG blob boundary with smooth border and warm parchment surface
/// - Typed result and async confirm support (MOD02: modal only closes on confirmation success)
/// - Double-submit and double-pop prevention
/// - Caller-owned dialogue content rendered through the modal surface
/// - Responsive scrolling accommodating 200% font scaling and virtual keyboard insets
class AnimalModal extends StatefulWidget {
  final Widget? title;
  final Widget content;
  final Widget? footer;
  final VoidCallback? onClose;
  final FutureOr<bool?> Function()? onOk;
  final String? okText;
  final String? cancelText;
  final double width;
  final bool typewriter;
  final Duration typeSpeed;
  final bool _dialogueAction;

  const AnimalModal({
    super.key,
    this.title,
    required this.content,
    this.footer,
    this.onClose,
    this.onOk,
    this.okText,
    this.cancelText,
    this.width = 500.0,
    this.typewriter = false,
    this.typeSpeed = const Duration(milliseconds: 40),
  }) : _dialogueAction = false;

  const AnimalModal._internal(
    this._dialogueAction, {
    this.title,
    required this.content,
    this.footer,
    this.onClose,
    this.onOk,
    this.okText,
    this.cancelText,
    this.width = 500.0,
    this.typewriter = false,
    this.typeSpeed = const Duration(milliseconds: 40),
  });

  /// Displays the modal in a cozy blur overlay.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget content,
    Widget? footer,
    FutureOr<bool?> Function()? onOk,
    String? okText,
    String? cancelText,
    double width = 500.0,
    bool barrierDismissible = true,
    bool typewriter = false,
    Duration typeSpeed = const Duration(milliseconds: 40),
    Color? barrierColor,
  }) => _show<T>(
    context: context,
    title: title,
    content: content,
    footer: footer,
    onOk: onOk,
    okText: okText,
    cancelText: cancelText,
    width: width,
    barrierDismissible: barrierDismissible,
    typewriter: typewriter,
    typeSpeed: typeSpeed,
    barrierColor: barrierColor,
  );

  static Future<T?> _show<T>({
    required BuildContext context,
    Widget? title,
    required Widget content,
    Widget? footer,
    FutureOr<bool?> Function()? onOk,
    String? okText,
    String? cancelText,
    double width = 500.0,
    bool barrierDismissible = true,
    bool typewriter = false,
    Duration typeSpeed = const Duration(milliseconds: 40),
    Color? barrierColor,
    bool dialogueAction = false,
  }) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveBarrierColor =
        barrierColor ??
        theme.colors.text.withValues(
          alpha: theme.colors.brightness == Brightness.dark ? 0.6 : 0.47,
        );

    return showAnimalLocalizedDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: effectiveBarrierColor,
      transitionDuration: theme.motion.normal,
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: AnimalModal._internal(
                dialogueAction,
                title: title,
                content: content,
                footer: footer,
                onClose: () => Navigator.of(ctx).pop(),
                onOk: onOk,
                okText: okText,
                cancelText: cancelText,
                width: width,
                typewriter: typewriter,
                typeSpeed: typeSpeed,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedAnim = CurvedAnimation(
          parent: anim1,
          curve: theme.motion.spring,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curvedAnim),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: anim1, curve: theme.motion.ease),
            child: child,
          ),
        );
      },
    );
  }

  /// Displays an Animal Crossing-style character dialogue modal.
  static Future<T?> showDialogue<T>({
    required BuildContext context,
    String? speaker,
    Widget? avatar,
    required String dialogue,
    Widget? title,
    Widget? footer,
    FutureOr<bool?> Function()? onOk,
    VoidCallback? onFinish,
    String? okText,
    String? cancelText,
    double width = 500.0,
  }) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveTitle = title ?? (speaker != null ? Text(speaker) : null);

    Widget dialogueContent = AnimalTypewriter(
      text: dialogue,
      speed: const Duration(milliseconds: 35),
      textAlign: TextAlign.left,
      onComplete: onFinish,
    );

    if (avatar != null) {
      dialogueContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar,
          SizedBox(width: theme.spacing.md + theme.spacing.xxs / 2),
          Expanded(child: dialogueContent),
        ],
      );
    }

    return _show<T>(
      context: context,
      title: effectiveTitle,
      content: dialogueContent,
      footer: footer,
      onOk: onOk,
      okText: okText,
      cancelText: cancelText,
      width: width,
      typewriter: false,
      dialogueAction: true,
    );
  }

  @override
  State<AnimalModal> createState() => _AnimalModalState();
}

class _AnimalModalState extends State<AnimalModal> {
  bool _isConfirming = false;
  String? _errorMessage;

  Future<void> _handleConfirm() async {
    if (_isConfirming) return;
    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onOk?.call();
      if (mounted && (result == null || result == true)) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isConfirming = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  String? _extractTextSafely(Widget widget) {
    if (widget is Text) {
      return widget.data ?? widget.textSpan?.toPlainText();
    }
    if (widget is AnimalTypewriter) {
      return widget.text;
    }
    if (widget is SingleChildRenderObjectWidget) {
      final child = widget.child;
      if (child != null) return _extractTextSafely(child);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final effectiveWidth = math.min(
      widget.width,
      mq.size.width - theme.spacing.xxl,
    );

    final borderColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.border.withValues(alpha: 0.6)
        : theme.colors.borderLight.withValues(alpha: 0.8);

    Widget effectiveContent = widget.content;
    if (widget.typewriter) {
      final text = _extractTextSafely(widget.content);
      if (text != null && text.isNotEmpty) {
        effectiveContent = AnimalTypewriter(
          text: text,
          speed: widget.typeSpeed,
        );
      }
    }

    return AnimalModalSurface(
      width: effectiveWidth,
      fillColor: theme.colors.bgContent,
      borderColor: borderColor,
      borderWidth: 2.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: widget.title != null
                        ? DefaultTextStyle(
                            style: theme.typography.title
                                .apply(fontSizeFactor: 0.75)
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colors.text,
                                ),
                            child: widget.title!,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (widget.onClose != null)
                    _ModalCloseButton(
                      onClose: widget.onClose!,
                      theme: theme,
                      borderColor: borderColor,
                    ),
                ],
              ),
              SizedBox(height: theme.spacing.lg + theme.spacing.xxs),
              // Body Content
              DefaultTextStyle(
                style: theme.typography.body
                    .apply(fontSizeFactor: (15 / 14))
                    .copyWith(color: theme.colors.textBody, height: 1.5),
                child: effectiveContent,
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: theme.spacing.md),
                Text(
                  _errorMessage!,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              SizedBox(height: theme.spacing.xl + theme.spacing.xs),
              // Footer
              widget.footer ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onClose != null) ...[
                        AnimalButton(
                          variant: AnimalButtonVariant.outlined,
                          size: AnimalButtonSize.small,
                          onPressed: _isConfirming ? null : widget.onClose,
                          child: Text(
                            widget.cancelText ?? localizations.cancel,
                          ),
                        ),
                        SizedBox(width: theme.spacing.md),
                      ],
                      AnimalButton(
                        variant: AnimalButtonVariant.filled,
                        tone: AnimalButtonTone.primary,
                        size: AnimalButtonSize.small,
                        loading: _isConfirming,
                        onPressed: _isConfirming
                            ? null
                            : (widget.onOk != null
                                  ? _handleConfirm
                                  : widget.onClose),
                        child: Text(
                          widget.okText ??
                              (widget._dialogueAction
                                  ? localizations.modalContinue
                                  : localizations.modalConfirm),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalCloseButton extends StatefulWidget {
  final VoidCallback onClose;
  final AnimalIslandTheme theme;
  final Color borderColor;

  const _ModalCloseButton({
    required this.onClose,
    required this.theme,
    required this.borderColor,
  });

  @override
  State<_ModalCloseButton> createState() => _ModalCloseButtonState();
}

class _ModalCloseButtonState extends State<_ModalCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InteractiveRegion(
      onPressed: widget.onClose,
      enableHaptics: false,
      semanticLabel: AnimalLocalizations.of(context)!.modalCloseLabel,
      surfaceColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: widget.theme.motion.fast,
          padding: EdgeInsets.all(
            widget.theme.spacing.xs + widget.theme.spacing.xxs,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? widget.theme.colors.surfaceAlt
                : Colors.transparent,
          ),
          child: AnimalIcon(
            data: AnimalIcons.close,
            size: 16,
            color: widget.theme.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

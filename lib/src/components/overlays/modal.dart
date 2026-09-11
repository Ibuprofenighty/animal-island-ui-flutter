import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../primitives/blob_clipper.dart';
import '../general/button.dart';
import '../general/typewriter.dart';
import '../../icons/icon_widget.dart';

/// Animal Island Organic Blob Modal dialog.
///
/// Strictly adheres to canonical design laws:
/// - Hard rule 9: Must use the organic SVG blob clip-path (`AnimalBlobClipper`),
///   NEVER swapped for a plain rectangle.
/// - Playful spring entrance animation (`Curves.easeOutBack`)
/// - Warm parchment background & smooth curved organic border
/// - Optional typewriter dialogue text animation
class AnimalModal extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final Widget? footer;
  final VoidCallback? onClose;
  final VoidCallback? onOk;
  final String okText;
  final String cancelText;
  final double width;
  final bool typewriter;
  final Duration typeSpeed;

  const AnimalModal({
    super.key,
    this.title,
    required this.content,
    this.footer,
    this.onClose,
    this.onOk,
    this.okText = 'Confirm',
    this.cancelText = 'Cancel',
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
    VoidCallback? onOk,
    String okText = 'Confirm',
    String cancelText = 'Cancel',
    double width = 500.0,
    bool barrierDismissible = true,
    bool typewriter = false,
    Duration typeSpeed = const Duration(milliseconds: 40),
    Color? barrierColor,
  }) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveBarrierColor = barrierColor ??
        (theme.isDark ? const Color(0x99000000) : const Color(0x77201812));

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: effectiveBarrierColor,
      transitionDuration: AnimalMotion.normal,
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: AnimalModal(
                title: title,
                content: content,
                footer: footer,
                onClose: () => Navigator.of(ctx).pop(),
                onOk: () {
                  onOk?.call();
                  Navigator.of(ctx).pop();
                },
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
        final curvedAnim = CurvedAnimation(parent: anim1, curve: AnimalMotion.spring);
        return ScaleTransition(
          scale: curvedAnim,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  /// Displays a dialogue modal with character speech typewriter effect.
  static Future<T?> showDialogue<T>({
    required BuildContext context,
    Widget? title,
    required String message,
    Widget? footer,
    VoidCallback? onOk,
    String okText = 'Understood!',
    String? cancelText,
    double width = 500.0,
  }) {
    return show<T>(
      context: context,
      title: title,
      content: AnimalTypewriter(
        text: message,
        speed: const Duration(milliseconds: 35),
        textAlign: TextAlign.left,
      ),
      footer: footer,
      onOk: onOk,
      okText: okText,
      cancelText: cancelText ?? 'Cancel',
      width: width,
      typewriter: false, // Already wrapped
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = math.min(width, screenWidth - 32.0);

    final borderColor = theme.isDark
        ? theme.border.withValues(alpha: 0.6)
        : AnimalColors.borderLight.withValues(alpha: 0.8);

    Widget effectiveContent = content;
    if (typewriter) {
      final extracted = _extractTextInfo(content);
      if (extracted != null) {
        effectiveContent = AnimalTypewriter(
          text: extracted.text,
          speed: typeSpeed,
          textAlign: extracted.textAlign ?? TextAlign.left,
          style: extracted.style,
        );
      }
    }

    return FocusScope(
      autofocus: true,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: 'Modal Dialog',
        child: CustomPaint(
          painter: _BlobModalPainter(
            fillColor: theme.bgContent,
            borderColor: borderColor,
            borderWidth: 2.5,
          ),
          child: ClipPath(
            clipper: const AnimalBlobClipper(),
            child: Container(
              width: effectiveWidth,
              padding: const EdgeInsets.fromLTRB(48.0, 42.0, 48.0, 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        DefaultTextStyle(
                          style: AnimalTypography.heading.copyWith(
                            fontSize: 20.0,
                            color: theme.text,
                          ),
                          child: title!,
                        )
                      else
                        const SizedBox.shrink(),
                      if (onClose != null)
                        _ModalCloseButton(
                          onClose: onClose!,
                          theme: theme,
                          borderColor: borderColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  // Content
                  DefaultTextStyle(
                    style: AnimalTypography.body.copyWith(
                      color: theme.textBody,
                      fontSize: 15.0,
                      height: 1.5,
                    ),
                    child: effectiveContent,
                  ),
                  const SizedBox(height: 28.0),
                  // Footer
                  footer ??
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onClose != null) ...[
                            AnimalButton(
                              type: AnimalButtonType.defaultButton,
                              size: AnimalButtonSize.small,
                              onPressed: onClose,
                              child: Text(cancelText),
                            ),
                            const SizedBox(width: 12.0),
                          ],
                          if (onOk != null)
                            AnimalButton(
                              type: AnimalButtonType.primary,
                              size: AnimalButtonSize.small,
                              onPressed: onOk,
                              child: Text(okText),
                            ),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlobModalPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  const _BlobModalPainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = const AnimalBlobClipper().getClip(size);

    // Drop shadow
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.25), 16.0, true);

    // Fill background
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Continuous organic border stroke
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _BlobModalPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}

class _ExtractedTextInfo {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;
  const _ExtractedTextInfo(this.text, {this.textAlign, this.style});
}

_ExtractedTextInfo? _extractTextInfo(Widget widget) {
  if (widget is Text) {
    final text = widget.data ?? widget.textSpan?.toPlainText();
    if (text != null && text.isNotEmpty) {
      return _ExtractedTextInfo(text, textAlign: widget.textAlign, style: widget.style);
    }
  } else if (widget is RichText) {
    final text = widget.text.toPlainText();
    if (text.isNotEmpty) {
      return _ExtractedTextInfo(text, textAlign: widget.textAlign);
    }
  } else if (widget is AnimalTypewriter) {
    return _ExtractedTextInfo(widget.text, textAlign: widget.textAlign, style: widget.style);
  } else {
    try {
      final dynamic dynamicWidget = widget;
      final dynamic child = dynamicWidget.child;
      if (child is Widget) {
        return _extractTextInfo(child);
      }
    } catch (_) {}
  }
  return null;
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
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _isFocused = f),
      onShowHoverHighlight: (h) => setState(() => _isHovered = h),
      mouseCursor: SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onClose(),
        ),
      },
      child: Semantics(
        button: true,
        label: 'Close dialog',
        child: GestureDetector(
          onTap: widget.onClose,
          child: AnimatedContainer(
            duration: AnimalMotion.fast,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered ? widget.theme.surfaceAlt : widget.theme.bgInput,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isFocused
                    ? widget.theme.focusYellow
                    : widget.borderColor.withValues(alpha: 0.5),
                width: _isFocused ? 2.0 : 1.0,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.theme.focusYellow.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: CloseIcon(size: 14, color: widget.theme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

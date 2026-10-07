import 'package:flutter/material.dart';

import '../../foundation/theme/components/loading_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../loading/loading.dart';
import 'button_style.dart';

export 'button_style.dart';

/// Cozy game-like 3D tactile button component (C01).
///
/// Strictly adheres to canonical design laws and decisions:
/// - 50px pill shape (`BorderRadius.circular(50)`)
/// - Orthogonal [variant] and [tone] (DD-02)
/// - Stacked 3D tactile depth shadow (`depth: 4.0`) exclusively on filled primary and danger
/// - Contrast compliance (WCAG AA)
/// - Zero ghost callbacks or unmount execution (eliminates F13 via [InteractiveRegion])
/// - Full keyboard accessibility (Enter/Space) and custom focus support
class AnimalButton extends StatelessWidget {
  /// The primary button label or inner content widget.
  final Widget child;

  /// Callback when pressed. If null, the button is rendered as disabled.
  final VoidCallback? onPressed;

  /// Button structural visual variant. Default is [AnimalButtonVariant.filled].
  final AnimalButtonVariant variant;

  /// Button semantic color tone. Default is [AnimalButtonTone.primary].
  final AnimalButtonTone tone;

  /// Button physical dimension size. Default is [AnimalButtonSize.middle].
  final AnimalButtonSize size;

  /// Optional leading icon.
  final Widget? icon;

  /// Whether the button is in a busy/loading state with a spinner.
  final bool loading;

  /// Whether the button is disabled.
  final bool disabled;

  /// Whether the button expands to fill the full available horizontal width.
  final bool block;

  /// Optional external [FocusNode].
  final FocusNode? focusNode;

  /// Optional accessible semantic label overriding child visual text.
  final String? semanticLabel;

  /// Creates an [AnimalButton].
  const AnimalButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = AnimalButtonVariant.filled,
    this.tone = AnimalButtonTone.primary,
    this.size = AnimalButtonSize.middle,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.block = false,
    this.focusNode,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveDisabled = disabled || onPressed == null;

    final style = ResolvedAnimalButtonStyle.resolve(
      context: context,
      variant: variant,
      tone: tone,
      size: size,
      disabled: effectiveDisabled,
      loading: loading,
    );

    Widget content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: size.iconSize,
            height: size.iconSize,
            child: AnimalLoading(
              size: size.iconSize,
              style: AnimalLoadingStyle(color: style.textColor),
            ),
          ),
          SizedBox(width: theme.spacing.sm),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(size: size.iconSize, color: style.textColor),
            child: icon!,
          ),
          SizedBox(width: theme.spacing.sm),
        ],
        DefaultTextStyle(style: style.textStyle, child: child),
      ],
    );

    Widget interactive = InteractiveRegion(
      onPressed: (effectiveDisabled || loading) ? null : onPressed,
      semanticLabel: semanticLabel,
      depth: style.depth,
      surfaceColor: style.surfaceColor,
      depthShadow: style.depthShadow,
      borderRadius: theme.radii.pillBorder,
      border: style.border,
      extraShadows: style.extraShadows,
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      disabled: effectiveDisabled,
      busy: loading,
      focusNode: focusNode,
      child: SizedBox(
        height: size.height,
        child: Center(widthFactor: block ? 1.0 : null, child: content),
      ),
    );

    return interactive;
  }
}

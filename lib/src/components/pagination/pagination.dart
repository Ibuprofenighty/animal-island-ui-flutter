import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/pagination_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'pagination_model.dart';

/// Controlled pagination with exact integer arithmetic and measured layout.
/// Empty data uses page 1 of 1 and no actions. Proposals never change current.
/// Layout measures scaled labels and 48px hit areas before choosing a window.
class AnimalPagination extends StatelessWidget {
  /// Current one-based page within 1..totalPages.
  final int current;

  /// Nonnegative number of data items.
  final int total;

  /// Positive number of items per page, default 10.
  final int pageSize;

  /// Receives one valid changed page proposal per activation.
  final ValueChanged<int> onChanged;

  /// Whether only previous, current readout and next are shown.
  final bool simple;

  /// Whether all navigation rejects activation.
  final bool disabled;

  /// Instance overrides before component theme and tokens.
  final AnimalPaginationStyle? style;

  /// Exact page count; empty data still has one empty page.
  final int totalPages;

  /// Creates pagination. Invalid total/pageSize throw ArgumentError; current
  /// outside 1..totalPages throws RangeError in debug and release alike.
  AnimalPagination({
    super.key,
    required this.current,
    required this.total,
    this.pageSize = 10,
    required this.onChanged,
    this.simple = false,
    this.disabled = false,
    this.style,
  }) : totalPages = AnimalPaginationModel.calculateTotalPages(
         total: total,
         pageSize: pageSize,
       ) {
    RangeError.checkValueInInterval(current, 1, totalPages, 'current');
  }

  void _request(int target) {
    if (!disabled &&
        total > 0 &&
        target != current &&
        target >= 1 &&
        target <= totalPages) {
      onChanged(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _resolvePaginationStyle(AnimalIslandTheme.of(context), style);
    final copy = AnimalLocalizations.of(context)!;
    final padding = s.padding!.resolve(Directionality.of(context));
    final labelStyle = s.textStyle!.copyWith(fontWeight: FontWeight.w600);
    TextStyle tokenStyle(int token) =>
        token < 0 ? s.ellipsisTextStyle! : labelStyle;
    double textWidth(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    double targetWidth(int token) => math.max(
      48,
      textWidth(token < 0 ? '•••' : '$token', tokenStyle(token)) +
          padding.horizontal,
    );
    Widget arrow(bool previous) {
      final enabled =
          !disabled &&
          total > 0 &&
          (previous ? current > 1 : current < totalPages);
      return InteractiveRegion(
        semanticLabel: previous ? copy.paginationPrevious : copy.paginationNext,
        disabled: !enabled,
        onPressed: () => _request(current + (previous ? -1 : 1)),
        depth: enabled ? s.depth! : 0,
        surfaceColor: enabled ? s.backgroundColor : s.disabledBackgroundColor,
        depthShadow: s.shadow,
        borderRadius: s.borderRadius,
        padding: s.padding,
        child: RotatedBox(
          quarterTurns:
              (previous == (Directionality.of(context) == TextDirection.ltr))
              ? 2
              : 0,
          child: AnimalIcon(
            data: AnimalIcons.play,
            size: s.iconSize!,
            color: enabled ? s.textColor : s.disabledTextColor,
          ),
        ),
      );
    }

    Widget page(int token) {
      final ellipsis = token < 0;
      final selected = token == current;
      final target = ellipsis
          ? (token == -1
                ? current - math.min<int>(5, current - 1)
                : current + math.min<int>(5, totalPages - current))
          : token;
      final enabled = !disabled && total > 0 && target != current;
      return InteractiveRegion(
        disabled: disabled || total == 0,
        selected: selected,
        semanticLabel: ellipsis
            ? (token == -1
                  ? copy.paginationSkipBackward
                  : copy.paginationSkipForward)
            : copy.paginationPage(token),
        onPressed: enabled ? () => _request(target) : null,
        depth: selected || !enabled ? 0 : s.depth!,
        surfaceColor: selected
            ? s.selectedBackgroundColor
            : (disabled ? s.disabledBackgroundColor : s.backgroundColor),
        depthShadow: s.shadow,
        borderRadius: s.borderRadius,
        padding: s.padding,
        child: Text(
          ellipsis ? '•••' : '$token',
          style: tokenStyle(token).copyWith(
            color: selected
                ? s.selectedTextColor
                : (disabled
                      ? s.disabledTextColor
                      : (ellipsis ? s.ellipsisTextColor : s.textColor)),
          ),
        ),
      );
    }

    final tokens = AnimalPaginationModel.calculatePageItems(
      current: current,
      totalPages: totalPages,
    );
    final arrowWidth = math.max(48, s.iconSize! + padding.horizontal);
    final windowWidth =
        arrowWidth * 2 +
        tokens.fold<double>(0, (sum, token) => sum + targetWidth(token)) +
        s.gap! * (tokens.length + 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = simple || constraints.maxWidth < windowWidth;
        final content = compact
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  arrow(true),
                  SizedBox(width: s.gap),
                  Flexible(
                    child: Text(
                      '$current / $totalPages',
                      style: labelStyle.copyWith(color: s.textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: s.gap),
                  arrow(false),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  arrow(true),
                  for (final token in tokens) ...[
                    SizedBox(width: s.gap),
                    page(token),
                  ],
                  SizedBox(width: s.gap),
                  arrow(false),
                ],
              );
        return Semantics(
          container: true,
          explicitChildNodes: true,
          label: copy.paginationNavigation(current, totalPages),
          child: content,
        );
      },
    );
  }
}

AnimalPaginationStyle _resolvePaginationStyle(
  AnimalIslandTheme theme,
  AnimalPaginationStyle? instance,
) => (instance ?? AnimalPaginationStyle())
    .merge(theme.components.pagination)
    .merge(
      AnimalPaginationStyle(
        backgroundColor: theme.colors.bgContent,
        selectedBackgroundColor: theme.colors.primary,
        disabledBackgroundColor: theme.colors.surfaceAlt,
        borderRadius: theme.radii.pillBorder,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        gap: theme.spacing.xs,
        textStyle: theme.typography.button.apply(fontSizeFactor: 14 / 15),
        ellipsisTextStyle: theme.typography.button
            .apply(fontSizeFactor: 12 / 15)
            .copyWith(
              letterSpacing:
                  (theme.typography.button.letterSpacing ?? .2) * 7.5,
            ),
        textColor: theme.colors.text,
        ellipsisTextColor: theme.colors.textSecondary,
        selectedTextColor: theme.colors.onPrimary,
        disabledTextColor: theme.colors.textDisabled,
        iconSize: 14,
        shadow: theme.shadows.button3d,
        depth: 3,
      ),
    );

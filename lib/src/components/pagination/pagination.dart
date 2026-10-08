import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'pagination_model.dart';

/// Animal Island 3D sinking pill Pagination component.
///
/// Features:
/// - Exact integer pagination algorithm with zero precision loss
/// - Windowed pagination with ellipsis nodes supporting quick multi-step jumping (+5 / -5)
/// - Adaptive responsive layout: switches to compact mode on narrow viewports (< 420px)
/// - [disabled] state with tactile locking and zero callback emission
/// - Full accessible semantics with localized page announcements
class AnimalPagination extends StatelessWidget {
  /// The current active page number (1-based index).
  final int current;

  /// The total number of items across all pages. Must not be negative.
  final int total;

  /// The number of items displayed per page. Must be strictly positive.
  final int pageSize;

  /// Callback invoked when the user selects or jumps to a new page.
  final ValueChanged<int> onChanged;

  /// Explicitly forces compact / simple navigation mode `[<] current / total [>]`.
  final bool simple;

  /// Whether the pagination control is completely disabled.
  final bool disabled;

  /// Creates a pagination control for page [current] of [total] items.
  ///
  /// [pageSize] must be positive, [total] non-negative and [current] at
  /// least 1.
  const AnimalPagination({
    super.key,
    required this.current,
    required this.total,
    this.pageSize = 10,
    required this.onChanged,
    this.simple = false,
    this.disabled = false,
  }) : assert(pageSize > 0, 'pageSize must be greater than 0'),
       assert(total >= 0, 'total must not be negative'),
       assert(current >= 1, 'current must be at least 1');

  /// Total number of pages calculated safely via integer division.
  int get totalPages => AnimalPaginationModel.calculateTotalPages(
    total: total,
    pageSize: pageSize,
  );

  Widget _buildCompactView({
    required BuildContext context,
    required AnimalIslandTheme theme,
    required int pages,
    required bool canPrev,
    required bool canNext,
  }) {
    final disabledBg = theme.colors.surfaceAlt;
    final localizations = AnimalLocalizations.of(context)!;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: localizations.paginationNavigation(current, pages),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InteractiveRegion(
            semanticLabel: localizations.paginationPrevious,
            onPressed: canPrev ? () => onChanged(current - 1) : null,
            depth: canPrev ? 3.0 : 0.0,
            surfaceColor: canPrev ? theme.colors.bgContent : disabledBg,
            depthShadow: theme.shadows.button3d,
            borderRadius: theme.radii.pillBorder,
            disabled: !canPrev,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.md,
              vertical: theme.spacing.sm,
            ),
            child: RotatedBox(
              quarterTurns: 2,
              child: AnimalIcon(
                data: AnimalIcons.play,
                size: 14,
                color: canPrev ? theme.colors.text : theme.colors.textDisabled,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing.md),
            child: Text(
              '$current / $pages',
              style: theme.typography.button
                  .apply(fontSizeFactor: (14 / 15))
                  .copyWith(color: theme.colors.text),
            ),
          ),
          InteractiveRegion(
            semanticLabel: localizations.paginationNext,
            onPressed: canNext ? () => onChanged(current + 1) : null,
            depth: canNext ? 3.0 : 0.0,
            surfaceColor: canNext ? theme.colors.bgContent : disabledBg,
            depthShadow: theme.shadows.button3d,
            borderRadius: theme.radii.pillBorder,
            disabled: !canNext,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.md,
              vertical: theme.spacing.sm,
            ),
            child: AnimalIcon(
              data: AnimalIcons.play,
              size: 14,
              color: canNext ? theme.colors.text : theme.colors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowedView({
    required BuildContext context,
    required AnimalIslandTheme theme,
    required int pages,
    required bool canPrev,
    required bool canNext,
  }) {
    final disabledBg = theme.colors.surfaceAlt;
    final localizations = AnimalLocalizations.of(context)!;
    final items = AnimalPaginationModel.calculatePageItems(
      current: current,
      totalPages: pages,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: localizations.paginationNavigation(current, pages),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous Page Button
          InteractiveRegion(
            semanticLabel: localizations.paginationPrevious,
            onPressed: canPrev ? () => onChanged(current - 1) : null,
            depth: canPrev ? 3.0 : 0.0,
            surfaceColor: canPrev ? theme.colors.bgContent : disabledBg,
            depthShadow: theme.shadows.button3d,
            borderRadius: theme.radii.pillBorder,
            disabled: !canPrev,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.md,
              vertical: theme.spacing.sm,
            ),
            child: RotatedBox(
              quarterTurns: 2,
              child: AnimalIcon(
                data: AnimalIcons.play,
                size: 14,
                color: canPrev ? theme.colors.text : theme.colors.textDisabled,
              ),
            ),
          ),
          SizedBox(width: theme.spacing.xs + theme.spacing.xxs),

          // Number and Ellipsis items
          ...items.map((item) {
            if (item < 0) {
              // Ellipsis item: -1 jumps -5, -2 jumps +5
              final isLeft = item == -1;
              final targetPage = isLeft
                  ? math.max(1, current - 5)
                  : math.min(pages, current + 5);
              final canJump =
                  !disabled && (isLeft ? current > 1 : current < pages);

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.xxs + theme.spacing.xxs / 2,
                ),
                child: InteractiveRegion(
                  semanticLabel: isLeft
                      ? localizations.paginationSkipBackward
                      : localizations.paginationSkipForward,
                  onPressed: canJump ? () => onChanged(targetPage) : null,
                  depth: canJump ? 2.0 : 0.0,
                  surfaceColor: theme.colors.bgContent,
                  depthShadow: theme.shadows.button3d,
                  borderRadius: theme.radii.pillBorder,
                  disabled: !canJump,
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md - theme.spacing.xxs,
                    vertical: theme.spacing.sm,
                  ),
                  child: Text(
                    '•••',
                    style: theme.typography.button
                        .apply(fontSizeFactor: (12 / 15))
                        .copyWith(
                          color: canJump
                              ? theme.colors.textSecondary
                              : theme.colors.textDisabled,
                          letterSpacing:
                              (theme.typography.button.letterSpacing ?? 0.2) *
                              7.5,
                        ),
                  ),
                ),
              );
            }

            final isSelected = item == current;
            final canClick = !disabled && !isSelected;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.xxs + theme.spacing.xxs / 2,
              ),
              child: InteractiveRegion(
                onPressed: canClick ? () => onChanged(item) : null,
                semanticLabel: localizations.paginationPage(item),
                selected: isSelected,
                depth: isSelected ? 0.0 : 3.0,
                surfaceColor: isSelected
                    ? theme.colors.primary
                    : (disabled ? disabledBg : theme.colors.bgContent),
                depthShadow: theme.shadows.button3d,
                borderRadius: theme.radii.pillBorder,
                disabled: disabled,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.md + theme.spacing.xxs / 2,
                  vertical: theme.spacing.sm,
                ),
                child: Text(
                  '$item',
                  style: theme.typography.button
                      .apply(fontSizeFactor: (14 / 15))
                      .copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected
                            ? theme.colors.onPrimary
                            : (disabled
                                  ? theme.colors.textDisabled
                                  : theme.colors.text),
                      ),
                ),
              ),
            );
          }),

          SizedBox(width: theme.spacing.xs + theme.spacing.xxs),

          // Next Page Button
          InteractiveRegion(
            semanticLabel: localizations.paginationNext,
            onPressed: canNext ? () => onChanged(current + 1) : null,
            depth: canNext ? 3.0 : 0.0,
            surfaceColor: canNext ? theme.colors.bgContent : disabledBg,
            depthShadow: theme.shadows.button3d,
            borderRadius: theme.radii.pillBorder,
            disabled: !canNext,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.md,
              vertical: theme.spacing.sm,
            ),
            child: AnimalIcon(
              data: AnimalIcons.play,
              size: 14,
              color: canNext ? theme.colors.text : theme.colors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final pages = totalPages;

    final canPrev = !disabled && current > 1;
    final canNext = !disabled && current < pages;

    if (simple) {
      return _buildCompactView(
        context: context,
        theme: theme,
        pages: pages,
        canPrev: canPrev,
        canNext: canNext,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Six 48dp targets and their gaps need more than the former visual-only
        // threshold. Switch before the full row can overflow.
        if (constraints.maxWidth.isFinite && constraints.maxWidth < 540.0) {
          return _buildCompactView(
            context: context,
            theme: theme,
            pages: pages,
            canPrev: canPrev,
            canNext: canNext,
          );
        }

        return _buildWindowedView(
          context: context,
          theme: theme,
          pages: pages,
          canPrev: canPrev,
          canNext: canNext,
        );
      },
    );
  }
}

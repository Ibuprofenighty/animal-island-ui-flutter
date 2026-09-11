import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../primitives/pressable.dart';
import '../../icons/icon_widget.dart';

/// Animal Island 3D sinking pill Pagination component.
///
/// Features:
/// - SOTA windowed pagination algorithm with ellipsis `...` nodes
/// - Zero [RenderFlex] overflow regardless of total page count (up to 1,000,000 pages)
/// - Ellipsis nodes support quick multi-step jumping (+5 / -5 pages)
/// - Optional [simple] mode for compact mobile viewports
class AnimalPagination extends StatelessWidget {
  final int current;
  final int total;
  final int pageSize;
  final ValueChanged<int> onChanged;
  final bool simple;
  final bool disabled;

  const AnimalPagination({
    super.key,
    required this.current,
    required this.total,
    this.pageSize = 10,
    required this.onChanged,
    this.simple = false,
    this.disabled = false,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 999999);

  List<int> _calculatePageItems() {
    final pages = totalPages;
    if (pages <= 7) {
      return List.generate(pages, (i) => i + 1);
    }

    // Windowed algorithm: -1 represents left ellipsis, -2 represents right ellipsis
    if (current <= 4) {
      return [1, 2, 3, 4, 5, -2, pages];
    } else if (current >= pages - 3) {
      return [1, -1, pages - 4, pages - 3, pages - 2, pages - 1, pages];
    } else {
      return [1, -1, current - 1, current, current + 1, -2, pages];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final disabledBg = theme.surfaceAlt;
    final pages = totalPages;

    final canPrev = !disabled && current > 1;
    final canNext = !disabled && current < pages;

    // Simple compact mode
    if (simple) {
      return Semantics(
        container: true,
        label: '分页导航，当前第 $current 页，共 $pages 页',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimalPressable(
              semanticLabel: '上一页',
              onPressed: canPrev ? () => onChanged(current - 1) : null,
              depth: canPrev ? 3.0 : 0.0,
              surfaceColor: canPrev ? theme.bgContent : disabledBg,
              depthColor: theme.isDark ? theme.border : AnimalColors.shadowBtn,
              borderRadius: AnimalRadii.pillBorder,
              disabled: !canPrev,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: RotatedBox(
                quarterTurns: 2,
                child: PlayIcon(
                  size: 14,
                  color: canPrev ? theme.text : theme.textDisabled,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '$current / $pages',
                style: AnimalTypography.button.copyWith(
                  fontSize: 14.0,
                  color: theme.text,
                ),
              ),
            ),
            AnimalPressable(
              semanticLabel: '下一页',
              onPressed: canNext ? () => onChanged(current + 1) : null,
              depth: canNext ? 3.0 : 0.0,
              surfaceColor: canNext ? theme.bgContent : disabledBg,
              depthColor: theme.isDark ? theme.border : AnimalColors.shadowBtn,
              borderRadius: AnimalRadii.pillBorder,
              disabled: !canNext,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: PlayIcon(
                size: 14,
                color: canNext ? theme.text : theme.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    final items = _calculatePageItems();

    return Semantics(
      container: true,
      label: '分页导航，当前第 $current 页，共 $pages 页',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous Page
          AnimalPressable(
            semanticLabel: '上一页',
            onPressed: canPrev ? () => onChanged(current - 1) : null,
            depth: canPrev ? 3.0 : 0.0,
            surfaceColor: canPrev ? theme.bgContent : disabledBg,
            depthColor: theme.isDark ? theme.border : AnimalColors.shadowBtn,
            borderRadius: AnimalRadii.pillBorder,
            disabled: !canPrev,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: RotatedBox(
              quarterTurns: 2,
              child: PlayIcon(
                size: 14,
                color: canPrev ? theme.text : theme.textDisabled,
              ),
            ),
          ),
          const SizedBox(width: 6.0),
          // Page numbers & ellipsis
          ...items.map((item) {
            if (item < 0) {
              // Ellipsis item: clicking jumps 5 pages back or forward
              final isLeftEllipsis = item == -1;
              final targetPage = isLeftEllipsis ? math.max(1, current - 5) : math.min(pages, current + 5);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: AnimalPressable(
                  semanticLabel: isLeftEllipsis ? '向前跳转5页' : '向后跳转5页',
                  onPressed: disabled ? null : () => onChanged(targetPage),
                  depth: 0.0,
                  surfaceColor: theme.bgContent.withValues(alpha: 0.4),
                  depthColor: theme.isDark ? theme.border : AnimalColors.shadowBtn,
                  borderRadius: AnimalRadii.pillBorder,
                  disabled: disabled,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Text(
                    '•••',
                    style: AnimalTypography.button.copyWith(
                      fontSize: 12.0,
                      color: theme.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              );
            }

            final page = item;
            final isSelected = page == current;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: AnimalPressable(
                semanticLabel: '第 $page 页',
                selected: isSelected,
                onPressed: disabled ? null : () => onChanged(page),
                depth: isSelected ? 3.0 : 0.0,
                surfaceColor: isSelected ? theme.primary : theme.bgContent,
                depthColor: isSelected ? theme.primaryActive : (theme.isDark ? theme.border : AnimalColors.shadowBtn),
                borderRadius: AnimalRadii.pillBorder,
                disabled: disabled,
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Text(
                  '$page',
                  style: AnimalTypography.button.copyWith(
                    fontSize: 14.0,
                    color: isSelected ? const Color(0xFFFFFFFF) : theme.text,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 6.0),
          // Next Page
          AnimalPressable(
            semanticLabel: '下一页',
            onPressed: canNext ? () => onChanged(current + 1) : null,
            depth: canNext ? 3.0 : 0.0,
            surfaceColor: canNext ? theme.bgContent : disabledBg,
            depthColor: theme.isDark ? theme.border : AnimalColors.shadowBtn,
            borderRadius: AnimalRadii.pillBorder,
            disabled: !canNext,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: PlayIcon(
              size: 14,
              color: canNext ? theme.text : theme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

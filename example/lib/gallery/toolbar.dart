import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

class GalleryToolbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;
  final bool reducedMotion;
  final ValueChanged<bool> onReducedMotionChanged;
  final VoidCallback? onOpenSearch;

  const GalleryToolbar({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.textScale,
    required this.onTextScaleChanged,
    required this.reducedMotion,
    required this.onReducedMotionChanged,
    this.onOpenSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final isZh = currentLocale.languageCode == 'zh';

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colors.bgContent,
        border: Border(
          bottom: BorderSide(color: theme.colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo & Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimalIcon(
                data: AnimalIcons.leaf,
                size: 28,
                color: theme.colors.primary,
              ),
              const SizedBox(width: 12),
              AnimalTitle(
                size: AnimalTitleSize.small,
                child: Text(localizations.galleryBrandName),
              ),
              const SizedBox(width: 12),
              AnimalTag(
                color: AnimalTileColor.appOrange,
                child: Text(localizations.galleryDevelopmentCandidateBadge),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Controls
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search button
                    if (onOpenSearch != null) ...[
                      AnimalTooltip(
                        message: localizations.gallerySearchTooltip,
                        child: AnimalButton(
                          variant: AnimalButtonVariant.text,
                          icon: const AnimalIcon(
                            data: AnimalIcons.compass,
                            size: 20,
                          ),
                          onPressed: onOpenSearch,
                          child: Text(localizations.gallerySearchAction),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Locale switcher
                    AnimalTooltip(
                      message: localizations.galleryLocaleSwitch,
                      child: AnimalButton(
                        variant: AnimalButtonVariant.outlined,
                        onPressed: () {
                          onLocaleChanged(
                            isZh ? const Locale('en') : const Locale('zh'),
                          );
                        },
                        child: Text(localizations.galleryLocaleSwitchValue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text scale selector
                    AnimalTooltip(
                      message: localizations.galleryTextScaleTooltip,
                      child: AnimalButton(
                        variant: AnimalButtonVariant.outlined,
                        onPressed: () {
                          final nextScale = textScale >= 2.0
                              ? 1.0
                              : (textScale + 0.5);
                          onTextScaleChanged(nextScale);
                        },
                        child: Text(
                          localizations.galleryTextScaleValue(textScale),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Reduced motion toggle
                    AnimalTooltip(
                      message: reducedMotion
                          ? localizations.galleryReducedMotionOn
                          : localizations.galleryReducedMotionOff,
                      child: AnimalButton(
                        variant: reducedMotion
                            ? AnimalButtonVariant.filled
                            : AnimalButtonVariant.outlined,
                        tone: reducedMotion
                            ? AnimalButtonTone.warning
                            : AnimalButtonTone.neutral,
                        icon: AnimalIcon(
                          data: reducedMotion
                              ? AnimalIcons.cloud
                              : AnimalIcons.star,
                          size: 18,
                        ),
                        onPressed: () {
                          onReducedMotionChanged(!reducedMotion);
                        },
                        child: Text(
                          reducedMotion
                              ? localizations.galleryReducedMotionOn
                              : localizations.galleryReducedMotionOff,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Theme switcher
                    AnimalTooltip(
                      message: localizations.galleryThemeTooltip,
                      child: AnimalButton(
                        variant: AnimalButtonVariant.filled,
                        tone: isDarkMode
                            ? AnimalButtonTone.warning
                            : AnimalButtonTone.primary,
                        icon: AnimalIcon(
                          data: isDarkMode ? AnimalIcons.sun : AnimalIcons.star,
                          size: 18,
                        ),
                        onPressed: onToggleTheme,
                        child: Text(
                          isDarkMode
                              ? localizations.galleryThemeDark
                              : localizations.galleryThemeLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

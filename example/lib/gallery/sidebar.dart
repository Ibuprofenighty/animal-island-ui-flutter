import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

class NavItem {
  final String title;
  final String route;
  final AnimalIconData icon;
  final String? badge;

  const NavItem({
    required this.title,
    required this.route,
    required this.icon,
    this.badge,
  });
}

class NavCategory {
  final String name;
  final List<NavItem> items;

  const NavCategory({required this.name, required this.items});
}

class GallerySidebar extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onNavigate;

  const GallerySidebar({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  static List<NavCategory> _categories(AnimalLocalizations localizations) => [
    NavCategory(
      name: localizations.galleryCategoryExplore,
      items: [
        NavItem(
          title: localizations.galleryOverviewNav,
          route: '/',
          icon: AnimalIcons.home,
        ),
        NavItem(
          title: localizations.galleryIconsNav,
          route: '/icons',
          icon: AnimalIcons.apple,
          badge: localizations.galleryCount(AnimalIcons.values.length),
        ),
        NavItem(
          title: localizations.galleryProvenanceNav,
          route: '/provenance',
          icon: AnimalIcons.anchor,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryRecipes,
      items: [
        NavItem(
          title: localizations.galleryRecipeFormNav,
          route: '/recipes/form',
          icon: AnimalIcons.edit,
          badge: localizations.galleryRecipeBadge,
        ),
        NavItem(
          title: localizations.galleryRecipeOverlayNav,
          route: '/recipes/overlay',
          icon: AnimalIcons.cloud,
          badge: localizations.galleryRecipeBadge,
        ),
        NavItem(
          title: localizations.galleryRecipeTableNav,
          route: '/recipes/data-table',
          icon: AnimalIcons.folder,
          badge: localizations.galleryRecipeBadge,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryGeneral,
      items: [
        NavItem(
          title: localizations.galleryComponentC01,
          route: '/components/button',
          icon: AnimalIcons.star,
        ),
        NavItem(
          title: localizations.galleryComponentC02,
          route: '/components/icon',
          icon: AnimalIcons.star,
        ),
        NavItem(
          title: localizations.galleryComponentC03,
          route: '/components/typewriter',
          icon: AnimalIcons.chat,
        ),
        NavItem(
          title: localizations.galleryComponentC04,
          route: '/components/cursor',
          icon: AnimalIcons.compass,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryLayout,
      items: [
        NavItem(
          title: localizations.galleryComponentC05,
          route: '/components/card',
          icon: AnimalIcons.bookmark,
        ),
        NavItem(
          title: localizations.galleryComponentC06,
          route: '/components/title',
          icon: AnimalIcons.bookmark,
        ),
        NavItem(
          title: localizations.galleryComponentC07,
          route: '/components/divider',
          icon: AnimalIcons.leaf,
        ),
        NavItem(
          title: localizations.galleryComponentC08,
          route: '/components/background',
          icon: AnimalIcons.image,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryNavigation,
      items: [
        NavItem(
          title: localizations.galleryComponentC09,
          route: '/components/collapse',
          icon: AnimalIcons.play,
        ),
        NavItem(
          title: localizations.galleryComponentC10,
          route: '/components/tabs',
          icon: AnimalIcons.settings,
        ),
        NavItem(
          title: localizations.galleryComponentC11,
          route: '/components/carousel',
          icon: AnimalIcons.refresh,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryFormControls,
      items: [
        NavItem(
          title: localizations.galleryComponentC12,
          route: '/components/input',
          icon: AnimalIcons.edit,
        ),
        NavItem(
          title: localizations.galleryComponentC13,
          route: '/components/switch',
          icon: AnimalIcons.bulb,
        ),
        NavItem(
          title: localizations.galleryComponentC14,
          route: '/components/checkbox',
          icon: AnimalIcons.check,
        ),
        NavItem(
          title: localizations.galleryComponentC15,
          route: '/components/radio',
          icon: AnimalIcons.sun,
        ),
        NavItem(
          title: localizations.galleryComponentC16,
          route: '/components/select',
          icon: AnimalIcons.play,
        ),
        NavItem(
          title: localizations.galleryComponentC17,
          route: '/components/date_picker',
          icon: AnimalIcons.calendar,
        ),
        NavItem(
          title: localizations.galleryComponentC18,
          route: '/components/time_picker',
          icon: AnimalIcons.clock,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryFormEngine,
      items: [
        NavItem(
          title: localizations.galleryComponentC19,
          route: '/components/form',
          icon: AnimalIcons.file,
        ),
        NavItem(
          title: localizations.galleryComponentC20,
          route: '/components/form_item',
          icon: AnimalIcons.check,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryOverlays,
      items: [
        NavItem(
          title: localizations.galleryComponentC21,
          route: '/components/modal',
          icon: AnimalIcons.chat,
        ),
        NavItem(
          title: localizations.galleryComponentC22,
          route: '/components/drawer',
          icon: AnimalIcons.home,
        ),
        NavItem(
          title: localizations.galleryComponentC23,
          route: '/components/tooltip',
          icon: AnimalIcons.bulb,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryFeedback,
      items: [
        NavItem(
          title: localizations.galleryComponentC24,
          route: '/components/progress',
          icon: AnimalIcons.flame,
        ),
        NavItem(
          title: localizations.galleryComponentC25,
          route: '/components/loading',
          icon: AnimalIcons.refresh,
        ),
        NavItem(
          title: localizations.galleryComponentC26,
          route: '/components/skeleton',
          icon: AnimalIcons.gift,
        ),
        NavItem(
          title: localizations.galleryComponentC27,
          route: '/components/back_top',
          icon: AnimalIcons.rocket,
        ),
        NavItem(
          title: localizations.galleryComponentC28,
          route: '/components/countdown',
          icon: AnimalIcons.clock,
        ),
        NavItem(
          title: localizations.galleryComponentC29,
          route: '/components/time',
          icon: AnimalIcons.clock,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryNotifications,
      items: [
        NavItem(
          title: localizations.galleryComponentC30,
          route: '/components/notification',
          icon: AnimalIcons.bell,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryDataDisplay,
      items: [
        NavItem(
          title: localizations.galleryComponentC31,
          route: '/components/table',
          icon: AnimalIcons.cart,
        ),
        NavItem(
          title: localizations.galleryComponentC32,
          route: '/components/pagination',
          icon: AnimalIcons.play,
        ),
        NavItem(
          title: localizations.galleryComponentC33,
          route: '/components/code_block',
          icon: AnimalIcons.code,
        ),
        NavItem(
          title: localizations.galleryComponentC34,
          route: '/components/tag',
          icon: AnimalIcons.tag,
        ),
        NavItem(
          title: localizations.galleryComponentC35,
          route: '/components/image',
          icon: AnimalIcons.camera,
        ),
      ],
    ),
    NavCategory(
      name: localizations.galleryCategoryDecorative,
      items: [
        NavItem(
          title: localizations.galleryComponentC36,
          route: '/components/footer',
          icon: AnimalIcons.location,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final categories = _categories(localizations);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colors.bgContent,
        border: Border(right: BorderSide(color: theme.colors.border, width: 1)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, catIndex) {
          final category = categories[catIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  category.name.toUpperCase(),
                  style: theme.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: theme.colors.textMuted,
                  ),
                ),
              ),
              ...category.items.map((item) {
                final isSelected = activeRoute == item.route;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: InkWell(
                    onTap: () => onNavigate(item.route),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          AnimalIcon(
                            data: item.icon,
                            size: 18,
                            color: isSelected
                                ? theme.colors.primary
                                : theme.colors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.typography.body.copyWith(
                                color: isSelected
                                    ? theme.colors.primary
                                    : theme.colors.text,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (item.badge != null)
                            AnimalTag(
                              color: isSelected
                                  ? AnimalTileColor.appTeal
                                  : AnimalTileColor.appOrange,
                              child: Text(item.badge!),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

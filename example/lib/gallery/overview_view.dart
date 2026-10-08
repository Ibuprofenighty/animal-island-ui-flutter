import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../l10n/generated/gallery_localizations.g.dart';

class OverviewView extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const OverviewView({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = GalleryLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimalTitle(
            size: AnimalTitleSize.large,
            child: Text(localizations.galleryWelcomeTitle),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.galleryWelcomeSubtitle,
            style: theme.typography.subheading.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Metrics Row
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _buildMetricCard(
                  context,
                  localizations.galleryCount(36),
                  localizations.galleryMetricComponents,
                  AnimalIcons.home,
                  AnimalTileColor.appTeal,
                ),
                _buildMetricCard(
                  context,
                  localizations.galleryCount(AnimalIcons.values.length),
                  localizations.galleryMetricIcons,
                  AnimalIcons.apple,
                  AnimalTileColor.appOrange,
                ),
              ];
              if (constraints.maxWidth > 750) {
                return Row(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }
              final cardWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards
                    .map(
                      (c) => SizedBox(
                        width: cardWidth > 140
                            ? cardWidth
                            : constraints.maxWidth,
                        child: c,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            localizations.galleryRecipesTitle,
            style: theme.typography.heading.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final items = [
                _buildActionCard(
                  context,
                  title: localizations.galleryRecipeFormTitle,
                  desc: localizations.galleryRecipeFormDescription,
                  icon: AnimalIcons.file,
                  onTap: () => onNavigate('/recipes/form'),
                ),
                _buildActionCard(
                  context,
                  title: localizations.galleryRecipeOverlayTitle,
                  desc: localizations.galleryRecipeOverlayDescription,
                  icon: AnimalIcons.cloud,
                  onTap: () => onNavigate('/recipes/overlay'),
                ),
                _buildActionCard(
                  context,
                  title: localizations.galleryRecipeTableTitle,
                  desc: localizations.galleryRecipeTableDescription,
                  icon: AnimalIcons.folder,
                  onTap: () => onNavigate('/recipes/data-table'),
                ),
              ];
              if (constraints.maxWidth > 850) {
                return Row(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(child: items[i]),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: items[i]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            localizations.galleryExploreCategoriesTitle,
            style: theme.typography.heading.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCategoryChip(
                context,
                localizations.galleryChipButton,
                '/components/button',
                AnimalIcons.star,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipIcons,
                '/icons',
                AnimalIcons.star,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipTypewriter,
                '/components/typewriter',
                AnimalIcons.chat,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipInputForms,
                '/components/input',
                AnimalIcons.edit,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipDateTime,
                '/components/date_picker',
                AnimalIcons.calendar,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipModal,
                '/components/modal',
                AnimalIcons.chat,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipTable,
                '/components/table',
                AnimalIcons.cart,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipPagination,
                '/components/pagination',
                AnimalIcons.play,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipCodeBlock,
                '/components/code_block',
                AnimalIcons.code,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipImage,
                '/components/image',
                AnimalIcons.camera,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipTabs,
                '/components/tabs',
                AnimalIcons.settings,
              ),
              _buildCategoryChip(
                context,
                localizations.galleryChipNotifications,
                '/components/notification',
                AnimalIcons.bell,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String value,
    String label,
    AnimalIconData icon,
    AnimalTileColor color,
  ) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = GalleryLocalizations.of(context);
    return AnimalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimalIcon(data: icon, size: 24, color: theme.colors.primary),
              const Spacer(),
              AnimalTag(
                color: color,
                child: Text(localizations.galleryDemoBadge),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.typography.heading.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String desc,
    required AnimalIconData icon,
    required VoidCallback onTap,
  }) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = GalleryLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimalIcon(data: icon, size: 28, color: theme.colors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.typography.subheading.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: theme.typography.caption.copyWith(
                color: theme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  localizations.galleryLaunchRecipe,
                  style: theme.typography.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                AnimalIcon(
                  data: AnimalIcons.play,
                  size: 16,
                  color: theme.colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String route,
    AnimalIconData icon,
  ) {
    return AnimalButton(
      variant: AnimalButtonVariant.outlined,
      icon: AnimalIcon(data: icon, size: 16),
      onPressed: () => onNavigate(route),
      child: Text(label),
    );
  }
}

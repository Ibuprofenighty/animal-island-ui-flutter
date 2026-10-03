import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class IconsBrowserStory extends StatefulWidget {
  const IconsBrowserStory({super.key});

  @override
  State<IconsBrowserStory> createState() => _IconsBrowserStoryState();
}

class _IconsBrowserStoryState extends State<IconsBrowserStory> {
  final TextEditingController _searchController = TextEditingController();
  AnimalIconData? _selectedIcon = AnimalIcons.apple;
  double _iconSize = 32.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final allIcons = AnimalIcons.all;
    final searchQuery = _searchController.text;
    final filteredIcons = allIcons.where((icon) {
      return icon.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimalTitle(
            size: AnimalTitleSize.large,
            child: const Text('101 Canonical Vector Icons (C02)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Native island-themed SVG vectors with preserved multi-color fills and alpha strokes',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: 'Icon Explorer & Playground',
            capabilityIds: const ['C02-ICO', 'ICO01', 'ICO02', 'ICO03'],
            description: 'Search across all 101 icons, customize display size, and copy type-safe code snippets.',
            codeSnippet: _selectedIcon != null
                ? "AnimalIcon(\n  data: AnimalIcons.${_selectedIcon!.name},\n  size: $_iconSize,\n)"
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input & Controls
                Row(
                  children: [
                    Expanded(
                      child: AnimalInput(
                        controller: _searchController,
                        placeholder: 'Search 101 icons by name...',
                        prefix: const AnimalIcon(
                          data: AnimalIcons.compass,
                          size: 20,
                        ),
                        clearable: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimalTag(
                      color: AnimalTileColor.appTeal,
                      child: Text(
                        '${filteredIcons.length} / ${allIcons.length} Icons',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Size adjuster
                Row(
                  children: [
                    Text(
                      'Icon Preview Size: ',
                      style: theme.typography.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      children: [20.0, 24.0, 32.0, 48.0, 64.0].map((s) {
                        return AnimalButton(
                          variant: _iconSize == s
                              ? AnimalButtonVariant.filled
                              : AnimalButtonVariant.outlined,
                          onPressed: () => setState(() => _iconSize = s),
                          child: Text('${s.toInt()}px'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Icons Grid
                Container(
                  constraints: const BoxConstraints(maxHeight: 480),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colors.bgContent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: filteredIcons.isEmpty
                      ? Center(
                          child: Text(
                            'No icons match "$searchQuery"',
                            style: theme.typography.body.copyWith(
                              color: theme.colors.textMuted,
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 110,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: filteredIcons.length,
                          itemBuilder: (context, index) {
                            final icon = filteredIcons[index];
                            final isSelected = _selectedIcon?.name == icon.name;

                            return InkWell(
                              onTap: () => setState(() => _selectedIcon = icon),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colors.primary.withValues(
                                          alpha: 0.15,
                                        )
                                      : theme.colors.bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colors.primary
                                        : theme.colors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimalIcon(data: icon, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      icon.name,
                                      style: theme.typography.caption.copyWith(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? theme.colors.primary
                                            : theme.colors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

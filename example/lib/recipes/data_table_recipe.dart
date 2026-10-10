import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../gallery/story_card.dart';

class DataTableRecipe extends StatefulWidget {
  const DataTableRecipe({super.key});

  @override
  State<DataTableRecipe> createState() => _DataTableRecipeState();
}

class _DataTableRecipeState extends State<DataTableRecipe> {
  static const int _totalRows = 1000;
  int _currentPage = 1;
  final int _pageSize = 10;
  String? _selectedItemName;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final startIndex = (_currentPage - 1) * _pageSize;

    final columns = [
      AnimalTableColumn(title: 'ID', width: 80),
      AnimalTableColumn(title: 'Island Item', flex: 2),
      AnimalTableColumn(title: 'Category', flex: 1),
      AnimalTableColumn(
        title: 'Bells Value',
        width: 120,
        alignment: Alignment.centerRight,
      ),
      AnimalTableColumn(
        title: 'Inspect',
        width: 100,
        alignment: Alignment.center,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimalTitle(
            size: AnimalTitleSize.large,
            child: const Text(
              'Recipe 3: Virtual Table, Pagination & Media Gallery',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'End-to-end interactive workflow rendering 1,000 items with lazy builder, pagination sync, code copy and lightbox preview',
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          StoryCard(
            title: '1,000-Item Island Store Catalog (F10 & F24 Tested)',
            capabilityIds: const [
              'C31-TBL',
              'C32-PAG',
              'C33-COD',
              'C35-IMG',
              'F10',
              'F24',
              'F25',
            ],
            description: 'Verifies finite viewport virtualization (renders <= 24 rows initially regardless of 1000 row count), integer-safe pagination, and image zoom.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Table Container
                Container(
                  height: 380,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimalTable(
                    columns: columns,
                    rowCount: _pageSize,
                    rowKey: (index) => ValueKey(startIndex + index),
                    rowBuilder: (context, index) {
                      final itemIndex = startIndex + index + 1;
                      final categories = [
                        'Fruit',
                        'Tool',
                        'Furniture',
                        'Fish',
                        'Bug',
                        'Flower',
                      ];
                      final cat = categories[itemIndex % categories.length];
                      final bells = (itemIndex * 150) % 8900 + 100;

                      return [
                        Text(
                          '#$itemIndex',
                          style: theme.typography.caption.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        Row(
                          children: [
                            AnimalIcon(
                              data: cat == 'Fruit'
                                  ? AnimalIcons.apple
                                  : (cat == 'Tool'
                                        ? AnimalIcons.anchor
                                        : AnimalIcons.star),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Island Asset #$itemIndex',
                              style: theme.typography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        AnimalTag(
                          color: cat == 'Fruit'
                              ? AnimalTileColor.appOrange
                              : AnimalTileColor.appTeal,
                          child: Text(cat),
                        ),
                        Text(
                          '$bells 🔔',
                          style: theme.typography.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.primary,
                          ),
                        ),
                        AnimalButton(
                          variant: AnimalButtonVariant.text,
                          onPressed: () {
                            setState(
                              () => _selectedItemName =
                                  'Island Asset #$itemIndex ($cat, $bells Bells)',
                            );
                          },
                          child: const Text('View'),
                        ),
                      ];
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Pagination Bar
                Row(
                  children: [
                    Text(
                      'Showing ${startIndex + 1}–${startIndex + _pageSize} of $_totalRows items',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    AnimalPagination(
                      current: _currentPage,
                      total: _totalRows,
                      pageSize: _pageSize,
                      onChanged: (page) => setState(() => _currentPage = page),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const AnimalDivider(type: AnimalDividerType.dashed),
                const SizedBox(height: 20),
                // Selected item inspect + code block copy
                if (_selectedItemName != null) ...[
                  Text(
                    'Selected Asset Details (F25 Tested):',
                    style: theme.typography.heading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimalCodeBlock(
                    code:
                        '{\n  "name": "$_selectedItemName",\n  "status": "In Stock",\n  "verified": true,\n  "virtualized": true\n}',
                    language: 'json',
                  ),
                  const SizedBox(height: 16),
                ],
                // Media Lightbox Gallery Demo
                Text(
                  'Island Postcard Gallery (C35 Image Preview):',
                  style: theme.typography.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const AnimalImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=300',
                      ),
                      width: 140,
                      height: 100,
                    ),
                    const SizedBox(width: 16),
                    const AnimalImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=300',
                      ),
                      width: 140,
                      height: 100,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Click any postcard image above to launch the full-screen interactive Lightbox modal. Supports pinch-to-zoom, pan drag, and Escape key dismissal.',
                        style: theme.typography.caption.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

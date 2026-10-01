import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String? description;
  final List<String> capabilityIds;
  final Widget child;
  final String? codeSnippet;
  final String? keyboardTips;

  const StoryCard({
    super.key,
    required this.title,
    this.description,
    this.capabilityIds = const [],
    required this.child,
    this.codeSnippet,
    this.keyboardTips,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return AnimalCard(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.heading.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.text,
            ),
          ),
          if (capabilityIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: capabilityIds.map((id) {
                return AnimalTag(
                  color: AnimalTileColor.appTeal,
                  child: Text(id),
                );
              }).toList(),
            ),
          ],
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: theme.typography.body.copyWith(
                color: theme.colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const AnimalDivider(type: AnimalDividerType.dashed),
          const SizedBox(height: 16),
          child,
          if (keyboardTips != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                AnimalIcon(
                  data: AnimalIcons.compass,
                  size: 16,
                  color: theme.colors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    keyboardTips!,
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (codeSnippet != null) ...[
            const SizedBox(height: 16),
            AnimalCodeBlock(code: codeSnippet!, language: 'dart'),
          ],
        ],
      ),
    );
  }
}

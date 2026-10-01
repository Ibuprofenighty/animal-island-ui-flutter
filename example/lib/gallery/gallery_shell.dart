import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'sidebar.dart';
import 'toolbar.dart';
import 'overview_view.dart';
import '../stories/icons_browser_story.dart';
import '../provenance/provenance_view.dart';
import '../recipes/form_workflow_recipe.dart';
import '../recipes/overlay_orchestration_recipe.dart';
import '../recipes/data_table_recipe.dart';
import '../stories/stories_registry.dart';

class GalleryShell extends StatefulWidget {
  final String activeRoute;
  final ValueChanged<String> onNavigate;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;
  final bool reducedMotion;
  final ValueChanged<bool> onReducedMotionChanged;

  const GalleryShell({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.textScale,
    required this.onTextScaleChanged,
    required this.reducedMotion,
    required this.onReducedMotionChanged,
  });

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildContent(String route) {
    final localizations = AnimalLocalizations.of(context)!;
    if (route == '/' || route.isEmpty) {
      return OverviewView(onNavigate: widget.onNavigate);
    }
    if (route == '/icons') {
      return const IconsBrowserStory();
    }
    if (route == '/provenance') {
      return const ProvenanceView();
    }
    if (route == '/recipes/form') {
      return const FormWorkflowRecipe();
    }
    if (route == '/recipes/overlay') {
      return const OverlayOrchestrationRecipe();
    }
    if (route == '/recipes/data-table') {
      return const DataTableRecipe();
    }
    if (route.startsWith('/components/')) {
      final slug = route.substring('/components/'.length);
      final story = resolveStoryWidget(slug);
      if (story != null) return story;
    }

    // 404 Fallback view
    final theme = AnimalIslandTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimalIcon(data: AnimalIcons.compass, size: 64),
            const SizedBox(height: 16),
            AnimalTitle(
              size: AnimalTitleSize.large,
              child: Text(localizations.galleryNotFoundTitle),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.galleryNotFoundRoute(route),
              style: theme.typography.body.copyWith(
                color: theme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AnimalButton(
              variant: AnimalButtonVariant.filled,
              onPressed: () => widget.onNavigate('/'),
              child: Text(localizations.galleryReturnOverview),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colors.bg,
      drawer: isDesktop
          ? null
          : Drawer(
              child: GallerySidebar(
                activeRoute: widget.activeRoute,
                onNavigate: (r) {
                  Navigator.of(context).pop();
                  widget.onNavigate(r);
                },
              ),
            ),
      body: Stack(
        children: [
          Column(
            children: [
              GalleryToolbar(
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme,
                currentLocale: widget.currentLocale,
                onLocaleChanged: widget.onLocaleChanged,
                textScale: widget.textScale,
                onTextScaleChanged: widget.onTextScaleChanged,
                reducedMotion: widget.reducedMotion,
                onReducedMotionChanged: widget.onReducedMotionChanged,
                onOpenSearch: isDesktop
                    ? null
                    : () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (isDesktop)
                      GallerySidebar(
                        activeRoute: widget.activeRoute,
                        onNavigate: (r) {
                          _scrollController.jumpTo(0);
                          widget.onNavigate(r);
                        },
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  _buildContent(widget.activeRoute),
                                  const SizedBox(height: 48),
                                  const AnimalFooter(
                                    type: AnimalFooterType.sea,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: AnimalBackTop(
              scrollController: _scrollController,
              visibilityHeight: 200,
            ),
          ),
        ],
      ),
    );
  }
}

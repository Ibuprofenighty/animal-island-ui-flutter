import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../../shared/palette.dart';
import 'example.dart';

const _ease = Cubic(0.4, 0, 0.2, 1);
const _short = Duration(milliseconds: 200);

/// Opens another Gallery route through the app router (reference
/// `<a href="#/chart-…">`). Hosts without a router ignore it.
void openGalleryRoute(BuildContext context, String id) {
  final provider = Router.maybeOf(context)?.routeInformationProvider;
  if (provider is PlatformRouteInformationProvider) {
    provider.didPushRouteInformation(RouteInformation(uri: Uri(path: '/$id')));
  }
}

/// Reference demo.module.less `.note` (margin 12 0 20, 13px / 1.8).
class ChartNote extends StatelessWidget {
  const ChartNote(this.text, {super.key, this.status = false});
  final String text;

  /// Reference `role="status"`: announced when it changes.
  final bool status;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 20),
    child: Semantics(
      liveRegion: status,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.8,
          color: GalleryPalette.chartNote,
        ),
      ),
    ),
  );
}

/// Reference `sectionTitleStyle` used inside a section (18 / 600 #725d42).
class ChartSectionTitle extends StatelessWidget {
  const ChartSectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: GalleryPalette.storyInk,
      ),
    ),
  );
}

/// Reference CSS grid of equal `minmax(0, 1fr)` columns, rows aligned to
/// the start (`align-items: start`).
class ChartGrid extends StatelessWidget {
  const ChartGrid({
    super.key,
    required this.columns,
    required this.children,
    this.rowGap = 24,
    this.columnGap = 20,
    this.equalRows = false,
  });
  final int columns;
  final double rowGap, columnGap;

  /// Reference `grid-auto-rows: 1fr`: every row as tall as the tallest.
  final bool equalRows;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final row = Row(
        crossAxisAlignment: equalRows
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        spacing: columnGap,
        children: [
          for (var j = i; j < i + columns; j++)
            Expanded(
              child: j < children.length ? children[j] : const SizedBox(),
            ),
        ],
      );
      rows.add(equalRows ? IntrinsicHeight(child: row) : row);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: rowGap,
      children: rows,
    );
  }
}

/// Reference gallery.module.less `.gallery`: a headed block of examples with
/// a bottom rule, laid out by its own width (container queries).
class ChartGallerySection extends StatelessWidget {
  const ChartGallerySection({
    super.key,
    required this.semanticLabel,
    required this.title,
    required this.body,
    required this.children,
    this.comparison = false,
    this.footer,
  });
  final String semanticLabel, title, body;
  final List<Widget> children;

  /// Reference `.comparison-grid`: two columns, never four.
  final bool comparison;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: Container(
      margin: const EdgeInsets.only(top: 24, bottom: 32),
      padding: const EdgeInsets.only(bottom: 28),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: GalleryPalette.rule)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width <= 719
              ? 1
              : (!comparison && width >= 1400 ? 4 : 2);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: GalleryPalette.demoStrongInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.8,
                        color: GalleryPalette.storyInk,
                      ),
                    ),
                  ],
                ),
              ),
              ChartGrid(columns: columns, children: children),
              ?footer,
            ],
          );
        },
      ),
    ),
  );
}

/// Reference `ChartGalleryItem`: the chart, a 查看配置 disclosure and, in
/// the overview, a link to the type page.
class ChartGalleryItem extends StatelessWidget {
  const ChartGalleryItem({super.key, required this.example, this.link});
  final ChartExample example;

  /// Link text and target route of the overview showcase.
  final (String, String)? link;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '${example.title}示例',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        example.chart(),
        ChartActions(disclosure: '查看配置', code: example.code, link: link),
      ],
    ),
  );
}

/// Reference `.actions`: a `<details>` code disclosure and an optional link,
/// spread to both ends and wrapping; the open disclosure takes the row.
class ChartActions extends StatefulWidget {
  const ChartActions({
    super.key,
    required this.disclosure,
    required this.code,
    this.link,
  });
  final String disclosure, code;
  final (String, String)? link;
  @override
  State<ChartActions> createState() => _ChartActionsState();
}

class _ChartActionsState extends State<ChartActions> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final summary = ChartPressable(
      label: '${open ? '▼' : '▶'} ${widget.disclosure}',
      semanticLabel: widget.disclosure,
      expanded: open,
      onPressed: () => setState(() => open = !open),
    );
    final link = switch (widget.link) {
      (final text, final route) => ChartPressable(
        label: text,
        link: true,
        onPressed: () => openGalleryRoute(context, route),
      ),
      null => null,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 12, color: GalleryPalette.storyInk),
        child: open
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(alignment: Alignment.centerLeft, child: summary),
                  const SizedBox(height: 8),
                  IslandCodeBlock(code: widget.code, margin: EdgeInsets.zero),
                  if (link != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: link,
                      ),
                    ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [summary, ?link],
              ),
      ),
    );
  }
}

/// Reference `summary` / `.actions a`: 8px padding, radius 12, `#f0e8d8`
/// hover over 0.2s, 2px focus ring 2px outside.
class ChartPressable extends StatefulWidget {
  const ChartPressable({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.expanded,
    this.link = false,
  });
  final String label;
  final String? semanticLabel;
  final bool? expanded;
  final bool link;
  final VoidCallback onPressed;
  @override
  State<ChartPressable> createState() => _ChartPressableState();
}

class _ChartPressableState extends State<ChartPressable> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => hover = value),
      onShowFocusHighlight: (value) => setState(() => focus = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Semantics(
        button: !widget.link,
        link: widget.link,
        expanded: widget.expanded,
        label: widget.semanticLabel ?? widget.label,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: reduced ? Duration.zero : _short,
              curve: _ease,
              padding: const EdgeInsets.all(8),
              foregroundDecoration: focus
                  ? BoxDecoration(
                      border: Border.all(
                        color: IslandTokens.light.focus,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside + 2,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              decoration: BoxDecoration(
                color: hover
                    ? GalleryPalette.chartActionHover
                    : GalleryPalette.chartActionHover.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  height: 1.6,
                  decoration: widget.link ? TextDecoration.underline : null,
                  decorationColor: GalleryPalette.storyInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reference catalog card: a link to one chart type page.
class ChartCatalogCard extends StatefulWidget {
  const ChartCatalogCard({
    super.key,
    required this.label,
    required this.desc,
    required this.onPressed,
  });
  final String label, desc;
  final VoidCallback onPressed;
  @override
  State<ChartCatalogCard> createState() => _ChartCatalogCardState();
}

class _ChartCatalogCardState extends State<ChartCatalogCard> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced ? Duration.zero : _short;
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => hover = value),
      onShowFocusHighlight: (value) => setState(() => focus = value),
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Semantics(
        link: true,
        label: '${widget.label} ${widget.desc}',
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: widget.onPressed,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: hover && !reduced ? -2 : 0),
              duration: duration,
              curve: _ease,
              builder: (context, lift, child) =>
                  Transform.translate(offset: Offset(0, lift), child: child),
              child: AnimatedContainer(
                duration: duration,
                curve: _ease,
                constraints: const BoxConstraints(minHeight: 110),
                padding: const EdgeInsets.all(24),
                foregroundDecoration: focus
                    ? BoxDecoration(
                        border: Border.all(
                          color: IslandTokens.light.focus,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside + 3,
                        ),
                        borderRadius: BorderRadius.circular(23),
                      )
                    : null,
                decoration: BoxDecoration(
                  color: hover
                      ? GalleryPalette.chartCatalogHover
                      : IslandTokens.light.paper,
                  border: Border.all(
                    width: 1.5,
                    color: hover
                        ? GalleryPalette.chartCatalogHoverBorder
                        : GalleryPalette.rule,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: GalleryPalette.demoStrongInk,
                      ),
                    ),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.8,
                        color: GalleryPalette.storyInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

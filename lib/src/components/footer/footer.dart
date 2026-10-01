import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'footer_painter.dart';

export 'footer_painter.dart';

/// Animal Island footer decoration with gentle wave shoreline or forest tree silhouette (C36).
///
/// Features:
/// - Supports [AnimalFooterType.sea] and [AnimalFooterType.tree] silhouettes
/// - Seamless bottom edge option
/// - Localized default copy provided by [AnimalLocalizations] (no emoji replacement)
/// - Pure decorative silhouette excluded from assistive tech semantics noise
class AnimalFooter extends StatelessWidget {
  /// Footer top silhouette decoration style. Default is [AnimalFooterType.sea].
  final AnimalFooterType type;

  /// Whether the footer seamlessly blends into the bottom without top margin.
  final bool seamless;

  /// Custom content inside the footer.
  final Widget? content;

  /// Fallback text when [content] is null. If null, resolves from [AnimalLocalizations].
  final String? defaultText;

  const AnimalFooter({
    super.key,
    this.type = AnimalFooterType.sea,
    this.seamless = false,
    this.content,
    this.defaultText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final footerColor = theme.colors.surfaceSubtle;
    final decoHeight = type == AnimalFooterType.tree ? 32.0 : 24.0;
    final localized = AnimalLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: availableWidth,
                height: decoHeight,
                child: CustomPaint(
                  size: Size(availableWidth, decoHeight),
                  painter: type == AnimalFooterType.tree
                      ? AnimalTreeCanopyPainter(color: footerColor)
                      : AnimalShorelineWavePainter(color: footerColor),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: footerColor,
              padding: EdgeInsets.symmetric(
                vertical: seamless ? theme.spacing.lg : theme.spacing.xl,
                horizontal: theme.spacing.lg + theme.spacing.xs,
              ),
              alignment: Alignment.center,
              child:
                  content ??
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AnimalIcon(
                        data: AnimalIcons.leaf,
                        size: 18,
                        color: theme.colors.primaryText,
                      ),
                      SizedBox(width: theme.spacing.sm),
                      Text(
                        defaultText ?? localized.footerDefaultText,
                        style: theme.typography.caption.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
            ),
          ],
        );
      },
    );
  }
}

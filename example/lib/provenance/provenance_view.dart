import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../l10n/generated/gallery_localizations.g.dart';

// The identity of this build, written by `dart run tool/build_info.dart`
// and passed to `flutter build` with --dart-define-from-file. Every value is
// empty when the build was not stamped.
abstract final class _BuildIdentity {
  static const String package = String.fromEnvironment('package');
  static const String version = String.fromEnvironment('version');
  static const String commit = String.fromEnvironment('commit');
  static const String flutterVersion = String.fromEnvironment(
    'flutter_version',
  );
  static const String dartVersion = String.fromEnvironment('dart_version');
  static const String publicApiSha256 = String.fromEnvironment(
    'public_api_sha256',
  );
  static const String license = String.fromEnvironment('license');

  static bool get stamped => commit.isNotEmpty;
}

class ProvenanceView extends StatelessWidget {
  const ProvenanceView({super.key});

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
            child: Text(localizations.provenanceTitle),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.provenanceDescription,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AnimalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AnimalIcon(
                      data: AnimalIcons.check,
                      size: 24,
                      color: theme.colors.primary,
                    ),
                    Text(
                      localizations.provenanceReleaseIdentity,
                      style: theme.typography.heading.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AnimalDivider(type: AnimalDividerType.dashed),
                const SizedBox(height: 16),
                if (!_BuildIdentity.stamped)
                  Text(localizations.provenanceUnavailable)
                else ...[
                  _buildRow(
                    context,
                    localizations.provenancePackageIdentity,
                    localizations.provenancePackageValue(
                      _BuildIdentity.package,
                      _BuildIdentity.version,
                    ),
                  ),
                  _buildRow(
                    context,
                    localizations.provenanceSourceCommit,
                    _BuildIdentity.commit,
                  ),
                  _buildRow(
                    context,
                    localizations.provenanceBuildSdk,
                    localizations.provenanceSdkValue(
                      _BuildIdentity.flutterVersion,
                      _BuildIdentity.dartVersion,
                    ),
                  ),
                  _buildRow(
                    context,
                    localizations.provenanceApiHash,
                    _BuildIdentity.publicApiSha256,
                  ),
                  _buildRow(
                    context,
                    localizations.provenanceUpstream,
                    localizations.provenanceUpstreamValue,
                  ),
                  _buildRow(
                    context,
                    localizations.provenanceLicense,
                    localizations.provenanceLicenseValue(
                      _BuildIdentity.license,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = AnimalIslandTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: theme.typography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.typography.body.copyWith(
                fontFamily: 'monospace',
                color: theme.colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

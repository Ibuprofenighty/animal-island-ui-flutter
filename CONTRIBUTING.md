# Contributing to Animal Island UI

Thanks for helping improve Animal Island UI! Bug reports, fixes, documentation
improvements and new ideas are all welcome.

## Getting set up

1. Install the Flutter version shown in the README badges (recorded in
   [`catalog/sdk.lock.json`](catalog/sdk.lock.json)); `pubspec.yaml` declares the
   minimum constraints.
2. Fork and clone the repository, then fetch dependencies for the package and the
   Gallery:

   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

3. Run the Gallery to see your changes: `cd example && flutter run -d chrome`.

## Making changes

- Public API is exported only from `lib/animal_island_ui.dart`. Keep implementation
  details under `lib/src/` and do not export them unintentionally.
- Components read styling from `AnimalIslandTheme`; avoid hard-coded colors and
  private default values (see [theme and tokens](docs/en/tokens.md)).
- User-visible package text goes through the English and Chinese ARB files so it
  can be localized.
- Replace old behavior instead of adding parallel implementations or
  compatibility aliases, and update every caller in the same change.
- Keep English and Chinese documentation in sync: `docs/en/` with `docs/zh/`,
  `README.md` with `README.zh-CN.md`, and the skill's `SKILL.md` with
  `SKILL.zh-CN.md`.
- If you change a public constructor, regenerate the API record and component
  references (see below) in the same pull request.

## Checks to run before opening a pull request

From the repository root:

```bash
dart format .
flutter analyze --fatal-infos
flutter test

# Gallery tests
cd example
flutter test
cd ..

# Generated API record and component references are up to date
dart run tool/generate.dart --check
dart run tool/generate_docs.dart --check

# Package files and a clean consumer build
dart run tool/package_check.dart
```

To regenerate after an API change, run `dart run tool/generate.dart` and
`dart run tool/generate_docs.dart` without `--check`.

## Pull requests

- Work on a focused branch and keep each pull request to one topic.
- Describe what changed and why, link related issues, and include screenshots or
  a short recording for visual changes.
- Add or update tests for behavior changes.
- List the commands you ran and their results; CI runs the same checks.
- Do not lower test thresholds or skip checks to make a build pass.

## Reporting issues

Use [GitHub Issues](https://github.com/Ibuprofenighty/animal-island-ui-flutter/issues)
with steps to reproduce, the expected and actual result, and your Flutter version
(`flutter --version`). For security problems, follow [SECURITY.md](SECURITY.md)
instead of opening a public issue.

## License

By contributing, you agree that your contributions are licensed under the
project's [Creative Commons Attribution-NonCommercial 4.0 International](LICENSE)
license (CC BY-NC 4.0), which does not permit commercial use.

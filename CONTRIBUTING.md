# Contributing to Animal Island UI

Thanks for your interest in Animal Island UI!

## Issues are welcome; pull requests are not accepted

This repository is published from a separate development workflow, so external
pull requests cannot be merged and are closed without review. Please open a
[GitHub Issue](https://github.com/Ibuprofenighty/animal-island-ui-flutter/issues)
instead — bug reports, documentation problems and feature ideas are all
welcome. A good report includes steps to reproduce, the expected and actual
result, and your Flutter version (`flutter --version`).

For security problems, follow [SECURITY.md](SECURITY.md) instead of opening a
public issue.

## Building from source

1. Install the Flutter version shown in the README badges (recorded in
   [`catalog/sdk.lock.json`](catalog/sdk.lock.json)).
2. Clone the repository and fetch dependencies for the package and the Gallery:

   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

3. Run the Gallery: `cd example && flutter run -d chrome`.

The same checks CI runs can be run locally from the repository root:

```bash
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
flutter analyze --fatal-infos
flutter test
(cd example && flutter test)
dart run tool/generate.dart --check
dart run tool/generate_docs.dart --check
dart run tool/package_check.dart
```

## License

Animal Island UI is licensed under the
[Creative Commons Attribution-NonCommercial 4.0 International](LICENSE) license
(CC BY-NC 4.0), which does not permit commercial use.

# Contributing to Animal Island UI for Flutter

Thank you for your interest in contributing!

## Development Workflow

1. Fork & clone the repo.
2. Ensure Flutter 3.47+ and Dart 3.13+ are installed.
3. Verify existing code:
   ```bash
   flutter test
   dart analyze
   node scripts/check-docs-sync.mjs
   ```
4. Create your feature branch (`feat/amazing-component`).
5. Ensure any changes to components are mirrored in:
   - `docs/design-system/components/`
   - `docs/zh-CN/design-system/components/`
   - `skills/animal-island-ui-style-flutter/references/components/` (<= 200 lines)
6. Verify `node scripts/check-docs-sync.mjs` exits with code 0.
7. Submit your Pull Request.

# Security Policy

## Supported versions

Animal Island UI is maintained on the `main` branch. Fixes are made against the
latest code; older versions do not receive separate backports.

## Reporting a vulnerability

Please **do not** post exploit details in a public issue.

- If private vulnerability reporting is enabled for the repository, use
  **Security → Report a vulnerability** on
  [GitHub](https://github.com/Ibuprofenighty/animal-island-ui-flutter/security).
- Otherwise, open a short public issue asking the maintainers for a private
  contact, without including any vulnerability details.

Please include the affected version or commit, a minimal reproduction and the
potential impact. This is a volunteer-maintained project, so response times are
not guaranteed, but reports are taken seriously.

## Scope notes

- Runtime dependencies are declared in [pubspec.yaml](pubspec.yaml): Flutter,
  `flutter_localizations`, `flutter_svg`, `characters` and `intl`.
- The built-in icons are SVG descriptors shipped with the package and rendered
  with `flutter_svg`. If you render your own SVG content, treat untrusted input
  with the same care as any other external data.
- Fonts are bundled with the package and are never downloaded at runtime.

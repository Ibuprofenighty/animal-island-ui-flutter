---
name: animal-island-ui-style-flutter
description: >
    Build Flutter UIs in the animal-island-ui style — a cozy island-style UI-inspired component
    library (warm earth tones, 50px pill shapes, 3D game-button depth, soft motion).
    Use when (1) building screens, widgets or pages with the animal_island_ui package in a Flutter
    project; (2) creating standalone Flutter widgets in this style; (3) the user asks for
    "a cozy island-style UI", "animal island style", or a cozy rounded game-like Flutter UI.
---

# animal-island-ui style (Flutter)

animal_island_ui is an enterprise-grade Flutter component library inspired by a cozy island-style UI design — 36 canonical components, 101 cute vector icons, zero 3rd-party UI dependencies.

Canonical design system: https://github.com/guokaigdg/animal-island-ui

## Pick your scenario first

| Scenario | Entry |
| :--- | :--- |
| Flutter project — `animal_island_ui` is in pubspec.yaml | [references/flutter-project.md](references/flutter-project.md) |
| Standalone Dart / single-file Flutter widget prototyping | [references/standalone-dart.md](references/standalone-dart.md) |

## The style in one paragraph

Warm parchment backgrounds (`AnimalColors.background` #F8F8F0), earth-brown text (`#794F27`, never pure black), mint-teal primary accent (`#19C8B9`), large-radius pill shapes (buttons and inputs are 50px pills; nothing interactive below 12px radius), 3D game button stacked shadow on primary buttons only (Offset(0, 5), blurRadius = 0), rounded Nunito + Noto Sans SC typography, soft spring curves over 150–350ms, and a mix of geometric shapes (swallowtail ribbon Title, digit-tile Countdown) with organic ones (SVG blob-clipped Modal).

## Component catalog

Props and constructors are grouped by category under `references/components/`:

| Category | Components | Reference |
| :--- | :--- | :--- |
| General | Button, Icon, Typewriter, Cursor | [general.md](references/components/general.md) |
| Layout | Card, Title, Divider, Background, Collapse, Tabs, Carousel | [layout.md](references/components/layout.md) |
| Form controls | Input, Switch, Checkbox, Radio, Select, DatePicker, TimePicker | [form-controls.md](references/components/form-controls.md) |
| Form container | Form, FormItem | [Form.md](references/components/Form.md) |
| Overlays | Modal, Drawer, Tooltip | [overlays.md](references/components/overlays.md) |
| Feedback | Progress, Loading, Skeleton, BackTop, Countdown, Time | [feedback.md](references/components/feedback.md) |
| Notification | Notification (imperative API) | [Notification.md](references/components/Notification.md) |
| Data display | Table, Pagination, CodeBlock, Tag, Image | [data-display.md](references/components/data-display.md) |
| Decorative | Footer | [decorative.md](references/components/decorative.md) |

## Hard rules (violations are bugs)

1. Never invent widget parameters. Every argument must exist on the Flutter class.
2. Import only from package root: `import 'package:animal_island_ui/animal_island_ui.dart';`.
3. Never use pure black text (`Colors.black`) or cold gray backgrounds. Use `AnimalColors.textPrimary` and `AnimalColors.background`.
4. Never use cold blue focus rings. Focus colors are warm yellow (`#FFCC00`) or mint primary.
5. Never give an interactive element corners sharper than 12px radius; buttons and inputs are 50px pills.
6. The 3D pixel-stack shadow (`Offset(0, 5)`) belongs to primary buttons only. Cards have no box-shadow. Switch has no outer blur shadow.
7. Modal keeps its SVG blob clip-path (`AnimalBlobClipper`) — never a plain rectangle. Title is a swallowtail ribbon.
8. Fonts are Nunito + Noto Sans SC; weight never below 400.
9. Motion uses smooth spring curves over 150–350ms.
10. Icons come from `AnimalIcon` or the 101 standalone icon widgets — never random raw emojis.

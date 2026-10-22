# Island UI Gallery

Independent Flutter consumer of the public `animal_island_ui` entrypoint, with the reference homepage, Skill guide and 40 component routes. The [reference Gallery](https://guokaigdg.github.io/animal-island-ui/#/) is the visual and interaction authority; see [design baseline](../docs/DESIGN.md).

Run from this directory:

```text
python ../tool/verify.py --generate-gallery-version
flutter pub get
flutter run -d windows
flutter run -d chrome
```

The Gallery composes app/pages/shared and uses public components for demonstrations. Component state, styling and behavior belong to the library; stories own demo data and explicit controlled values. Windows and Web are the first acceptance targets.

Font and asset provenance: [rights](../docs/RIGHTS.md), [asset inventory](../docs/asset-provenance.json), and [GROBOLD authorization](../docs/font-authorization.json). The Windows runner was created with Flutter tooling.

Status: **NOT_ACCEPTED**. Route presence, tests and builds do not establish all-state visual parity or commercial release acceptance. See [acceptance](../docs/ACCEPTANCE.md) for remaining gates.

The existing Home version badge is a generated projection of root `pubspec.yaml`; after changing the product version, run the version command above. The Gallery pubspec must match it, and validation rejects a stale projection. Reference provenance versions remain separate.

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

## Online preview / 在线预览

[Open the Flutter Gallery / 打开 Flutter Gallery](https://ibuprofenighty.github.io/animal-island-ui-flutter/).

The Gallery preview workflow tests the Gallery, builds its release Web bundle with the GitHub Pages base path and deploys only `example/build/web`. It runs on `main` pushes or manual dispatch. The independent Flutter checks workflow keeps its full validation behavior; preview availability is not a passing product-acceptance result.

Gallery 预览工作流在 `main` 推送或手动触发时运行 Gallery 测试，以 GitHub Pages 子路径构建 release Web 包，仅部署 `example/build/web`。独立的 Flutter checks 工作流继续执行原有完整验证；预览可访问不代表产品验收通过。

Before upload, `tool/prepare_gallery_web.py` names the generated bootstrap and app scripts by their content hashes. The index references only these scripts, preventing an old cached entry script from loading a previous Gallery. Flutter's generated service-worker retirement remains unchanged.

上传前，`tool/prepare_gallery_web.py` 按内容哈希命名生成的启动脚本与应用脚本，页面仅引用这两个文件，避免旧缓存入口加载前一版 Gallery；Flutter 自带的 service worker 退役机制保持不变。

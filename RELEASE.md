# Release status / 发布状态

## Version scope decision / 本版本范围决定 (2026-10-18)

User decisions, 2026-10-18: SDK-COMBOBOX-001 is an approved exception for this version. The installed SDK still cannot project the Select combobox role; the one button/TextField projection remains, without SDK modifications or DOM shims. This is not an implemented role or a passed role test. Keyboard, focus, names/states, IME and contrast requirements remain. The user confirmed private authorization for all21 previously investigated assets (4 library scene SVGs,1 Gallery logo,16 Gallery photos): "这些也是私人授权". See docs/asset-private-authorization.json for the original confirmation and time. Private-use authorization is no longer unknown or a remaining private-use acceptance item. Preserve provenance and the earlier private-only authorization history. The user subsequently confirmed public repository redistribution on2026-10-22; current scope and original confirmation are recorded in docs/RIGHTS.md. This is not independent legal verification or an unconditional commercial license. Investigation is stopped: do not investigate, contact others, request documents, replace or remove assets. Existing GROBOLD private authorization remains. The user approved60fps as the baseline direction for performance diagnosis and an acceptance proposal; detailed sampling, percentile, startup and size thresholds remain proposed until agreed. No installation, screen readers or supervision restart; do not touch the separately owned keep-awake helper.

用户于2026-10-18批准SDK-COMBOBOX-001为本版本例外：已安装SDK仍不能投射Select的combobox角色，保留唯一button/TextField投射，不修改SDK、不加DOM补丁。例外不等于角色已实现或角色测试通过；键盘、焦点、名称/状态、输入法及对比度要求保持。用户已确认此前21项素材（4张库内场景SVG、1个Gallery Logo、16张Gallery照片）“这些也是私人授权”，原文及实际确认时间保存在docs/asset-private-authorization.json；私人使用授权不再未知，也不再是本次私人使用验收未决项。保留来源及此前仅限私人使用授权的历史。用户于2026-10-22另行确认可随公开仓库分发；当前范围与原文统一记录在docs/RIGHTS.md。这不是独立法律核验或无条件商业许可。授权追溯停止，不再调查、联系他人、索要文件、自行替换或移除素材；GROBOLD既有私人授权不变。用户批准以60fps为基础继续性能诊断并拟定验收方案，采样、分位数、启动及体积的具体门槛仍为待确认提案。不安装软件、不做读屏、不恢复监督，不操作另有所有者的防睡眠程序。

Current finite usability and complete production acceptance are separate scopes. Source-bound accepted limitations are decisions, not unanswered blockers or passing numerical tests. The single current status/remaining-work owner is `scratch/global-audit-20261014T035753Z/report.json` in the delivery workspace, outside the source archives; the delivery review entry identifies it. Presentation rules remain in [DESIGN](docs/DESIGN.md), not a second release-status ledger.

有限范围的可用性与完整生产验收分别报告；已接受的具名限制不是尚未作决定的阻塞，也不等于数值测试通过。当前结论和待验项只由交付工作区的 `scratch/global-audit-20261014T035753Z/report.json` 维护，该文件不在源码归档内，交付入口提供位置；呈现规则仍归 [DESIGN](docs/DESIGN.md)，此处不另维护状态副本。

**Experimental — NOT_ACCEPTED.** The package version is defined in [pubspec.yaml](pubspec.yaml); changes are recorded in [CHANGELOG.md](CHANGELOG.md).

Scope: all 40 reference components, the Skill guide and homepage, with Windows + Web first. [library.json](library.json) defines the scope and checks; [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md) records acceptance requirements. [tool/reference_coverage.py](tool/reference_coverage.py) measures registered stories; route coverage is not state or visual acceptance.

Automated results are development evidence bound to their source snapshot. A prior build or test result does not validate changed source. Complete route/state comparison, accessibility, package consumption, performance and rights review remain release gates; current gaps must stay explicit. The superseded custom Gallery provides no parity evidence.

GROBOLD authorization is recorded in [docs/font-authorization.json](docs/font-authorization.json). Asset provenance and remaining release clearance are tracked in [docs/RIGHTS.md](docs/RIGHTS.md). No external publishing has occurred.

版本以 pubspec.yaml 为唯一来源；当前仍为实验版本、未验收。页面覆盖与自动检查不等于全状态复刻或商业发布通过；变更后不得沿用旧源码的通过结论。

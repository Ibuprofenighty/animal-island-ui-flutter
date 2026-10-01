# Package setup / 包接入

Use the [pubspec](../../../pubspec.yaml) for declared dependencies and SDK constraints.
依赖与 SDK 以 pubspec 为准。

Import the [public root](../../../lib/animal_island_ui.dart) and check its actual declarations.
An example app composition is in [example/lib/app.dart](../../../example/lib/app.dart);
do not copy the whole Gallery as boilerplate. Modal and Drawer use routes; Notification
and Loading use hosts as their API describes. Place a host inside the Flutter inherited
contexts it requires, and do not assume every overlay shares one lifecycle.
使用包根导出并核对实际声明。示例应用装配见 example/lib/app.dart，不要把整个 Gallery
当作模板。route 与 host 职责不同，宿主必须处于所需 Flutter inherited context 内。

The EN/ZH ARB pair is the only source for package-owned text. The generated
`AnimalLocalizations` class is exported directly from the package root. Install its
delegates and supported locales on `MaterialApp`; use `resolveAnimalLocale` so `zh`
regions select Chinese and all other or missing locales select English. The package
declares `flutter_localizations` and `intl` as runtime dependencies.

EN/ZH ARB 是库内文案的唯一来源。生成的 `AnimalLocalizations` 类由包根直接导出。
在 `MaterialApp` 上配置其 delegates 和 supported locales；`resolveAnimalLocale` 将
`zh` 地区映射为中文，其余和缺省 locale 映射为英文。包将 `flutter_localizations` 与
`intl` 声明为运行依赖。

Themes, fonts and icons are described in [tokens](../../../docs/en/tokens.md) /
[中文](../../../docs/zh/tokens.md). The library registers bundled fonts under package-qualified
family names.
Install `AnimalIslandTheme.light.toThemeData()`, the dark preset's `toThemeData()`,
or a custom theme's same conversion as the Material theme. Below it,
`AnimalIslandTheme.of(context)` reads the installed value; without an extension it
throws `StateError`. Theme values contain `colors`, `typography`, `radii`, `spacing`,
`shadows` and `motion`; customize a family with `copyWith` and replace it on the
theme. Do not construct an independent Animal Island `ThemeData` or use removed
static tokens. 库字体使用包限定 family 名称。应用通过浅色、深色或自定义主题的
`toThemeData()` 配置 Material 主题；`AnimalIslandTheme.of(context)` 读取已配置的六组值，
缺少扩展会抛 `StateError`。先用家族的 `copyWith` 定制，再替换到主题；不得维护另一套
主题转换或旧静态 token。

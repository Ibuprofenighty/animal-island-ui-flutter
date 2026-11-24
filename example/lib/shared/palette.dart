import 'package:flutter/painting.dart';

/// The one owner of Gallery demonstration colours (shell chrome, Home
/// wallpaper ink, story frames, demo swatches and sample data). Pages and
/// shared widgets reference these names and never hold colour literals.
///
/// Values that the library already exposes through its public root
/// (IslandTokens, IslandColorway, IslandBackgroundType) are consumed from the
/// library at their use site and are not redefined here. Library-internal
/// component recipes are not public, so a Gallery role that repeats one of
/// their values is a separate demonstration colour. Role aliases point at an
/// existing name when the same value serves the same purpose.
abstract final class GalleryPalette {
  // Shared story ink and frames.

  /// Reference demo text colour (`#725d42`) for story labels, captions and
  /// sample text.
  static const storyInk = Color(0xff725d42);

  /// Demo hairline (`#e8e2d6`): story frames, sidebar/header rules.
  static const rule = Color(0xffe8e2d6);
  static const demoSurface = Color(0xffffffff);
  static const demoPanel = Color(0xfffaf8f3);
  static const demoPanelDashed = Color(0xfffaf8f2);
  static const demoPanelDashedBorder = Color(0xffe0d8c8);

  /// Inline code chips (BackTop, Skill, Tooltip stories).
  static const codeChip = Color(0xfff0e8d8);

  /// Countdown custom-reminder demo: berry in the last 5 seconds; the
  /// reference `#b25770` (4.2:1 on the plates) deepened in hue to 4.5:1.
  static const countdownReminderBerry = Color(0xffac526b);

  /// Countdown custom-reminder demo: warm brown from 20 seconds; the
  /// reference `#9a6a38` (4.2:1) deepened in hue to 4.5:1.
  static const countdownReminderBrown = Color(0xff946533);

  /// Time custom-style demo (reference `.my-time`): clock ink
  /// `--animal-time-color` `#fffdf4`.
  static const timeCustomClock = Color(0xfffffdf4);

  /// Time custom-style demo weekday `--animal-primary-color` `#ffd166`.
  static const timeCustomWeekday = Color(0xffffd166);

  /// Time custom-style demo month-day: the demo leaves
  /// `--animal-text-color-secondary` at `#9f927d` (4.46:1 on the capsule),
  /// lightened in hue to 4.5:1.
  static const timeCustomDate = Color(0xffa0937e);

  /// Time custom-style demo decorative dot `--animal-text-color-disabled`.
  static const timeCustomDot = Color(0xffe0bd75);

  /// Time custom-style demo capsule `--animal-primary-color-bg` `#3d2a17`.
  static const timeCustomCapsule = Color(0xff3d2a17);

  /// Time custom-style demo 160deg gradient stops at 0% and 55%; the 100%
  /// stop is the library `leaf` (`#19c8b9`).
  static const timeCustomGradientStart = Color(0xff0f4c46);

  /// Reference `#137f74` deepened in its own hue so the cream clock keeps
  /// 4.5:1 over the lightest gradient point under it (4.54:1 at the reference
  /// capsule height).
  static const timeCustomGradientMiddle = Color(0xff00756a);

  /// Time custom-style demo shadow rgba(15, 76, 70, .28).
  static const timeCustomShadow = Color(0x470f4c46);

  // API table (StoryApiTable) and its code label.
  static const apiTableBackground = Color(0xff2b2118);
  static const apiTableRule = Color(0xff3d3028);
  static const apiTableHeader = apiTableRule;
  static const apiTableHeading = Color(0xffe8d5bc);
  static const apiTableName = Color(0xffe8c87a);
  static const apiTableType = Color(0xffd4a0e0);
  static const apiTableDefault = Color(0xffa8d4a0);
  static const apiTableCell = Color(0xffc8bba8);
  static const codeLabelFill = apiTableRule;
  static const codeLabelText = Color(0xffe7e4e0);

  // Shell chrome (sidebar, header, navigation, NEW badge, wallpaper dots).
  static const sidebar = demoPanel;
  static const sidebarBorder = Color(0xfffafafa);
  static const sidebarShadow = Color(0x1a3d3428);
  static const sidebarShadowMobile = Color(0x26000000);
  static const sidebarWave = Color(0xffa2b0e7);
  static const navActive = Color(0xffb7c6e5);
  static const navHover = Color(0xffd6dff0);

  /// Reference mobile drawer overlay rgba(0,0,0,.35).
  static const drawerScrim = Color(0x59000000);

  /// Header glass rgba(255,252,244,.92); the fractional alpha is exact.
  static const headerGlass = Color.fromRGBO(255, 252, 244, .92);
  static const newBadgeActive = Color(0xffffffff);

  /// Second gradient stop; the first is IslandColorway.red.accent.
  static const newBadgeGradientEnd = Color(0xfff7825a);
  static const newBadgeShadowActive = Color(0x26725d42);
  static const newBadgeShadow = Color(0x40725d42);
  static const wallpaperLargeDot = Color(0x665aa069);
  static const wallpaperSmallDot = Color(0x4d6eb47d);

  // Home wallpaper (reference demo/HomePage.tsx).
  static const homeCream = Color(0xfffff9e6);
  static const homeTitle = storyInk;
  static const homeBody = Color(0xff7c5734);
  static const homeGiantIcon = Color(0xffffffff);
  static const homeVersionBadge = Color(0xffe6f9f6);
  static const homeHeroShadow = Color(0x66000000);
  static const homeHintShadow = Color(0x4d000000);

  /// Feature card lift shadow base; its alpha follows the lift (.15 max).
  static const homeCardLift = storyInk;

  // Story demo colours.
  static const backTopCodeInk = Color(0xff746753);
  static const backTopBubble = Color(0x73ffffff);
  static const backTopChip = Color(0x59ffffff);

  /// Photograph caption gradient rgba(43,33,24,.72); the alpha is exact.
  static const carouselCaptionShade = Color.fromRGBO(43, 33, 24, .72);
  static const carouselCaption = Color(0xfffff9e3);
  static const codeBlockDemoBackground = Color(0xff242c46);

  // Cursor story native-control imitation (browser UA defaults).
  static const nativeControlBorder = Color(0xff767676);
  static const nativeControlFill = Color(0xffefefef);
  static const nativeInputFill = Color(0xffffffff);
  static const nativeLink = Color(0xff0000ee);

  static const footerDemoSurface = Color(0xfff7f3ea);
  static const formNoticeFill = Color(0xfffffbe6);
  static const formNoticeBorder = Color(0xffffe58f);
  static const formNoticeText = Color(0xff874d00);
  static const iconDemoCoffee = Color(0xffe05260);
  static const iconDemoCherry = Color(0xff2a9d8f);
  static const iconTile = Color(0xffffffff);
  static const iconTileHover = Color(0xfffaf7f0);
  static const iconTileHoverBorder = Color(0xffe8dec7);
  static const inputDemoCardBorder = Color(0xfff1d5a4);

  /// Modal story barriers: default (as showIslandModal), light and dark.
  static const modalBarrier = Color(0x59000000);
  static const modalBarrierLight = Color(0x14000000);
  static const modalBarrierDark = Color(0xbf000000);

  /// Reference demo span #FD9303 (2.0:1 on the modal paper), OKLCH-deepened
  /// in the same hue to 4.5:1.
  static const modalEmphasis = Color(0xffa45d01);
  static const notificationDemoText = homeBody;
  static const demoStrongInk = Color(0xff794f27);
  static const skeletonDemoSurface = Color(0xfffafaf5);
  static const skeletonDemoBorder = Color(0xffe8dcc8);
  static const skeletonDemoCard = homeVersionBadge;
  static const tooltipDemoEmphasis = Color(0xffd4834a);
  static const tooltipDemoInputFill = Color(0xfff7f3df);
  static const tooltipDemoInputBorder = Color(0xffc4b89e);

  /// Table story hobby pill backgrounds (text uses IslandColorway ink).
  static const hobbyMusic = Color(0xffece7f8);
  static const hobbySport = Color(0xfffff0dc);
  static const hobbySinging = Color(0xffffe8e4);
  static const hobbyFishing = Color(0xffe2effd);
  static const hobbyDrawing = Color(0xffffe8f1);
  static const hobbyOther = Color(0xffe0f7f4);

  /// Reference CARD_COLORS tile text, in IslandBackgroundType order. Two
  /// values are deepened to reach 4.5:1 on their dot composite: dots-dark-green
  /// #3a6b3a (3.79) -> #2f5d2f, and dots-pink #a85565 (3.75) -> #8b4654, the
  /// shared pink paper ink.
  static const backgroundTileInks = [
    storyInk,
    storyInk,
    Color(0xff2f5d2f),
    storyInk,
    storyInk,
    storyInk,
    Color(0xff8b4654),
    Color(0xff6a3a9a),
    Color(0xff4a5a8a),
    Color(0xff7a6528),
    Color(0xff8a4a2a),
    Color(0xff2a6b5a),
    Color(0xff3a6b3a),
    Color(0xff9a3a3a),
    Color(0xff5a6b28),
    Color(0xff6a5a28),
    Color(0xff5a4a2a),
    Color(0xff8a4a2a),
    Color(0xff5a5a5a),
  ];

  /// Title story demo backgrounds: (base, large dot, small dot, border).
  /// These are Gallery backgrounds, not alternate Title implementations.
  static const titleDemoTones = <(Color, Color, Color, Color)>[
    (
      Color(0xffddf0fa),
      Color(0x2650aae6),
      Color(0x1a8cd2fa),
      Color(0xff90cce8),
    ),
    (
      Color(0xfffdf3d8),
      Color(0x26dcb450),
      Color(0x1ff0d278),
      Color(0xffe8d090),
    ),
    (
      Color(0xffede8f8),
      Color(0x26a078e6),
      Color(0x1fc8a0fa),
      Color(0xffc0a8e8),
    ),
    (
      Color(0xfffce8e0),
      Color(0x26f0785a),
      Color(0x1fffaa8c),
      Color(0xffe8b0a0),
    ),
    (
      Color(0xffd8f5f0),
      Color(0x2e3cbeaa),
      Color(0x1f78e6d2),
      Color(0xff88d8c8),
    ),
    (
      Color(0xffe8f5d8),
      Color(0x2e78c850),
      Color(0x1fb4e678),
      Color(0xffb8d890),
    ),
  ];

  // Chart story (reference demo/components/Chart). The series sets mirror
  // gallery-shared.ts in order. Chart marks are necessary graphics: each
  // value is measured on the four chart surfaces it is drawn on (default
  // #f8f8f0, cream, mint, blossom) and, where the reference fails 3:1, moved
  // along OKLCH lightness in its own hue until it passes on all four.

  /// Reference meadow `#48a891 #97bc76 #e4b75c #ce9271 #aa91ba`
  /// (1.7–2.8:1).
  static const chartMeadow = [
    Color(0xff3d9e88),
    Color(0xff769955),
    chartHoney,
    Color(0xffbc8161),
    Color(0xff9e86ae),
  ];

  /// Reference sunset `#dc886b #e4b75c #c993a5 #ab8cba #8dab9b`
  /// (1.7–2.8:1).
  static const chartSunset = [
    Color(0xffcc795d),
    chartHoney,
    Color(0xffb58092),
    Color(0xffa284b1),
    Color(0xff789586),
  ];

  /// Reference forest `#408f7c` (passes, kept) `#68a18b #8fb6a0 #b3cbb4
  /// #d2dfc8` (1.3–2.8:1); the deepened tail no longer reads as a ramp.
  static const chartForest = [
    Color(0xff408f7c),
    Color(0xff629a85),
    Color(0xff719782),
    Color(0xff7e947f),
    Color(0xff87927d),
  ];

  /// Reference flowers `#a88abb #d38ba3 #e9b782 #92b7a0 #c1b979`
  /// (1.7–2.9:1).
  static const chartFlowers = [
    Color(0xffa184b4),
    Color(0xffc17a92),
    Color(0xffb58552),
    Color(0xff739781),
    Color(0xff999052),
  ];

  /// Reference `#e4b75c`, shared by meadow and sunset.
  static const chartHoney = Color(0xffb38827);

  /// Ring goal 待完成 sector: reference `#e4dcc9` (1.3:1).
  static const chartRingRemainder = Color(0xff968e7d);

  /// Reference `creamSurface`, `mintSurface`, `blossomSurface` chart
  /// containers (decorative borders keep the reference).
  static const chartCreamSurface = Color(0xfffffaf0);
  static const chartCreamBorder = Color(0xffeadfc9);
  static const chartMintSurface = Color(0xfff3f8ef);
  static const chartMintBorder = Color(0xffdce6d6);
  static const chartBlossomSurface = Color(0xfffcf5f1);
  static const chartBlossomBorder = Color(0xffeadcd4);

  /// Reference `.note` `#8a7b66` (4.1:1 on the white section) deepened to
  /// 4.5:1.
  static const chartNote = Color(0xff837460);

  /// Catalog card hover fill and decorative border (reference `#f0f5eb`,
  /// `#b8cbb2`).
  static const chartCatalogHover = Color(0xfff0f5eb);
  static const chartCatalogHoverBorder = Color(0xffb8cbb2);

  /// Gallery item action hover (reference `#f0e8d8`).
  static const chartActionHover = codeChip;

  /// API table required-prop mark (reference `#f0a870`, 7.9:1 on the table
  /// background `#2b2118`).
  static const apiTableRequired = Color(0xfff0a870);

  // Gallery shell inks (reference demo/App.tsx, ComponentPage.tsx) under the
  // measured-colour rule. The sidebar list scrolls over the cream aside
  // `#faf8f3`, its `#a2b0e7` bottom wave and the `#d6dff0` hover fill.

  /// Sidebar header, mobile header title and its glyphs: the reference
  /// `#725d42` passes (5.9:1 on the aside, 5.1:1 on the header glass).
  static const shellInk = storyInk;

  /// Sidebar group labels: reference `#a0936e` (2.9:1 on the aside, 1.4:1 on
  /// the wave) deepened in hue to 4.5:1 on the wave.
  static const navGroupInk = Color(0xff504422);

  /// Sidebar items: reference `#8a7b66` (3.9:1 aside, 3.1:1 hover, 1.9:1
  /// wave) deepened in hue to 4.5:1 on the wave.
  static const navInk = Color(0xff514330);

  /// Active sidebar item: reference white (1.7:1 on `#b7c6e5`) moved along
  /// lightness (achromatic) to 4.5:1.
  static const navActiveInk = Color(0xff525252);

  /// Component page description: reference `#794f27` (3.7:1 on `#88c9a1`,
  /// 3.1:1 over a large wallpaper dot) deepened in hue to 4.5:1 over any
  /// wallpaper pixel.
  static const pageDescription = Color(0xff5e360b);

  /// Home feature/component card title (`#725d42`, 5.6:1 on the card paper).
  static const homeCardTitle = storyInk;

  /// Home feature/component card description (`#7c5734`, 5.8:1).
  static const homeCardBody = homeBody;

  /// Icon demo bulb `color`: reference `#e9c46a` (1.7:1 on the white story
  /// panel) deepened in hue to 3:1.
  static const iconDemoBulb = Color(0xffb49033);

  /// Icon tile `XxxIcon` caption: reference `#a0936e` (3.0:1 on white,
  /// 2.8:1 on the `#faf7f0` hover) deepened in hue to 4.5:1 on both.
  static const iconTileName = Color(0xff7e714e);

  /// Cursor story native button text and disabled button, measured on the
  /// `#faf8f2` demo box (Chrome UA ButtonText, and the disabled composites;
  /// disabled controls keep the reference).
  static const nativeButtonText = Color(0xff000000);
  static const nativeDisabledBorder = Color(0xffcdccc9);
  static const nativeDisabledFill = Color(0xffebeae7);
  static const nativeDisabledText = Color(0xffa9a8a6);

  // Chart Gallery inks resolved from the reference `:root` theme variables
  // (`--animal-text-color` #794f27, `--animal-text-color-secondary` #9f927d),
  // not the `#725d42` fallbacks, under the measured-colour rule.

  /// Chart gallery header body (`.header p`): reference `#9f927d` (3.0:1 on
  /// the white story panel) deepened in hue to 4.5:1.
  static const chartGalleryBody = Color(0xff827561);

  /// Chart gallery item link (`.actions`, `更多…示例`): reference `#9f927d`
  /// (3.0:1 on white, 2.5:1 on the `#f0e8d8` hover) deepened in hue to 4.5:1
  /// on both, the value [backTopCodeInk] takes for the same pair.
  static const chartActionInk = backTopCodeInk;

  /// Chart gallery 查看配置 summary and its marker (`reset.less`
  /// `[class^='animal-']`): reference `#794f27` passes (5.8:1 on the hover).
  static const chartSummaryInk = demoStrongInk;

  /// Chart catalog card description (`.catalog a`): reference `#9f927d`
  /// (2.9:1 on the `#f8f8f0` card, 2.8:1 on the `#f0f5eb` hover) deepened in
  /// hue to 4.5:1 on both.
  static const chartCatalogBody = Color(0xff7a6e5a);

  /// Typewriter third line: reference `#FD9303` (2.1:1 on the `#faf8f2`
  /// dashed demo box) moved along OKLCH lightness in its own hue, chroma
  /// gamut-mapped as [modalEmphasis], until it passes 4.5:1 there (4.51:1).
  static const typewriterEmphasis = Color(0xffaa6000);

  /// Form story `liveValues` line: reference `#5b8def` (2.90:1 on the
  /// orange pattern card `#fff0e8`, 2.57:1 over its dot) moved along OKLCH
  /// lightness in its own hue until it passes 4.5:1 over any card pixel
  /// (5.14:1 on the fill, 4.50:1 over the dot centre `#fadfd1`).
  static const formLiveValues = Color(0xff3361c7);
}

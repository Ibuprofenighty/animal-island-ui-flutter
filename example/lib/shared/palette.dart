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

  /// Countdown custom-reminder demo: berry (`#b25770`) in the last 5 seconds.
  static const countdownReminderBerry = Color(0xffb25770);

  /// Countdown custom-reminder demo: warm brown (`#9a6a38`) from 20 seconds.
  static const countdownReminderBrown = Color(0xff9a6a38);

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
  static const nativeControlFill = Color(0xfff0f0f0);
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
}

import 'package:flutter/painting.dart';

/// Tier 1 of the colour system: every raw colour value the library paints
/// outside its indexed foundation tables ([IslandColorway] data, the generated
/// Background/sprinkle tables), defined exactly once.
///
/// Names follow a tonal palette (as in Material 3 tonal palettes): a hue
/// family plus the OKLCH lightness × 1000 of the opaque value
/// (`teal750` = #19c8b9). A translucent value appends `A` and its alpha in
/// percent of the same base (`brown492A10` = #725d42 at 0x1a). Families:
/// neutral (chroma < .012), sand/brown (warm low-chroma), orange, yellow,
/// green, teal, blue, violet and red by OKLCH hue. Near-identical values keep
/// separate names; merging them would change rendering.
///
/// Semantic roles ([IslandTokens]) and the per-component recipes in
/// `recipes/` reference these names; components and Gallery never hold
/// colour literals. Internal: not exported from the public root.
abstract final class Primitive {
  // neutral
  static const neutral0 = Color(0xff000000);
  static const neutral0A10 = Color(0x1a000000);
  static const neutral0A25 = Color(0x40000000);
  static const neutral0A3 = Color(0x08000000);
  static const neutral0A30 = Color(0x4d000000);
  static const neutral0A35 = Color(0x59000000);
  static const neutral0A55 = Color(0x8c000000);
  static const neutral0A58 = Color(0x94000000);
  static const neutral0A60 = Color(0x99000000);
  static const neutral0A8 = Color(0x14000000);
  static const neutral0A85 = Color(0xd9000000);
  static const neutral157A56 = Color(0x900f0c08);
  static const neutral157A82 = Color(0xd10f0c08);
  static const neutral285 = Color(0xff2a2a2a);
  static const neutral655A8 = Color(0x14958f8f);
  static const neutral834 = Color(0xffc4c9d0);
  static const neutral893 = Color(0xffd8dce2);
  static const neutral969 = Color(0xfff5f5f0);
  static const neutral977 = Color(0xfff8f8f0);
  static const neutral977A60 = Color(0x99f8f8f0);
  static const neutral979 = Color(0xfffaf8f2);
  static const neutral984 = Color(0xfffbfaf5);
  static const neutral994 = Color(0xfffffdf7);
  static const neutral994A88 = Color(0xe0fffdf7);
  static const neutral1000 = Color(0xffffffff);
  static const neutral1000A0 = Color(0x00ffffff);
  static const neutral1000A24 = Color(0x3dffffff);
  static const neutral1000A45 = Color(0x73ffffff);
  static const neutral1000A55 = Color(0x8cffffff);
  static const neutral1000A60 = Color(0x99ffffff);
  static const neutral1000A75 = Color(0xbfffffff);
  static const neutral1000A88 = Color(0xe0ffffff);

  // sand
  static const sand501 = Color(0xff6c6251);
  static const sand503 = Color(0xff716244);
  static const sand520 = Color(0xff746753);
  static const sand523 = Color(0xff736857);
  static const sand538 = Color(0xff796c5a);
  static const sand541 = Color(0xff7a6d59);
  static const sand552 = Color(0xff7d705c);
  static const sand619 = Color(0xff8f8474);
  static const sand641 = Color(0xff978b73);
  static const sand665 = Color(0xffa0936e);
  static const sand666 = Color(0xff9f927d);
  static const sand666A35 = Color(0x599f927d);
  static const sand706 = Color(0xffad9e88);
  static const sand720 = Color(0xffb6a184);
  static const sand786 = Color(0xffc4b89e);
  static const sand786A10 = Color(0x1ac4b89e);
  static const sand786A15 = Color(0x26c4b89e);
  static const sand824 = Color(0xffd5c3a2);
  static const sand826 = Color(0xffd4c4a8);
  static const sand839 = Color(0xffd4c9b4);
  static const sand887 = Color(0xffdfd9ce);
  static const sand899 = Color(0xffe8dcc8);
  static const sand901 = Color(0xffe9ddc6);
  static const sand902 = Color(0xffe8dec7);
  static const sand913 = Color(0xffeae2ce);
  static const sand914 = Color(0xffe8e2d6);
  static const sand923 = Color(0xffeae5db);
  static const sand931 = Color(0xffece8dc);
  static const sand933 = Color(0xfff0e8d8);
  static const sand943 = Color(0xfff0ece2);
  static const sand955 = Color(0xfff4f0e4);
  static const sand956 = Color(0xfff5f1dc);
  static const sand962 = Color(0xfff7f3df);
  static const sand965 = Color(0xfffff3d1);
  static const sand971 = Color(0xfffdf6d9);
  static const sand978 = Color(0xfffff7e6);
  static const sand985A18 = Color(0x2efffaeb);
  static const sand986 = Color(0xfffffbe7);
  static const sand991A55 = Color(0x8cfffcf2);
  static const sand993 = Color(0xfffffdf4);

  // brown
  static const brown257 = Color(0xff2b2118);
  static const brown257A55 = Color(0x8c2b2118);
  static const brown321 = Color(0xff3d3028);
  static const brown321A94 = Color(0xf03d3028);
  static const brown331A0 = Color(0x003d3428);
  static const brown331A10 = Color(0x1a3d3428);
  static const brown331A12 = Color(0x1f3d3428);
  static const brown331A16 = Color(0x293d3428);
  static const brown331A18 = Color(0x2e3d3428);
  static const brown331A6 = Color(0x0f3d3428);
  static const brown331A8 = Color(0x143d3428);
  static const brown367 = Color(0xff4b3b31);
  static const brown368 = Color(0xff573719);
  static const brown394 = Color(0xff603d1c);
  static const brown407 = Color(0xff5a4530);
  static const brown440 = Color(0xff714821);
  static const brown466 = Color(0xff794f27);
  static const brown466A14 = Color(0x24794f27);
  static const brown466A16 = Color(0x29794f27);
  static const brown492 = Color(0xff725d42);
  static const brown492A0 = Color(0x00725d42);
  static const brown492A10 = Color(0x1a725d42);
  static const brown492A12 = Color(0x1f725d42);
  static const brown538 = Color(0xff7f6a51);
  static const brown544 = Color(0xff836b4e);
  static const brown603 = Color(0xff937d61);
  static const brown621 = Color(0xff9a835a);
  static const brown658 = Color(0xff9d8f7e);
  static const brown707 = Color(0xffb59c7c);
  static const brown722 = Color(0xffb8a184);
  static const brown760 = Color(0xffbdaea0);
  static const brown798 = Color(0xffd4b896);
  static const brown839 = Color(0xffd5c8b8);
  static const brown882 = Color(0xffe8d5bc);
  static const brown882A30 = Color(0x4de8d5bc);
  static const brown935 = Color(0xffffe4cc);

  // orange
  static const orange550 = Color(0xffa55d05);
  static const orange661 = Color(0xffcc7b50);
  static const orange736 = Color(0xffe59266);
  static const orange754A50 = Color(0x80f49628);
  static const orange784 = Color(0xfff5a623);
  static const orange789 = Color(0xfff0a870);

  // yellow
  static const yellow426A22 = Color(0x385b4e1e);
  static const yellow426A32 = Color(0x525b4e1e);
  static const yellow431 = Color(0xff654c01);
  static const yellow524 = Color(0xff886300);
  static const yellow541 = Color(0xff8a6a08);
  static const yellow642 = Color(0xffaf8600);
  static const yellow654 = Color(0xffb4890c);
  static const yellow760 = Color(0xffdba90e);
  static const yellow795 = Color(0xffe0b800);
  static const yellow803 = Color(0xffe4b84f);
  static const yellow820 = Color(0xffffb400);
  static const yellow834 = Color(0xffe9c46a);
  static const yellow838 = Color(0xfff5c31c);
  static const yellow844 = Color(0xffffc107);
  static const yellow844A50 = Color(0x80ffc107);
  static const yellow865 = Color(0xfff7cd67);
  static const yellow865A85 = Color(0xd9f7cd67);
  static const yellow866A15 = Color(0x26ffcc00);
  static const yellow866A30 = Color(0x4dffcc00);
  static const yellow866A70 = Color(0xb3ffcc00);
  static const yellow867 = Color(0xfff5d04a);
  static const yellow886 = Color(0xffffd54f);
  static const yellow914 = Color(0xffffe08a);
  static const yellow934 = Color(0xfffbeaa1);
  static const yellow945 = Color(0xffffeea0);

  // green
  static const green316 = Color(0xff173a27);
  static const green495 = Color(0xff3d7200);
  static const green526 = Color(0xff4a7a1d);
  static const green625 = Color(0xff579d00);
  static const green641 = Color(0xff639d64);
  static const green713 = Color(0xff6fba2c);
  static const green713A50 = Color(0x806fba2c);
  static const green730 = Color(0xff9bae98);
  static const green730A35 = Color(0x599bae98);
  static const green768 = Color(0xff92c294);
  static const green770 = Color(0xff8ac68a);
  static const green772 = Color(0xff7ccc70);
  static const green781 = Color(0xff88c9a1);
  static const green803 = Color(0xff86d67a);
  static const green810 = Color(0xffb7c6b5);
  static const green825 = Color(0xffa8d4a0);
  static const green826 = Color(0xffabd2ac);
  static const green882 = Color(0xffc5e1c6);
  static const green923 = Color(0xffd8efc1);
  static const green957 = Color(0xffeaf6db);
  static const green977 = Color(0xfff5fae9);

  // teal
  static const teal270 = Color(0xff172b26);
  static const teal333 = Color(0xff243c33);
  static const teal394 = Color(0xff005249);
  static const teal408 = Color(0xff00564f);
  static const teal433 = Color(0xff005e56);
  static const teal474 = Color(0xff006b62);
  static const teal581 = Color(0xff008e81);
  static const teal609 = Color(0xff259689);
  static const teal626 = Color(0xff039d91);
  static const teal632 = Color(0xff3b9d85);
  static const teal637 = Color(0xff03a193);
  static const teal638 = Color(0xff04a195);
  static const teal699 = Color(0xff14b6a8);
  static const teal702 = Color(0xff19b7a7);
  static const teal720 = Color(0xff50b9ab);
  static const teal728 = Color(0xff0cc0b5);
  static const teal739 = Color(0xff0ec4b6);
  static const teal750 = Color(0xff19c8b9);
  static const teal750A14 = Color(0x2419c8b9);
  static const teal750A30 = Color(0x4d19c8b9);
  static const teal790 = Color(0xff3dd4c6);
  static const teal844 = Color(0xff7fe0d5);
  static const teal912 = Color(0xffc2ece6);
  static const teal935 = Color(0xffd6f0ea);
  static const teal967 = Color(0xffe6f9f6);
  static const teal967A0 = Color(0x00e6f9f6);
  static const teal972 = Color(0xffecf9f6);

  // blue
  static const blue144A0 = Color(0x00050a14);
  static const blue144A60 = Color(0x99050a14);
  static const blue173 = Color(0xff0b101a);
  static const blue585 = Color(0xff2e86ab);
  static const blue650 = Color(0xff7292b7);
  static const blue691 = Color(0xff7e9fc4);
  static const blue730 = Color(0xff61afef);
  static const blue776 = Color(0xff80c0e0);
  static const blue810 = Color(0xff74ccff);
  static const blue955 = Color(0xffdff4ff);

  // violet
  static const violet187A8 = Color(0x1412121c);
  static const violet340A25 = Color(0x4032325d);
  static const violet498 = Color(0xff6849b8);
  static const violet663A50 = Color(0x809b7fe0);
  static const violet664 = Color(0xffa87fc8);
  static const violet699 = Color(0xffb38ad3);
  static const violet775 = Color(0xffd4a0e0);
  static const violet947 = Color(0xfff0eafb);

  // red
  static const red213 = Color(0xff2a1010);
  static const red508 = Color(0xffb03038);
  static const red522 = Color(0xffa44b32);
  static const red535 = Color(0xffaf4a1e);
  static const red561 = Color(0xffc44043);
  static const red574 = Color(0xffc94444);
  static const red621 = Color(0xffd85555);
  static const red641 = Color(0xffe05a5a);
  static const red664 = Color(0xffc7798b);
  static const red667 = Color(0xffda7166);
  static const red668 = Color(0xffdd6e6f);
  static const red673 = Color(0xffdc7367);
  static const red700 = Color(0xffe87878);
  static const red727 = Color(0xffdc8c9e);
  static const red755A50 = Color(0x80ff8a65);
  static const red778 = Color(0xfff29d91);
  static const red838 = Color(0xffffb4a9);
  static const red873 = Color(0xffffc5bc);
  static const red874 = Color(0xfff7c8c8);
  static const red945 = Color(0xffffe7de);
  static const red948 = Color(0xfffde8e8);
  static const red961 = Color(0xfffdeeee);
}

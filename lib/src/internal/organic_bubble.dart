import 'package:flutter/material.dart';

class OrganicBubbleClip extends CustomClipper<Path> {
  const OrganicBubbleClip();
  @override
  Path getClip(Size size) {
    final p = Path()
      ..moveTo(.501, .005)
      ..lineTo(.523, .005)
      ..lineTo(.549, .006)
      ..cubicTo(.704, .01, .796, .017, .825, .027)
      ..lineTo(.827, .028)
      ..cubicTo(.872, .045, .939, .044, .978, .17)
      ..cubicTo(1, .254, 1, .365, .99, .505)
      ..lineTo(.988, .513)
      ..cubicTo(.979, .558, .971, .598, .965, .633)
      ..cubicTo(.956, .689, .979, .77, .964, .865)
      ..cubicTo(.953, .928, .921, .966, .869, .979)
      ..cubicTo(.821, .986, .773, .992, .726, .995)
      ..lineTo(.712, .996)
      ..lineTo(.694, .997)
      ..cubicTo(.648, 1, .586, 1, .507, 1)
      ..lineTo(.464, 1)
      ..cubicTo(.385, 1, .325, .998, .283, .995)
      ..cubicTo(.234, .992, .184, .987, .133, .979)
      ..cubicTo(.081, .966, .05, .928, .039, .865)
      ..cubicTo(.023, .77, .047, .689, .037, .633)
      ..cubicTo(.031, .595, .023, .552, .013, .505)
      ..cubicTo(-.006, .365, -.002, .254, .024, .17)
      ..cubicTo(.064, .045, .13, .045, .174, .028)
      ..lineTo(.175, .028)
      ..cubicTo(.204, .017, .303, .009, .474, .005)
      ..close();
    return p.transform(
      Matrix4.diagonal3Values(size.width, size.height, 1).storage,
    );
  }

  @override
  bool shouldReclip(OrganicBubbleClip old) => false;
}

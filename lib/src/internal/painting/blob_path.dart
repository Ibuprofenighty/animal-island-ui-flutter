import 'package:flutter/rendering.dart';

/// Organic blob geometry and clipping for Animal Island UI dialogs and modals.
///
/// Reproduces the exact `#animal-modal-clip` SVG path with normalized
/// cubic-bezier coordinates, scaled seamlessly to any container size.
abstract final class AnimalBlobPath {
  /// Builds the normalized organic blob path scaled to [size].
  static Path buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Exact normalized coordinates from #animal-modal-clip
    path.moveTo(0.501 * w, 0.005 * h);
    path.lineTo(0.523 * w, 0.005 * h);
    path.lineTo(0.549 * w, 0.006 * h);
    path.cubicTo(
      0.704 * w,
      0.010 * h,
      0.796 * w,
      0.017 * h,
      0.825 * w,
      0.027 * h,
    );
    path.lineTo(0.827 * w, 0.028 * h);
    path.cubicTo(
      0.872 * w,
      0.045 * h,
      0.939 * w,
      0.044 * h,
      0.978 * w,
      0.170 * h,
    );
    path.cubicTo(
      1.000 * w,
      0.254 * h,
      1.000 * w,
      0.365 * h,
      0.990 * w,
      0.505 * h,
    );
    path.lineTo(0.988 * w, 0.513 * h);
    path.cubicTo(
      0.979 * w,
      0.558 * h,
      0.971 * w,
      0.598 * h,
      0.965 * w,
      0.633 * h,
    );
    path.cubicTo(
      0.956 * w,
      0.689 * h,
      0.979 * w,
      0.770 * h,
      0.964 * w,
      0.865 * h,
    );
    path.cubicTo(
      0.953 * w,
      0.928 * h,
      0.921 * w,
      0.966 * h,
      0.869 * w,
      0.979 * h,
    );
    path.cubicTo(
      0.821 * w,
      0.986 * h,
      0.773 * w,
      0.992 * h,
      0.726 * w,
      0.995 * h,
    );
    path.lineTo(0.712 * w, 0.996 * h);
    path.lineTo(0.694 * w, 0.997 * h);
    path.cubicTo(
      0.648 * w,
      1.000 * h,
      0.586 * w,
      1.000 * h,
      0.507 * w,
      1.000 * h,
    );
    path.lineTo(0.501 * w, 1.000 * h);
    path.lineTo(0.464 * w, 1.000 * h);
    path.cubicTo(
      0.385 * w,
      1.000 * h,
      0.325 * w,
      0.998 * h,
      0.283 * w,
      0.995 * h,
    );
    path.cubicTo(
      0.234 * w,
      0.992 * h,
      0.184 * w,
      0.987 * h,
      0.133 * w,
      0.979 * h,
    );
    path.cubicTo(
      0.081 * w,
      0.966 * h,
      0.050 * w,
      0.928 * h,
      0.039 * w,
      0.865 * h,
    );
    path.cubicTo(
      0.023 * w,
      0.770 * h,
      0.047 * w,
      0.689 * h,
      0.037 * w,
      0.633 * h,
    );
    path.cubicTo(
      0.031 * w,
      0.595 * h,
      0.023 * w,
      0.552 * h,
      0.013 * w,
      0.505 * h,
    );
    path.cubicTo(
      -0.006 * w,
      0.365 * h,
      -0.002 * w,
      0.254 * h,
      0.024 * w,
      0.170 * h,
    );
    path.cubicTo(
      0.064 * w,
      0.045 * h,
      0.130 * w,
      0.045 * h,
      0.174 * w,
      0.028 * h,
    );
    path.lineTo(0.175 * w, 0.028 * h);
    path.cubicTo(
      0.204 * w,
      0.017 * h,
      0.303 * w,
      0.009 * h,
      0.474 * w,
      0.005 * h,
    );
    path.close();

    return path;
  }
}

/// CustomClipper utilizing [AnimalBlobPath].
class AnimalBlobClipper extends CustomClipper<Path> {
  /// Creates a clipper that clips to the blob shape of the clipped size.
  const AnimalBlobClipper();

  @override
  Path getClip(Size size) => AnimalBlobPath.buildPath(size);

  @override
  bool shouldReclip(covariant AnimalBlobClipper oldClipper) => false;
}

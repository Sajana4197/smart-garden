// Generates the app icon + splash logo PNGs from the app's own seed-derived
// M3 colors (see core/theme/app_theme.dart's seedColor). Deliberately pure
// pixel-buffer drawing via package:image — NOT Flutter's widget/rendering
// pipeline (RenderRepaintBoundary.toImage() proved unreliable to complete
// in this sandboxed dev environment, and rendering Icons.eco via a widget
// test silently fell back to a placeholder shape rather than the real
// glyph, since flutter test doesn't reliably load real fonts). This script
// runs as plain Dart (`dart run tool/generate_icons.dart`), no Flutter
// engine/test harness involved at all.
//
// The mark: a simple tilted "leaf blade" (a stretched, rotated ellipse) in
// the app's own colors — bold and legible at small icon sizes. No
// midrib/stem line: an earlier draft with one showed visible aliasing at
// small sizes, so the final mark is a solid silhouette only.
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img_lib;

// Exact hex values computed from ColorScheme.fromSeed(seedColor: 0xFF2E7D32).
const seedColor = 0xFF2E7D32; // icon background / adaptive-icon background
const surfaceColor = 0xFFF7FBF1; // splash background
const primaryContainer = 0xFFBCF0B4; // splash logo circle
const onPrimaryContainer = 0xFF245024; // splash logo leaf

img_lib.ColorRgba8 rgba(int argb, {int? alpha}) {
  return img_lib.ColorRgba8(
    (argb >> 16) & 0xFF,
    (argb >> 8) & 0xFF,
    argb & 0xFF,
    alpha ?? (argb >> 24) & 0xFF,
  );
}

/// Draws a filled, rotated ellipse ("leaf blade") centered at [cx],[cy].
void drawLeaf(
  img_lib.Image image, {
  required double cx,
  required double cy,
  required double semiMajor,
  required double semiMinor,
  required double angleDegrees,
  required img_lib.ColorRgba8 color,
}) {
  final angle = angleDegrees * math.pi / 180;
  final cosA = math.cos(-angle);
  final sinA = math.sin(-angle);

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final rx = dx * cosA - dy * sinA;
      final ry = dx * sinA + dy * cosA;
      final v = (rx * rx) / (semiMajor * semiMajor) +
          (ry * ry) / (semiMinor * semiMinor);
      if (v <= 1.0) {
        image.setPixel(x, y, color);
      }
    }
  }
}

void fillTransparent(img_lib.Image image) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixel(x, y, img_lib.ColorRgba8(0, 0, 0, 0));
    }
  }
}

void main() {
  const size = 1024;

  // 1) Flat combined icon: seed-green background + white leaf. Used as the
  //    general/iOS icon (image_path).
  final flat = img_lib.Image(width: size, height: size, numChannels: 4);
  img_lib.fill(flat, color: rgba(seedColor, alpha: 255));
  drawLeaf(
    flat,
    cx: size / 2,
    cy: size / 2,
    semiMajor: size * 0.32,
    semiMinor: size * 0.15,
    angleDegrees: 45,
    color: img_lib.ColorRgba8(255, 255, 255, 255),
  );
  File('assets/icon/icon_flat.png').writeAsBytesSync(img_lib.encodePng(flat));

  // 2) Adaptive-icon foreground: transparent background, leaf sized to the
  //    ~66% safe zone so Android's adaptive mask never clips it.
  final fg = img_lib.Image(width: size, height: size, numChannels: 4);
  fillTransparent(fg);
  drawLeaf(
    fg,
    cx: size / 2,
    cy: size / 2,
    semiMajor: size * 0.24,
    semiMinor: size * 0.11,
    angleDegrees: 45,
    color: img_lib.ColorRgba8(255, 255, 255, 255),
  );
  File('assets/icon/icon_foreground.png')
      .writeAsBytesSync(img_lib.encodePng(fg));

  // 3) Splash logo: primaryContainer circle + onPrimaryContainer leaf,
  //    transparent background — matches the in-app SplashScreen's
  //    CircleAvatar(backgroundColor: primaryContainer, Icon(eco,
  //    color: onPrimaryContainer)) exactly, so native splash -> Dart
  //    SplashScreen is a seamless handoff.
  const splashSize = 480;
  final splash =
      img_lib.Image(width: splashSize, height: splashSize, numChannels: 4);
  fillTransparent(splash);
  img_lib.fillCircle(
    splash,
    x: splashSize ~/ 2,
    y: splashSize ~/ 2,
    radius: (splashSize * 0.42).round(),
    color: rgba(primaryContainer, alpha: 255),
  );
  drawLeaf(
    splash,
    cx: splashSize / 2,
    cy: splashSize / 2,
    semiMajor: splashSize * 0.20,
    semiMinor: splashSize * 0.095,
    angleDegrees: 45,
    color: rgba(onPrimaryContainer, alpha: 255),
  );
  File('assets/icon/splash_logo.png')
      .writeAsBytesSync(img_lib.encodePng(splash));

  stdout.writeln('Generated assets/icon/icon_flat.png');
  stdout.writeln('Generated assets/icon/icon_foreground.png');
  stdout.writeln('Generated assets/icon/splash_logo.png');
  stdout.writeln('surfaceColor for flutter_native_splash config: '
      '#${(surfaceColor & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}');
}

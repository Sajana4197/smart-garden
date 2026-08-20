// One-off generator (Phase 19) — draws the app icon + splash logo as raw
// pixel buffers via package:image, deliberately avoiding Flutter's widget/
// rendering pipeline (which hung indefinitely for image capture in this
// dev environment). Run: dart run tool/generate_icons.dart
//
// The leaf mark is a simple tilted "rugby-ball" ellipse (reads clearly as
// a stylized leaf at icon scale, same spirit as Icons.eco used elsewhere
// in the app) plus a midrib line, in the app's exact seed-derived M3
// colors (see CLAUDE.md Phase 19 Locked Decision) so it's visually
// consistent with the in-app SplashScreen (CircleAvatar + eco icon).
import 'dart:math' as math;

import 'package:image/image.dart' as img_lib;

const seedColor = 0xFF2E7D32; // ARGB
const primaryContainer = 0xFFBCF0B4;
const onPrimaryContainer = 0xFF245024;
const white = 0xFFFFFFFF;
const transparent = 0x00000000;

img_lib.Color colorFromArgb(int argb) => img_lib.ColorRgba8(
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
      (argb >> 24) & 0xFF,
    );

/// Fills a tilted "rugby-ball" leaf shape (a stretched ellipse — tapers to
/// a soft point at both ends of its long axis, unlike a plain oval) into
/// [image], centered at ([cx],[cy]), long semi-axis [a], short semi-axis
/// [b], rotated [angleDeg] degrees, in [color].
void fillLeaf(
  img_lib.Image image, {
  required double cx,
  required double cy,
  required double a,
  required double b,
  required double angleDeg,
  required img_lib.Color color,
}) {
  final theta = angleDeg * math.pi / 180;
  final cosT = math.cos(theta);
  final sinT = math.sin(theta);
  final margin = math.max(a, b) + 2;

  final minX = (cx - margin).floor().clamp(0, image.width - 1);
  final maxX = (cx + margin).ceil().clamp(0, image.width - 1);
  final minY = (cy - margin).floor().clamp(0, image.height - 1);
  final maxY = (cy + margin).ceil().clamp(0, image.height - 1);

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final rx = dx * cosT + dy * sinT;
      final ry = -dx * sinT + dy * cosT;
      final v = (rx * rx) / (a * a) + (ry * ry) / (b * b);
      if (v <= 1.0) {
        image.setPixel(x, y, color);
      }
    }
  }
}

void main() {
  // 1) Flat combined icon (1024x1024): solid seed-green fill + white leaf.
  //    Used as the general/iOS image_path — platform tooling applies its
  //    own corner-rounding mask, so no rounding needed here.
  final flat = img_lib.Image(width: 1024, height: 1024, numChannels: 4);
  img_lib.fill(flat, color: colorFromArgb(seedColor));
  fillLeaf(
    flat,
    cx: 512,
    cy: 512,
    a: 380,
    b: 130,
    angleDeg: 45,
    color: colorFromArgb(white),
  );
  img_lib.encodePngFile('assets/icon/icon_flat.png', flat);

  // 2) Adaptive-icon foreground (1024x1024, transparent bg, leaf sized to
  //    the ~66% safe zone so Android's adaptive mask never clips it).
  final fg = img_lib.Image(width: 1024, height: 1024, numChannels: 4);
  img_lib.fill(fg, color: colorFromArgb(transparent));
  fillLeaf(
    fg,
    cx: 512,
    cy: 512,
    a: 280,
    b: 96,
    angleDeg: 45,
    color: colorFromArgb(white),
  );
  img_lib.encodePngFile('assets/icon/icon_foreground.png', fg);

  // 3) Splash logo (transparent bg): primaryContainer circle +
  //    onPrimaryContainer leaf, matching the in-app SplashScreen's
  //    CircleAvatar(backgroundColor: primaryContainer, Icon(eco,
  //    color: onPrimaryContainer)) as closely as a static mark can.
  final splash = img_lib.Image(width: 480, height: 480, numChannels: 4);
  img_lib.fill(splash, color: colorFromArgb(transparent));
  img_lib.fillCircle(
    splash,
    x: 240,
    y: 240,
    radius: 200,
    color: colorFromArgb(primaryContainer),
  );
  fillLeaf(
    splash,
    cx: 240,
    cy: 240,
    a: 120,
    b: 42,
    angleDeg: 45,
    color: colorFromArgb(onPrimaryContainer),
  );
  img_lib.encodePngFile('assets/icon/splash_logo.png', splash);

  // ignore: avoid_print
  print('Generated assets/icon/icon_flat.png, icon_foreground.png, '
      'splash_logo.png');
}

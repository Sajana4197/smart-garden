import 'dart:io';

import 'package:flutter/material.dart';

/// Displays an image from the sandboxed scans directory, falling back to a
/// themed placeholder — never Flutter's default red/gray error render —
/// if the file is missing, unreadable, or corrupted. Every screen that
/// shows a scan/plant photo goes through this rather than a bare
/// `Image.file`, since the underlying file is user/OS-managed disk state
/// that can vanish independently of the DB row that references it (low
/// storage cleanup, manual clearing, etc.) — see ROADMAP.md Phase 17
/// ("wrap risky I/O... never a raw exception or blank screen").
class SafeFileImage extends StatelessWidget {
  const SafeFileImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: colorScheme.onSurfaceVariant,
            size: _iconSizeFor(width, height),
          ),
        );
      },
    );
  }

  /// Explicit dimensions (grid/list thumbnails) scale the icon down;
  /// unbounded contexts (hero images inside an `AspectRatio`) get a fixed
  /// reasonable default rather than an unbounded/zero size.
  double _iconSizeFor(double? width, double? height) {
    final smallest = [width, height].whereType<double>().fold<double?>(
          null,
          (min, v) => min == null || v < min ? v : min,
        );
    if (smallest == null) return 40;
    return (smallest * 0.4).clamp(20, 64);
  }
}

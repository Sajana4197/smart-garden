import 'package:flutter/animation.dart';

/// Shared motion vocabulary — see UI_GUIDELINES.md §5. Features must reuse
/// these tokens rather than inventing per-screen durations/curves.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

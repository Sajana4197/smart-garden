import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_motion.dart';

/// A single shimmering placeholder rectangle — the building block for
/// content-shaped loading states (UI_GUIDELINES.md §5: "skeleton/shimmer
/// loading states where applicable"). Hand-rolled with a plain
/// `AnimationController` sweeping a `LinearGradient`, matching this
/// project's existing custom-animation convention (no new dependency).
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppSpacing.radiusSmall,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow * 2,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sweep = Alignment(-1 + 2 * _controller.value, 0);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(sweep.x - 0.4, 0),
              end: Alignment(sweep.x + 0.4, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

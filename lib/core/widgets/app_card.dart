import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'press_scale.dart';

/// Shared card container (M3 filled card) — see UI_GUIDELINES.md §6.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      enabled: onTap != null,
      child: Card.filled(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

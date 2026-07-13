import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Plant-health severity levels a status badge can represent. Feature
/// domain layers map their own status types onto this when rendering.
enum AppHealthStatus { healthy, mild, moderate, severe }

/// Shared severity/status pill badge — reused on Home, My Garden, Scan
/// History, and Plant Health Dashboard. Pairs color with an icon and a
/// text label so status is never conveyed by color alone (UI_GUIDELINES §8).
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.status, this.label});

  final AppHealthStatus status;

  /// Overrides the default label text (e.g. a specific diagnosis name).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final statusColors = context.statusColors;
    final (background, foreground, icon, defaultLabel) = switch (status) {
      AppHealthStatus.healthy => (
          statusColors.healthy,
          statusColors.onHealthy,
          Icons.check_circle,
          'Healthy',
        ),
      AppHealthStatus.mild => (
          statusColors.mild,
          statusColors.onMild,
          Icons.info,
          'Mild',
        ),
      AppHealthStatus.moderate => (
          statusColors.moderate,
          statusColors.onModerate,
          Icons.warning,
          'Moderate',
        ),
      AppHealthStatus.severe => (
          statusColors.severe,
          statusColors.onSevere,
          Icons.error,
          'Severe',
        ),
    };

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label ?? defaultLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

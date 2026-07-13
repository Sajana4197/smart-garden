import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/widgets/safe_file_image.dart';
import '../../domain/entities/garden_health_summary.dart';

/// One row in the Plant Health Dashboard's "Needs Attention" list —
/// thumbnail, name/species, status badge, and a trend indicator derived
/// from the plant's two most recent scans. See ROADMAP.md Phase 14.
class NeedsAttentionTile extends StatelessWidget {
  const NeedsAttentionTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final NeedsAttentionEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final plant = entry.plant;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: SafeFileImage(path: plant.imagePath, width: 48, height: 48),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (plant.species != null)
                  Text(
                    plant.species!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          _TrendIndicator(trend: entry.trend),
          const SizedBox(width: AppSpacing.sm2),
          AppStatusBadge(status: AppHealthStatus.values.byName(plant.status.name)),
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trend});

  final HealthTrend trend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = context.statusColors;

    final (icon, color, tooltip) = switch (trend) {
      HealthTrend.improving => (
          Icons.trending_down,
          statusColors.healthy,
          'Improving since last scan',
        ),
      HealthTrend.worsening => (
          Icons.trending_up,
          statusColors.severe,
          'Worsening since last scan',
        ),
      HealthTrend.stable => (
          Icons.trending_flat,
          colorScheme.onSurfaceVariant,
          'Unchanged since last scan',
        ),
      HealthTrend.unknown => (
          Icons.help_outline,
          colorScheme.onSurfaceVariant,
          'Not enough scans yet',
        ),
    };

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 20),
    );
  }
}

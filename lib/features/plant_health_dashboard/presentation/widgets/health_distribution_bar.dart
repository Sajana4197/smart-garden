import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../my_garden/domain/entities/plant.dart';

/// Stacked-bar visualization of how many My Garden plants fall into each
/// [PlantHealthStatus] bucket, plus a color-keyed legend with counts (status
/// is never conveyed by color alone — UI_GUIDELINES.md §8). See
/// ROADMAP.md Phase 14.
class HealthDistributionBar extends StatelessWidget {
  const HealthDistributionBar({super.key, required this.statusCounts});

  final Map<PlantHealthStatus, int> statusCounts;

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.values.fold(0, (sum, count) => sum + count);
    final statusColors = context.statusColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (total == 0)
            Text(
              'No plants saved yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (final status in PlantHealthStatus.values)
                      if (statusCounts[status]! > 0)
                        Expanded(
                          flex: statusCounts[status]!,
                          child: Container(
                            color: _colorFor(status, statusColors),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                for (final status in PlantHealthStatus.values)
                  _LegendEntry(
                    color: _colorFor(status, statusColors),
                    label: _labelFor(status),
                    count: statusCounts[status]!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _colorFor(PlantHealthStatus status, AppColors statusColors) =>
      switch (status) {
        PlantHealthStatus.healthy => statusColors.healthy,
        PlantHealthStatus.mild => statusColors.mild,
        PlantHealthStatus.moderate => statusColors.moderate,
        PlantHealthStatus.severe => statusColors.severe,
      };

  String _labelFor(PlantHealthStatus status) => switch (status) {
        PlantHealthStatus.healthy => 'Healthy',
        PlantHealthStatus.mild => 'Mild',
        PlantHealthStatus.moderate => 'Moderate',
        PlantHealthStatus.severe => 'Severe',
      };
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

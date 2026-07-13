import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// A single summary stat tile (e.g. "Total Plants", "Needs Attention") —
/// reused in a row on the Plant Health Dashboard. See ROADMAP.md Phase 14.
class HealthStatCard extends StatelessWidget {
  const HealthStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = accentColor ?? colorScheme.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

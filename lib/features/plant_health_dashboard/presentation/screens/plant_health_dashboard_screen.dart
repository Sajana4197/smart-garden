import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/plant_health_dashboard_provider.dart';
import '../widgets/health_distribution_bar.dart';
import '../widgets/health_stat_card.dart';
import '../widgets/needs_attention_tile.dart';

/// Garden-wide health overview — summary stat cards, a status distribution
/// visualization, and a "needs attention" list linking into My Garden
/// detail. `PlantHealthDashboardProvider` is registered app-wide (app.dart),
/// not screen-scoped, for the same `StatefulShellRoute.indexedStack` reason
/// as `MyGardenProvider`/`ScanHistoryProvider` (CLAUDE.md §3): every
/// mutating action elsewhere in the app explicitly calls `loadSummary()`
/// right after it succeeds. See ROADMAP.md Phase 14.
class PlantHealthDashboardScreen extends StatelessWidget {
  const PlantHealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlantHealthDashboardProvider>();
    final summary = provider.summary;

    late final Widget body;
    if (provider.isLoading && summary == null) {
      body = const AppLoadingIndicator();
    } else if (provider.hasError) {
      body = ErrorStateWidget(
        title: 'Could not load health data',
        message: 'Something went wrong aggregating your garden\'s health.',
        retryLabel: 'Try Again',
        onRetry: provider.loadSummary,
      );
    } else if (summary == null || summary.totalPlants == 0) {
      body = const EmptyStateWidget(
        icon: Icons.favorite_outline,
        title: 'Nothing to show yet',
        message: 'Add plants to My Garden to see health trends here.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.local_florist,
                    value: '${summary.totalPlants}',
                    label: 'Total Plants',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HealthStatCard(
                    icon: Icons.warning_amber,
                    value: '${summary.needsAttention.length}',
                    label: 'Needs Attention',
                    accentColor: summary.needsAttention.isEmpty
                        ? null
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            HealthDistributionBar(statusCounts: summary.statusCounts),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: 'Needs Attention'),
            const SizedBox(height: AppSpacing.sm),
            if (summary.needsAttention.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'All your plants are doing well.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              for (final entry in summary.needsAttention)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
                  child: NeedsAttentionTile(
                    entry: entry,
                    onTap: () => context.push(
                      AppRoutes.plantDetail,
                      extra: entry.plant,
                    ),
                  ),
                ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Plant Health'),
      body: body,
    );
  }
}

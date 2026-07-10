import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/widgets/section_header.dart';
import '../widgets/scan_source_sheet.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: SmartGardenAppBar(
        title: 'SmartGarden AI',
        actions: [
          // TODO(Phase 19): remove/guard this debug entry point.
          IconButton(
            tooltip: 'Component gallery (debug)',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => context.push(AppRoutes.debugGallery),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('${_greeting()}, gardener', style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Let's check on your plants today.",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _WeatherCard(),
          const SizedBox(height: AppSpacing.md),
          const _DailyTipCard(),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Scan a Plant',
            icon: Icons.camera_alt_outlined,
            onPressed: () => showScanSourceSheet(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: 'Recent Activity',
            trailingLabel: 'See all',
            onTrailingTap: () => context.go(AppRoutes.scanHistory),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _RecentActivityList(),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          Icon(
            Icons.wb_cloudy_outlined,
            size: 40,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Colombo, LK', style: textTheme.titleMedium),
                Text(
                  'Partly cloudy',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text('28°C', style: textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.tertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip of the Day', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Rotate your potted plants a quarter turn every week so '
                  'all sides get even sunlight.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityEntry {
  const _RecentActivityEntry(this.name, this.status, this.timeAgo);

  final String name;
  final AppHealthStatus status;
  final String timeAgo;
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  static const _entries = [
    _RecentActivityEntry('Monstera Deliciosa', AppHealthStatus.healthy, '2 days ago'),
    _RecentActivityEntry('Basil', AppHealthStatus.mild, '5 days ago'),
    _RecentActivityEntry('Fiddle Leaf Fig', AppHealthStatus.moderate, '1 week ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final entry in _entries) ...[
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  child: const Icon(Icons.eco_outlined),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name, style: textTheme.titleMedium),
                      Text(
                        entry.timeAgo,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppStatusBadge(status: entry.status),
              ],
            ),
          ),
          if (entry != _entries.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

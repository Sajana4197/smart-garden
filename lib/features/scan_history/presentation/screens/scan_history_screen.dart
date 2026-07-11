import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../domain/entities/scan.dart';
import '../providers/scan_history_provider.dart';
import '../widgets/scan_filter_bar.dart';

AppHealthStatus _scanStatus(ScanSeverity severity) => switch (severity) {
      ScanSeverity.none => AppHealthStatus.healthy,
      ScanSeverity.mild => AppHealthStatus.mild,
      ScanSeverity.moderate => AppHealthStatus.moderate,
      ScanSeverity.severe => AppHealthStatus.severe,
    };

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Reverse-chronological list of every completed scan, independent of
/// whether it was ever saved to My Garden — per ROADMAP.md Phase 10.
/// `ScanHistoryProvider` is registered app-wide (app.dart), not screen-
/// scoped, for the same `StatefulShellRoute.indexedStack` reason
/// `MyGardenProvider` was (see CLAUDE.md §3): this screen is a bottom-nav
/// branch whose subtree survives tab switches without rebuilding.
class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanHistoryProvider>();
    final scans = provider.scans;

    late final Widget body;
    if (provider.isLoading && !provider.hasAnyScans) {
      body = const AppLoadingIndicator();
    } else if (provider.hasError) {
      body = ErrorStateWidget(
        title: 'Could not load scan history',
        message: 'Something went wrong loading your past scans.',
        retryLabel: 'Try Again',
        onRetry: provider.loadScans,
      );
    } else if (!provider.hasAnyScans) {
      body = const EmptyStateWidget(
        icon: Icons.history,
        title: 'No scans yet',
        message: 'Every plant you scan will be logged here.',
      );
    } else {
      body = Column(
        children: [
          ScanFilterBar(provider: provider),
          Expanded(
            child: scans.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No scans match these filters',
                    message: 'Try a different severity or link filter.',
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadScans,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      itemCount: scans.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final scan = scans[index];
                        return _ScanListTile(
                          scan: scan,
                          onTap: () => context.push(
                            AppRoutes.scanDetail,
                            extra: scan,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Scan History'),
      body: body,
    );
  }
}

class _ScanListTile extends StatelessWidget {
  const _ScanListTile({required this.scan, required this.onTap});

  final Scan scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: Image.file(
              File(scan.imagePath),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.diagnosisLabel,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(scan.scannedAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (scan.plantId == null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Not saved to My Garden',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppStatusBadge(status: _scanStatus(scan.severity)),
        ],
      ),
    );
  }
}

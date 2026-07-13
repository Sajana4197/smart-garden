import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/widgets/safe_file_image.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../daily_tips/presentation/providers/daily_tip_provider.dart';
import '../../../scan_history/domain/entities/scan.dart';
import '../../../scan_history/presentation/providers/scan_history_provider.dart';
import '../../../weather/presentation/widgets/weather_card.dart';
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
          const WeatherCard(),
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

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<DailyTipProvider>();

    final String title;
    final String body;
    if (provider.isLoading && provider.tip == null) {
      title = 'Tip of the Day';
      body = 'Loading...';
    } else if (provider.tip != null) {
      title = provider.tip!.title;
      body = provider.tip!.body;
    } else {
      // provider.hasError with no cached tip — still show something useful
      // rather than a blank card (no dedicated error UI for a non-critical
      // dashboard widget).
      title = 'Tip of the Day';
      body = 'Keep your plants healthy with regular care and attention.';
    }

    return AppCard(
      key: const Key('dailyTipCard'),
      onTap: () => context.push(AppRoutes.allTips),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.tertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

AppHealthStatus _statusFor(ScanSeverity severity) => switch (severity) {
      ScanSeverity.none => AppHealthStatus.healthy,
      ScanSeverity.mild => AppHealthStatus.mild,
      ScanSeverity.moderate => AppHealthStatus.moderate,
      ScanSeverity.severe => AppHealthStatus.severe,
    };

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 7) {
    final weeks = diff.inDays ~/ 7;
    return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
  }
  if (diff.inDays >= 1) {
    return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
  }
  if (diff.inHours >= 1) {
    return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
  }
  if (diff.inMinutes >= 1) {
    return diff.inMinutes == 1 ? '1 minute ago' : '${diff.inMinutes} minutes ago';
  }
  return 'Just now';
}

/// Shows the actual most-recent scans (via `ScanHistoryProvider.
/// recentScans`, deliberately not its filtered `scans` getter — see that
/// getter's doc comment) rather than the Phase 3 static placeholder this
/// replaced. A brand-new user with an empty DB sees a genuine empty state,
/// not fake plants they never scanned (ROADMAP.md Phase 17).
class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  static const int _maxEntries = 3;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanHistoryProvider>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // No spinner here (unlike a dedicated screen's initial-load state) —
    // this is a small, non-critical dashboard summary, same reasoning as
    // `_DailyTipCard`'s static "Loading..." text: a `CircularProgressIndicator`
    // is a never-settling indeterminate animation, and this widget's loading
    // window should be brief enough that plain text reads fine.
    if (provider.isLoading && !provider.hasAnyScans) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.eco_outlined, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Text('Loading recent activity…', style: textTheme.bodyMedium),
          ],
        ),
      );
    }

    final recentScans = provider.recentScans.take(_maxEntries).toList();
    if (recentScans.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.eco_outlined, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Scan a plant to see your recent activity here.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final (index, scan) in recentScans.indexed) ...[
          AppCard(
            onTap: () => context.push(AppRoutes.scanDetail, extra: scan),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SafeFileImage(path: scan.imagePath, width: 40, height: 40),
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
                      Text(
                        _timeAgo(scan.scannedAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppStatusBadge(status: _statusFor(scan.severity)),
              ],
            ),
          ),
          if (index != recentScans.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/scan.dart';
import '../providers/scan_history_provider.dart';

const Map<ScanSeverity?, String> _severityLabels = {
  null: 'All severities',
  ScanSeverity.none: 'Healthy',
  ScanSeverity.mild: 'Mild',
  ScanSeverity.moderate: 'Moderate',
  ScanSeverity.severe: 'Severe',
};

const Map<ScanLinkFilter, String> _linkLabels = {
  ScanLinkFilter.all: 'All',
  ScanLinkFilter.linked: 'Linked',
  ScanLinkFilter.unlinked: 'Unlinked',
};

/// Sort/filter controls for the Scan History list — per ROADMAP.md Phase 10
/// (date, severity, linked-vs-unlinked). Purely presentational; all state
/// lives in the [ScanHistoryProvider] passed in.
class ScanFilterBar extends StatelessWidget {
  const ScanFilterBar({super.key, required this.provider});

  final ScanHistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<ScanLinkFilter>(
                  segments: [
                    for (final filter in ScanLinkFilter.values)
                      ButtonSegment(
                        value: filter,
                        label: Text(_linkLabels[filter]!),
                      ),
                  ],
                  selected: {provider.linkFilter},
                  onSelectionChanged: (selection) =>
                      provider.setLinkFilter(selection.first),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filledTonal(
                tooltip: provider.sortOrder == ScanSortOrder.newestFirst
                    ? 'Newest first'
                    : 'Oldest first',
                icon: Icon(
                  provider.sortOrder == ScanSortOrder.newestFirst
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                ),
                onPressed: () => provider.setSortOrder(
                  provider.sortOrder == ScanSortOrder.newestFirst
                      ? ScanSortOrder.oldestFirst
                      : ScanSortOrder.newestFirst,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final severity in [null, ...ScanSeverity.values])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(_severityLabels[severity]!),
                      selected: provider.severityFilter == severity,
                      onSelected: (_) => provider.setSeverityFilter(severity),
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

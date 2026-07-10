import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';

// TODO(Phase 10): Replace this placeholder with the real Scan History list
// (reverse-chronological, filter/sort controls).
class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Scan History'),
      body: const EmptyStateWidget(
        icon: Icons.history,
        title: 'No scans yet',
        message: 'Every plant you scan will be logged here.',
      ),
    );
  }
}

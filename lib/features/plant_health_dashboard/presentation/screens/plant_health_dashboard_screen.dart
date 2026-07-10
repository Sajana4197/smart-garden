import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';

// TODO(Phase 14): Replace this placeholder with aggregate health stats
// (status counts, trends, needs-attention list).
class PlantHealthDashboardScreen extends StatelessWidget {
  const PlantHealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Plant Health'),
      body: const EmptyStateWidget(
        icon: Icons.favorite_outline,
        title: 'Nothing to show yet',
        message: 'Add plants to My Garden to see health trends here.',
      ),
    );
  }
}

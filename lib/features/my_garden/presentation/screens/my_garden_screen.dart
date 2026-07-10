import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';

// TODO(Phase 9): Replace this placeholder with the real My Garden CRUD UI
// (grid/list of saved plants, thumbnail, name, status badge).
class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'My Garden'),
      body: const EmptyStateWidget(
        icon: Icons.local_florist_outlined,
        title: 'Your garden is empty',
        message: 'Plants you save from a scan will show up here.',
      ),
    );
  }
}

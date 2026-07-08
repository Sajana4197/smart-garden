import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';

// TODO(Phase 3): Replace this placeholder with the full Home Dashboard —
// greeting header, weather card, daily tip card, quick-scan CTA, recent
// activity preview — inside a primary navigation shell.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Text(
          'SmartGarden AI',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

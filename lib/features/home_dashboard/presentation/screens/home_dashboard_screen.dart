import 'package:flutter/material.dart';

// TODO(Phase 3): Replace this placeholder with the full Home Dashboard —
// greeting header, weather card, daily tip card, quick-scan CTA, recent
// activity preview — inside a primary navigation shell.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'SmartGarden AI',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

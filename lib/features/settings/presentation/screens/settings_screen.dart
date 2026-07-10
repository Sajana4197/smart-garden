import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';

// TODO(Phase 15): Replace this placeholder with the real Settings & About
// screens (theme mode, units, TTS controls, clear data, app version).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Settings'),
      body: const EmptyStateWidget(
        icon: Icons.settings_outlined,
        title: 'Settings coming soon',
        message: 'Theme, units, voice, and data controls will live here.',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_spacing.dart';
import '../theme/theme_mode_controller.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_secondary_button.dart';
import '../widgets/app_status_badge.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/section_header.dart';

/// Temporary debug-only route to visually verify every shared widget in
/// both themes. Removed/guarded in Phase 19 (Release Preparation).
class ComponentGalleryScreen extends StatelessWidget {
  const ComponentGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeModeController>();

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Component Gallery'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ],
                selected: {themeController.themeMode},
                onSelectionChanged: (selection) =>
                    themeController.setThemeMode(selection.first),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Buttons'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppPrimaryButton(label: 'Primary', onPressed: () {}),
              AppPrimaryButton(label: 'Scan Now', icon: Icons.camera_alt, onPressed: () {}),
              AppSecondaryButton(label: 'Secondary', onPressed: () {}),
              const AppPrimaryButton(label: 'Disabled', onPressed: null),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Status badges'),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppStatusBadge(status: AppHealthStatus.healthy),
              AppStatusBadge(status: AppHealthStatus.mild),
              AppStatusBadge(status: AppHealthStatus.moderate),
              AppStatusBadge(status: AppHealthStatus.severe),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Card'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Card title', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                const Text('Card container built on Card.filled per M3.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Loading indicator'),
          const SizedBox(height: AppSpacing.sm),
          const SizedBox(
            height: 120,
            child: AppLoadingIndicator(label: 'Analyzing your plant…'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Empty state'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 260,
            child: EmptyStateWidget(
              icon: Icons.eco_outlined,
              title: 'No plants yet',
              message: 'Scan a plant to add it to My Garden.',
              actionLabel: 'Scan a plant',
              onAction: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Error state'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 260,
            child: ErrorStateWidget(
              title: 'Couldn\'t load weather',
              message: 'Check your connection and try again.',
              retryLabel: 'Retry',
              onRetry: () {},
            ),
          ),
        ],
      ),
    );
  }
}

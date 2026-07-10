import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_secondary_button.dart';

// TODO(Phase 6): Replace with the real Preview screen — Retake/Confirm
// actions (Confirm proceeds to AI Loading), Hero continuity from
// Camera/Gallery. This is intentionally minimal per Phase 5's exit
// criteria: just prove the resulting file path is valid and displayable.
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Photo Captured'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Saved to app storage', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            SelectableText(
              imagePath,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSecondaryButton(
              label: 'Retake',
              icon: Icons.refresh,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

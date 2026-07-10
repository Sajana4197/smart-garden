import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_primary_button.dart';

// TODO(Phase 7): Replace this placeholder with the real Result screen —
// diagnosis label, confidence indicator, severity badge, description, and
// the persisted PlantDiagnosisResult from AIService.analyzeImage(). This is
// intentionally minimal per Phase 6's exit criteria: just prove Confirm ->
// AI Loading -> forward navigation works end-to-end.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Analysis Complete'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: imagePath,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Diagnosis coming soon', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Real plant health results will appear here once the AI '
              'service is wired up.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Back to Home',
              onPressed: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

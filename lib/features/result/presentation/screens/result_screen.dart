import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../recommendation/presentation/screens/recommendation_screen.dart';

/// Bundles the scan image path with its diagnosis for the `/result` route's
/// `extra` — constructed by `AiLoadingScreen` after a successful
/// `AIService.analyzeImage()` call and the scan has been persisted.
class ResultScreenArgs {
  const ResultScreenArgs({required this.imagePath, required this.result});

  final String imagePath;
  final PlantDiagnosisResult result;
}

/// Displays a completed `PlantDiagnosisResult`: hero image, diagnosis label,
/// severity badge, confidence indicator, description, and visual symptoms —
/// per ROADMAP.md Phase 7 and MODEL_INTEGRATION.md §3.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  final String imagePath;
  final PlantDiagnosisResult result;

  AppHealthStatus get _healthStatus => switch (result.severity) {
        DiagnosisSeverity.none => AppHealthStatus.healthy,
        DiagnosisSeverity.mild => AppHealthStatus.mild,
        DiagnosisSeverity.moderate => AppHealthStatus.moderate,
        DiagnosisSeverity.severe => AppHealthStatus.severe,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Diagnosis'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Hero(
              tag: imagePath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(result.diagnosisLabel, style: textTheme.headlineMedium),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(status: _healthStatus),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            result.plantSpeciesLatin != null
                ? '${result.plantCommonName} · ${result.plantSpeciesLatin}'
                : result.plantCommonName,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('Confidence', style: textTheme.labelLarge),
                    const Spacer(),
                    Text(
                      '${(result.confidence * 100).round()}%',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: result.confidence),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    child: LinearProgressIndicator(value: value, minHeight: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('About this diagnosis', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(result.description, style: textTheme.bodyMedium),
          if (result.visualSymptoms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('What we noticed', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            ...result.visualSymptoms.map(
              (symptom) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(symptom, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'View Care Recommendations',
            icon: Icons.spa_outlined,
            onPressed: () => context.push(
              AppRoutes.recommendation,
              extra: RecommendationScreenArgs(imagePath: imagePath, result: result),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            label: 'Back to Home',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}

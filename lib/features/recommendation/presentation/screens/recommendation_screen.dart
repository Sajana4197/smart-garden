import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../services/ai/ai_service.dart';
import '../../domain/entities/care_recommendation.dart';
import '../../domain/usecases/get_care_recommendation.dart';

/// Bundles the scan image path with its diagnosis for the `/recommendation`
/// route's `extra` — constructed by `ResultScreen`'s "View Care
/// Recommendations" CTA.
class RecommendationScreenArgs {
  const RecommendationScreenArgs({required this.imagePath, required this.result});

  final String imagePath;
  final PlantDiagnosisResult result;
}

/// Presents the domain-mapped `CareRecommendation` for a diagnosis as a
/// clear card/checklist layout — per ROADMAP.md Phase 8. Reached only from
/// `ResultScreen`; never depends on `AIService` directly, only the already-
/// resolved `PlantDiagnosisResult` passed in.
class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  final String imagePath;
  final PlantDiagnosisResult result;

  static AppHealthStatus _urgencyStatus(RecommendationUrgency urgency) =>
      switch (urgency) {
        RecommendationUrgency.routine => AppHealthStatus.healthy,
        RecommendationUrgency.monitor => AppHealthStatus.moderate,
        RecommendationUrgency.urgent => AppHealthStatus.severe,
      };

  static String _urgencyLabel(RecommendationUrgency urgency) =>
      switch (urgency) {
        RecommendationUrgency.routine => 'Routine',
        RecommendationUrgency.monitor => 'Monitor',
        RecommendationUrgency.urgent => 'Urgent',
      };

  @override
  Widget build(BuildContext context) {
    final recommendation = context.read<GetCareRecommendation>()(
      diagnosisLabel: result.diagnosisLabel,
      severity: result.severity,
    );
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Care Recommendations'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: Image.file(
                  File(imagePath),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.diagnosisLabel, style: textTheme.titleLarge),
                    Text(
                      result.plantCommonName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(
                status: _urgencyStatus(recommendation.urgency),
                label: _urgencyLabel(recommendation.urgency),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _AdviceCard(
            icon: Icons.water_drop_outlined,
            title: 'Watering',
            body: recommendation.wateringAdvice,
          ),
          const SizedBox(height: AppSpacing.md),
          _AdviceCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Light',
            body: recommendation.lightAdvice,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Treatment Steps', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final step in recommendation.treatmentSteps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(step, style: textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Back to Home',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

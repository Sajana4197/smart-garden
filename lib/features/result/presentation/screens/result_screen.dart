import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../my_garden/domain/entities/plant.dart';
import '../../../my_garden/domain/usecases/save_plant_to_garden.dart';
import '../../../my_garden/presentation/providers/my_garden_provider.dart';
import '../../../my_garden/presentation/widgets/save_to_garden_dialog.dart';
import '../../../recommendation/presentation/screens/recommendation_screen.dart';

/// Bundles the scan image path, diagnosis, and the persisted scan's DB id
/// for the `/result` route's `extra` — constructed by `AiLoadingScreen`
/// after a successful `AIService.analyzeImage()` call and the scan has been
/// persisted. `scanId` lets "Save to My Garden" link the new plant back to
/// the scan that produced it (`scans.plant_id`).
class ResultScreenArgs {
  const ResultScreenArgs({
    required this.imagePath,
    required this.result,
    required this.scanId,
  });

  final String imagePath;
  final PlantDiagnosisResult result;
  final int scanId;
}

/// Displays a completed `PlantDiagnosisResult`: hero image, diagnosis label,
/// severity badge, confidence indicator, description, and visual symptoms —
/// per ROADMAP.md Phase 7 and MODEL_INTEGRATION.md §3. Also offers "Save to
/// My Garden" (Phase 9), which becomes disabled/relabeled once saved so a
/// user can't create duplicate entries from the same scan.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
    required this.scanId,
  });

  final String imagePath;
  final PlantDiagnosisResult result;
  final int scanId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaved = false;
  bool _isSaving = false;

  AppHealthStatus get _healthStatus => switch (widget.result.severity) {
        DiagnosisSeverity.none => AppHealthStatus.healthy,
        DiagnosisSeverity.mild => AppHealthStatus.mild,
        DiagnosisSeverity.moderate => AppHealthStatus.moderate,
        DiagnosisSeverity.severe => AppHealthStatus.severe,
      };

  PlantHealthStatus get _plantStatus => switch (widget.result.severity) {
        DiagnosisSeverity.none => PlantHealthStatus.healthy,
        DiagnosisSeverity.mild => PlantHealthStatus.mild,
        DiagnosisSeverity.moderate => PlantHealthStatus.moderate,
        DiagnosisSeverity.severe => PlantHealthStatus.severe,
      };

  Future<void> _saveToGarden() async {
    final dialogResult = await SaveToGardenDialog.show(
      context,
      initialSpecies: widget.result.plantCommonName,
    );
    if (dialogResult == null || !mounted) return;

    setState(() => _isSaving = true);
    final savePlantToGarden = context.read<SavePlantToGarden>();
    final messenger = ScaffoldMessenger.of(context);
    await savePlantToGarden(
      name: dialogResult.name,
      species: dialogResult.species,
      imagePath: widget.imagePath,
      notes: dialogResult.notes,
      status: _plantStatus,
      sourceScanId: widget.scanId,
    );
    if (!mounted) return;
    context.read<MyGardenProvider>().loadPlants();
    setState(() {
      _isSaving = false;
      _isSaved = true;
    });
    messenger.showSnackBar(const SnackBar(content: Text('Saved to My Garden')));
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
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
              tag: widget.imagePath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
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
              extra: RecommendationScreenArgs(
                imagePath: widget.imagePath,
                result: result,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            label: _isSaved ? 'Saved to My Garden' : 'Save to My Garden',
            icon: _isSaved ? Icons.check : Icons.bookmark_add_outlined,
            onPressed: (_isSaved || _isSaving) ? null : _saveToGarden,
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

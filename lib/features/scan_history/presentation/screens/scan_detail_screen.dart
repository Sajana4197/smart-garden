import 'dart:convert';
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
import '../../../my_garden/domain/usecases/get_plant_by_id.dart';
import '../../../my_garden/domain/usecases/save_plant_to_garden.dart';
import '../../../my_garden/presentation/providers/my_garden_provider.dart';
import '../../../my_garden/presentation/widgets/save_to_garden_dialog.dart';
import '../../../plant_health_dashboard/presentation/providers/plant_health_dashboard_provider.dart';
import '../../../recommendation/presentation/screens/recommendation_screen.dart';
import '../../domain/entities/scan.dart';
import '../providers/scan_history_provider.dart';

AppHealthStatus _healthStatusFor(DiagnosisSeverity severity) => switch (severity) {
      DiagnosisSeverity.none => AppHealthStatus.healthy,
      DiagnosisSeverity.mild => AppHealthStatus.mild,
      DiagnosisSeverity.moderate => AppHealthStatus.moderate,
      DiagnosisSeverity.severe => AppHealthStatus.severe,
    };

PlantHealthStatus _plantStatusFor(DiagnosisSeverity severity) => switch (severity) {
      DiagnosisSeverity.none => PlantHealthStatus.healthy,
      DiagnosisSeverity.mild => PlantHealthStatus.mild,
      DiagnosisSeverity.moderate => PlantHealthStatus.moderate,
      DiagnosisSeverity.severe => PlantHealthStatus.severe,
    };

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Full detail for one historical scan — extends `ResultScreen`'s
/// presentation (hero image, diagnosis, confidence, description, symptoms)
/// per ROADMAP.md Phase 10, reconstructing the full `PlantDiagnosisResult`
/// from `scans.raw_result_json` (Phase 7) rather than re-deriving it from
/// the flattened columns. The footer action depends on whether the scan is
/// already linked to a My Garden entry: unlinked scans get "Save to My
/// Garden" (identical flow to Result); linked ones get "View in My Garden"
/// instead, since re-saving would create a duplicate plant.
class ScanDetailScreen extends StatefulWidget {
  const ScanDetailScreen({super.key, required this.scan});

  final Scan scan;

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  late final PlantDiagnosisResult _result;
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _result = PlantDiagnosisResult.fromJson(
      jsonDecode(widget.scan.rawResultJson) as Map<String, Object?>,
    );
    _isSaved = widget.scan.plantId != null;
  }

  Future<void> _saveToGarden() async {
    final dialogResult = await SaveToGardenDialog.show(
      context,
      initialSpecies: _result.plantCommonName,
    );
    if (dialogResult == null || !mounted) return;

    setState(() => _isSaving = true);
    final savePlantToGarden = context.read<SavePlantToGarden>();
    final messenger = ScaffoldMessenger.of(context);
    await savePlantToGarden(
      name: dialogResult.name,
      species: dialogResult.species,
      imagePath: widget.scan.imagePath,
      notes: dialogResult.notes,
      status: _plantStatusFor(_result.severity),
      sourceScanId: widget.scan.id!,
    );
    if (!mounted) return;
    context.read<MyGardenProvider>().loadPlants();
    context.read<ScanHistoryProvider>().loadScans();
    context.read<PlantHealthDashboardProvider>().loadSummary();
    setState(() {
      _isSaving = false;
      _isSaved = true;
    });
    messenger.showSnackBar(const SnackBar(content: Text('Saved to My Garden')));
  }

  Future<void> _viewInGarden() async {
    final plantId = widget.scan.plantId;
    if (plantId == null) return;
    final plant = await context.read<GetPlantById>()(plantId);
    if (!mounted || plant == null) return;
    context.push(AppRoutes.plantDetail, extra: plant);
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Scan Detail'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Image.file(File(scan.imagePath), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(_result.diagnosisLabel, style: textTheme.headlineMedium),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(status: _healthStatusFor(_result.severity)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _result.plantSpeciesLatin != null
                ? '${_result.plantCommonName} · ${_result.plantSpeciesLatin}'
                : _result.plantCommonName,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Scanned ${_formatDate(scan.scannedAt)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
                      '${(_result.confidence * 100).round()}%',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  child: LinearProgressIndicator(
                    value: _result.confidence,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('About this diagnosis', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(_result.description, style: textTheme.bodyMedium),
          if (_result.visualSymptoms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('What we noticed', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            ..._result.visualSymptoms.map(
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
                imagePath: scan.imagePath,
                result: _result,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (scan.plantId != null)
            AppSecondaryButton(
              label: 'View in My Garden',
              icon: Icons.local_florist_outlined,
              onPressed: _viewInGarden,
            )
          else
            AppSecondaryButton(
              label: _isSaved ? 'Saved to My Garden' : 'Save to My Garden',
              icon: _isSaved ? Icons.check : Icons.bookmark_add_outlined,
              onPressed: (_isSaved || _isSaving) ? null : _saveToGarden,
            ),
        ],
      ),
    );
  }
}

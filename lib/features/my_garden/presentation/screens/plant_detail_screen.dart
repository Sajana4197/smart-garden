import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/routing/app_router.dart';
import '../../../home_dashboard/presentation/widgets/scan_source_sheet.dart';
import '../../../scan_history/domain/entities/scan.dart';
import '../../../scan_history/domain/usecases/get_scans_for_plant.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/update_plant.dart';
import '../providers/my_garden_provider.dart';
import '../widgets/save_to_garden_dialog.dart';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

AppHealthStatus _scanStatus(ScanSeverity severity) => switch (severity) {
      ScanSeverity.none => AppHealthStatus.healthy,
      ScanSeverity.mild => AppHealthStatus.mild,
      ScanSeverity.moderate => AppHealthStatus.moderate,
      ScanSeverity.severe => AppHealthStatus.severe,
    };

/// Full info for one My Garden entry: photo, notes, a rescan CTA, and that
/// plant's scan history (via `GetScansForPlant`) — per ROADMAP.md Phase 9.
/// Note: "Rescan" opens the standard Camera/Gallery choice sheet (same as
/// Home's quick-scan CTA); it does not auto-link the resulting scan back to
/// this plant — see CLAUDE.md §3 for why that's deferred.
class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, required this.plant});

  final Plant plant;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late Plant _plant;
  List<Scan> _scans = [];
  bool _isLoadingScans = true;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
    _loadScans();
  }

  Future<void> _loadScans() async {
    setState(() => _isLoadingScans = true);
    final getScansForPlant = context.read<GetScansForPlant>();
    final scans = await getScansForPlant(_plant.id!);
    if (!mounted) return;
    setState(() {
      _scans = scans;
      _isLoadingScans = false;
    });
  }

  Future<void> _edit() async {
    final result = await SaveToGardenDialog.show(
      context,
      title: 'Edit Plant',
      initialName: _plant.name,
      initialSpecies: _plant.species,
      initialNotes: _plant.notes,
    );
    if (result == null || !mounted) return;

    final updated = Plant(
      id: _plant.id,
      name: result.name,
      species: result.species,
      imagePath: _plant.imagePath,
      dateAdded: _plant.dateAdded,
      lastScanId: _plant.lastScanId,
      notes: result.notes,
      status: _plant.status,
    );
    await context.read<UpdatePlant>()(updated);
    if (!mounted) return;
    context.read<MyGardenProvider>().loadPlants();
    setState(() => _plant = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plant updated')),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this plant?'),
        content: Text(
          "This removes ${_plant.name} from My Garden. Its scan history "
          'stays in Scan History.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<DeletePlant>()(_plant.id!);
    if (!mounted) return;
    context.read<MyGardenProvider>().loadPlants();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: SmartGardenAppBar(
        title: _plant.name,
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Image.file(File(_plant.imagePath), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(_plant.name, style: textTheme.headlineMedium),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(
                status: AppHealthStatus.values.byName(_plant.status.name),
              ),
            ],
          ),
          if (_plant.species != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _plant.species!,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Added ${_formatDate(_plant.dateAdded)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (_plant.notes != null && _plant.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Notes', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(_plant.notes!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Rescan This Plant',
            icon: Icons.camera_alt_outlined,
            onPressed: () => showScanSourceSheet(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Scan History', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (_isLoadingScans)
            const AppLoadingIndicator()
          else if (_scans.isEmpty)
            Text(
              'No scans linked to this plant yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (final scan in _scans) ...[
              _ScanHistoryTile(
                scan: scan,
                onTap: () =>
                    context.push(AppRoutes.scanDetail, extra: scan),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _ScanHistoryTile extends StatelessWidget {
  const _ScanHistoryTile({required this.scan, required this.onTap});

  final Scan scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: Image.file(
              File(scan.imagePath),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.diagnosisLabel, style: textTheme.titleMedium),
                Text(
                  _formatDate(scan.scannedAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppStatusBadge(status: _scanStatus(scan.severity)),
        ],
      ),
    );
  }
}

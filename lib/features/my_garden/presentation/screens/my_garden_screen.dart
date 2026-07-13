import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/safe_file_image.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../domain/entities/plant.dart';
import '../providers/my_garden_provider.dart';

/// Grid of saved plants (thumbnail, name, status badge) — per ROADMAP.md
/// Phase 9. `MyGardenProvider` is registered app-wide (app.dart), not
/// screen-scoped: `StatefulShellRoute.indexedStack` keeps this screen's
/// subtree alive across tab switches without rebuilding it, so a
/// screen-local provider created once on first visit would never see
/// plants saved afterward from Result. Every mutating action (Save/Edit/
/// Delete) explicitly calls `loadPlants()` on this shared instance right
/// after it succeeds, rather than trying to detect "tab became visible."
class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyGardenProvider>();

    late final Widget body;
    if (provider.isLoading && provider.plants.isEmpty) {
      body = const _PlantGridSkeleton();
    } else if (provider.hasError) {
      body = ErrorStateWidget(
        title: 'Could not load your garden',
        message: 'Something went wrong loading your saved plants.',
        retryLabel: 'Try Again',
        onRetry: provider.loadPlants,
      );
    } else if (provider.plants.isEmpty) {
      body = const EmptyStateWidget(
        icon: Icons.local_florist_outlined,
        title: 'Your garden is empty',
        message: 'Plants you save from a scan will show up here.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadPlants,
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.78,
          ),
          itemCount: provider.plants.length,
          itemBuilder: (context, index) {
            final plant = provider.plants[index];
            return StaggeredFadeIn(
              index: index,
              child: _PlantGridTile(
                plant: plant,
                onTap: () => context.push(AppRoutes.plantDetail, extra: plant),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'My Garden'),
      body: body,
    );
  }
}

class _PlantGridSkeleton extends StatelessWidget {
  const _PlantGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SkeletonBox(width: double.infinity, height: double.infinity)),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 96, height: 14),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 64, height: 12),
        ],
      ),
    );
  }
}

class _PlantGridTile extends StatelessWidget {
  const _PlantGridTile({required this.plant, required this.onTap});

  final Plant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    child: SafeFileImage(path: plant.imagePath),
                  ),
                ),
                Positioned(
                  right: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  child: AppStatusBadge(
                    status: AppHealthStatus.values.byName(plant.status.name),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            plant.name,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (plant.species != null)
            Text(
              plant.species!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

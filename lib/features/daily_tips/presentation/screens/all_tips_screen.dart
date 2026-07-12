import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../domain/entities/plant_tip.dart';
import '../../domain/usecases/get_all_tips.dart';

/// Browses the full local tip bank — Phase 12's optional "All Tips" screen.
class AllTipsScreen extends StatefulWidget {
  const AllTipsScreen({super.key});

  @override
  State<AllTipsScreen> createState() => _AllTipsScreenState();
}

class _AllTipsScreenState extends State<AllTipsScreen> {
  late Future<List<PlantTip>> _tipsFuture;

  @override
  void initState() {
    super.initState();
    _tipsFuture = context.read<GetAllTips>()();
  }

  void _retry() {
    setState(() {
      _tipsFuture = context.read<GetAllTips>()();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'All Tips'),
      body: FutureBuilder<List<PlantTip>>(
        future: _tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorStateWidget(
              title: "Couldn't load tips",
              message: 'Something went wrong loading the tip bank.',
              retryLabel: 'Retry',
              onRetry: _retry,
            );
          }
          final tips = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: tips.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      tip.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../result/presentation/screens/result_screen.dart';
import '../../../scan_history/domain/entities/scan.dart';
import '../../../scan_history/domain/repositories/scan_repository.dart';
import '../../../scan_history/presentation/providers/scan_history_provider.dart';

/// Branded "analyzing your plant" state — a scanning-line sweep over the
/// just-captured photo, per UI_GUIDELINES.md §5. Keeps the same Hero tag as
/// Preview/Result so the photo persists visually across all three screens.
/// Calls the real `AIService.analyzeImage()` (Phase 7), persists the
/// resulting scan via `ScanRepository`, then hands off to Result. On
/// `AIServiceException` it shows an inline error with Retry, per
/// MODEL_INTEGRATION.md §2 — never a raw exception.
class AiLoadingScreen extends StatefulWidget {
  const AiLoadingScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<AiLoadingScreen> createState() => _AiLoadingScreenState();
}

class _AiLoadingScreenState extends State<AiLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sweepController;
  late final AnimationController _pulseController;
  AIServiceException? _error;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() => _error = null);
    final aiService = context.read<AIService>();
    final scanRepository = context.read<ScanRepository>();
    try {
      final result = await aiService.analyzeImage(File(widget.imagePath));
      final scanId = await scanRepository.addScan(
        Scan(
          imagePath: widget.imagePath,
          diagnosisLabel: result.diagnosisLabel,
          confidence: result.confidence,
          severity: ScanSeverity.values.byName(result.severity.name),
          rawResultJson: jsonEncode(result.toJson()),
          scannedAt: result.analyzedAt,
        ),
      );
      if (!mounted) return;
      context.read<ScanHistoryProvider>().loadScans();
      GoRouter.of(context).pushReplacement(
        AppRoutes.result,
        extra: ResultScreenArgs(
          imagePath: widget.imagePath,
          result: result,
          scanId: scanId,
        ),
      );
    } on AIServiceException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _errorTitle(AIServiceErrorType type) {
    switch (type) {
      case AIServiceErrorType.invalidImage:
        return 'Unreadable photo';
      case AIServiceErrorType.modelUnavailable:
        return 'Diagnosis unavailable';
      case AIServiceErrorType.inferenceFailed:
        return 'Analysis failed';
      case AIServiceErrorType.timeout:
        return 'Taking too long';
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: error != null ? _buildError(error) : _buildAnalyzing(),
    );
  }

  Widget _buildError(AIServiceException error) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white70),
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorTitle(error.type),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(label: 'Try Again', onPressed: _runAnalysis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: widget.imagePath,
          child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
        ),
        // Scrim so the sweep line and label stay legible over any photo —
        // same image-overlay rule as UI_GUIDELINES.md §2.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black45, Colors.black87],
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _sweepController,
            child: Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            builder: (context, child) => Align(
              alignment: Alignment(0, -1 + 2 * _sweepController.value),
              child: child,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: AppSpacing.xxl,
          child: Center(
            child: FadeTransition(
              opacity: _pulseController.drive(
                Tween<double>(begin: 0.5, end: 1),
              ),
              child: Text(
                'Analyzing your plant…',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

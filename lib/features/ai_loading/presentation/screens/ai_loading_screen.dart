import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';

// TODO(Phase 7): Replace the simulated delay below with a real call to
// AIService.analyzeImage() (injected via provider) once the contract and
// MockAIService exist per MODEL_INTEGRATION.md. Navigate to Result with the
// resulting PlantDiagnosisResult instead of just the image path.
const _simulatedAnalysisDuration = Duration(seconds: 2, milliseconds: 200);

/// Branded "analyzing your plant" state — a scanning-line sweep over the
/// just-captured photo, per UI_GUIDELINES.md §5. Keeps the same Hero tag as
/// Preview/Result so the photo persists visually across all three screens.
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
    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    await Future.delayed(_simulatedAnalysisDuration);
    if (!mounted) return;
    GoRouter.of(context).pushReplacement(
      AppRoutes.result,
      extra: widget.imagePath,
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
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
      ),
    );
  }
}

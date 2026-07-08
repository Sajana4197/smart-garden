import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_slide_view.dart';

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

const List<_OnboardingSlideData> _slides = [
  _OnboardingSlideData(
    icon: Icons.camera_alt_outlined,
    title: 'Diagnose in a snap',
    description:
        'Photograph any leaf and get an instant read on your plant\'s health.',
  ),
  _OnboardingSlideData(
    icon: Icons.eco_outlined,
    title: 'Grow your garden',
    description:
        'Save every plant you scan and track its health over time.',
  ),
  _OnboardingSlideData(
    icon: Icons.spa_outlined,
    title: 'Personalized care',
    description:
        'Get watering, light, and treatment guidance tailored to each diagnosis.',
  ),
  _OnboardingSlideData(
    icon: Icons.wb_sunny_outlined,
    title: 'Weather-aware tips',
    description:
        'Daily advice and spoken guidance that factor in your local conditions.',
  ),
];

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingProvider(context.read<CompleteOnboarding>()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish(OnboardingProvider provider) async {
    await provider.complete();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final isLastPage = provider.currentPage == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: TextButton(
                  onPressed: () => _finish(provider),
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: provider.setPage,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return OnboardingSlideView(
                    icon: slide.icon,
                    title: slide.title,
                    description: slide.description,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OnboardingPageIndicator(
              count: _slides.length,
              currentIndex: provider.currentPage,
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: isLastPage ? 'Get Started' : 'Next',
                  onPressed: () {
                    if (isLastPage) {
                      _finish(provider);
                    } else {
                      _pageController.nextPage(
                        duration: AppDurations.medium,
                        curve: AppCurves.standard,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

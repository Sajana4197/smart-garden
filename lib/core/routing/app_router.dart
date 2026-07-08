import 'package:go_router/go_router.dart';

import '../debug/component_gallery_screen.dart';
import '../../features/home_dashboard/presentation/screens/home_dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String debugGallery = '/debug/gallery';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.debugGallery,
      builder: (context, state) => const ComponentGalleryScreen(),
    ),
  ],
);

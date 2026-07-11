import 'package:go_router/go_router.dart';

import '../debug/component_gallery_screen.dart';
import 'main_shell_screen.dart';
import '../../features/ai_loading/presentation/screens/ai_loading_screen.dart';
import '../../features/camera/presentation/screens/camera_screen.dart';
import '../../features/home_dashboard/presentation/screens/home_dashboard_screen.dart';
import '../../features/my_garden/domain/entities/plant.dart';
import '../../features/my_garden/presentation/screens/my_garden_screen.dart';
import '../../features/my_garden/presentation/screens/plant_detail_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/plant_health_dashboard/presentation/screens/plant_health_dashboard_screen.dart';
import '../../features/preview/presentation/screens/preview_screen.dart';
import '../../features/recommendation/presentation/screens/recommendation_screen.dart';
import '../../features/result/presentation/screens/result_screen.dart';
import '../../features/scan_history/presentation/screens/scan_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String myGarden = '/my-garden';
  static const String scanHistory = '/scan-history';
  static const String plantHealth = '/plant-health';
  static const String settings = '/settings';
  static const String camera = '/camera';
  static const String preview = '/preview';
  static const String aiLoading = '/ai-loading';
  static const String result = '/result';
  static const String recommendation = '/recommendation';
  static const String plantDetail = '/my-garden/detail';
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
      path: AppRoutes.debugGallery,
      builder: (context, state) => const ComponentGalleryScreen(),
    ),
    GoRoute(
      path: AppRoutes.camera,
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: AppRoutes.preview,
      builder: (context, state) =>
          PreviewScreen(imagePath: state.extra! as String),
    ),
    GoRoute(
      path: AppRoutes.aiLoading,
      builder: (context, state) =>
          AiLoadingScreen(imagePath: state.extra! as String),
    ),
    GoRoute(
      path: AppRoutes.result,
      builder: (context, state) {
        final args = state.extra! as ResultScreenArgs;
        return ResultScreen(
          imagePath: args.imagePath,
          result: args.result,
          scanId: args.scanId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.recommendation,
      builder: (context, state) {
        final args = state.extra! as RecommendationScreenArgs;
        return RecommendationScreen(
          imagePath: args.imagePath,
          result: args.result,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.plantDetail,
      builder: (context, state) =>
          PlantDetailScreen(plant: state.extra! as Plant),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.myGarden,
              builder: (context, state) => const MyGardenScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.scanHistory,
              builder: (context, state) => const ScanHistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.plantHealth,
              builder: (context, state) => const PlantHealthDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

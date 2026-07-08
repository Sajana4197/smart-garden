import 'package:go_router/go_router.dart';

import '../../features/home_dashboard/presentation/screens/home_dashboard_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeDashboardScreen(),
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';

class SmartGardenApp extends StatelessWidget {
  const SmartGardenApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final OnboardingRepository onboardingRepository = OnboardingRepositoryImpl(
      OnboardingLocalDataSource(prefs),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController()),
        Provider<CheckOnboardingStatus>(
          create: (_) => CheckOnboardingStatus(onboardingRepository),
        ),
        Provider<CompleteOnboarding>(
          create: (_) => CompleteOnboarding(onboardingRepository),
        ),
      ],
      child: Consumer<ThemeModeController>(
        builder: (context, themeController, _) {
          return MaterialApp.router(
            title: 'SmartGarden AI',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

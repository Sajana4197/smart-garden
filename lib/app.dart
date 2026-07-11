import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/camera/data/repositories/camera_capture_repository_impl.dart';
import 'features/camera/domain/repositories/camera_capture_repository.dart';
import 'features/camera/domain/usecases/store_captured_photo.dart';
import 'features/gallery/data/repositories/gallery_repository_impl.dart';
import 'features/gallery/domain/repositories/gallery_repository.dart';
import 'features/gallery/domain/usecases/store_picked_photo.dart';
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'features/recommendation/domain/repositories/recommendation_repository.dart';
import 'features/recommendation/domain/usecases/get_care_recommendation.dart';
import 'features/scan_history/data/datasources/scan_local_datasource.dart';
import 'features/scan_history/data/repositories/scan_repository_impl.dart';
import 'features/scan_history/domain/repositories/scan_repository.dart';
import 'services/ai/ai_service.dart';
import 'services/ai/mock_ai_service.dart';
import 'services/storage/image_storage_service.dart';

class SmartGardenApp extends StatelessWidget {
  const SmartGardenApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final OnboardingRepository onboardingRepository = OnboardingRepositoryImpl(
      OnboardingLocalDataSource(prefs),
    );
    final imageStorageService = ImageStorageService();
    final CameraCaptureRepository cameraCaptureRepository =
        CameraCaptureRepositoryImpl(imageStorageService);
    final GalleryRepository galleryRepository =
        GalleryRepositoryImpl(imageStorageService);
    final AIService aiService = MockAIService();
    final ScanRepository scanRepository = ScanRepositoryImpl(
      ScanLocalDataSource(),
    );
    final RecommendationRepository recommendationRepository =
        RecommendationRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController()),
        Provider<CheckOnboardingStatus>(
          create: (_) => CheckOnboardingStatus(onboardingRepository),
        ),
        Provider<CompleteOnboarding>(
          create: (_) => CompleteOnboarding(onboardingRepository),
        ),
        Provider<StoreCapturedPhoto>(
          create: (_) => StoreCapturedPhoto(cameraCaptureRepository),
        ),
        Provider<StorePickedPhoto>(
          create: (_) => StorePickedPhoto(galleryRepository),
        ),
        Provider<AIService>(create: (_) => aiService),
        Provider<ScanRepository>(create: (_) => scanRepository),
        Provider<GetCareRecommendation>(
          create: (_) => GetCareRecommendation(recommendationRepository),
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

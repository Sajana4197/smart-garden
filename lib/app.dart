import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/daily_tips/data/datasources/daily_tip_state_local_datasource.dart';
import 'features/daily_tips/data/datasources/tip_bank_datasource.dart';
import 'features/daily_tips/data/repositories/daily_tip_repository_impl.dart';
import 'features/daily_tips/domain/repositories/daily_tip_repository.dart';
import 'features/daily_tips/domain/usecases/get_all_tips.dart';
import 'features/daily_tips/domain/usecases/get_daily_tip.dart';
import 'features/daily_tips/presentation/providers/daily_tip_provider.dart';
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
import 'features/my_garden/data/datasources/plant_local_datasource.dart';
import 'features/my_garden/data/repositories/plant_repository_impl.dart';
import 'features/my_garden/domain/repositories/plant_repository.dart';
import 'features/my_garden/domain/usecases/delete_plant.dart';
import 'features/my_garden/domain/usecases/get_all_plants.dart';
import 'features/my_garden/domain/usecases/get_plant_by_id.dart';
import 'features/my_garden/domain/usecases/save_plant_to_garden.dart';
import 'features/my_garden/domain/usecases/update_plant.dart';
import 'features/my_garden/presentation/providers/my_garden_provider.dart';
import 'features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'features/recommendation/domain/repositories/recommendation_repository.dart';
import 'features/recommendation/domain/usecases/get_care_recommendation.dart';
import 'features/scan_history/data/datasources/scan_local_datasource.dart';
import 'features/scan_history/data/repositories/scan_repository_impl.dart';
import 'features/scan_history/domain/repositories/scan_repository.dart';
import 'features/scan_history/domain/usecases/get_all_scans.dart';
import 'features/scan_history/domain/usecases/get_scans_for_plant.dart';
import 'features/scan_history/presentation/providers/scan_history_provider.dart';
import 'features/weather/data/datasources/weather_local_datasource.dart';
import 'features/weather/data/datasources/weather_remote_datasource.dart';
import 'features/weather/data/repositories/location_repository_impl.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/location_repository.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/domain/usecases/get_cached_weather.dart';
import 'features/weather/domain/usecases/get_current_weather.dart';
import 'features/weather/presentation/providers/weather_provider.dart';
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
    final PlantRepository plantRepository = PlantRepositoryImpl(
      PlantLocalDataSource(),
    );
    final LocationRepository locationRepository = LocationRepositoryImpl();
    final WeatherRepository weatherRepository = WeatherRepositoryImpl(
      WeatherRemoteDataSource(),
      WeatherLocalDataSource(prefs),
    );
    final DailyTipRepository dailyTipRepository = DailyTipRepositoryImpl(
      TipBankDataSource(),
      DailyTipStateLocalDataSource(),
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
        Provider<GetAllPlants>(
          create: (_) => GetAllPlants(plantRepository),
        ),
        Provider<UpdatePlant>(
          create: (_) => UpdatePlant(plantRepository),
        ),
        Provider<DeletePlant>(
          create: (_) => DeletePlant(plantRepository),
        ),
        Provider<GetPlantById>(
          create: (_) => GetPlantById(plantRepository),
        ),
        Provider<SavePlantToGarden>(
          create: (_) => SavePlantToGarden(plantRepository, scanRepository),
        ),
        Provider<GetScansForPlant>(
          create: (_) => GetScansForPlant(scanRepository),
        ),
        Provider<GetAllScans>(
          create: (_) => GetAllScans(scanRepository),
        ),
        ChangeNotifierProvider<MyGardenProvider>(
          create: (context) => MyGardenProvider(
            context.read<GetAllPlants>(),
            context.read<DeletePlant>(),
          )..loadPlants(),
        ),
        ChangeNotifierProvider<ScanHistoryProvider>(
          create: (context) =>
              ScanHistoryProvider(context.read<GetAllScans>())..loadScans(),
        ),
        Provider<GetCurrentWeather>(
          create: (_) => GetCurrentWeather(locationRepository, weatherRepository),
        ),
        Provider<GetCachedWeather>(
          create: (_) => GetCachedWeather(weatherRepository),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<GetCurrentWeather>(),
            context.read<GetCachedWeather>(),
          )..loadWeather(),
        ),
        Provider<GetDailyTip>(
          create: (_) => GetDailyTip(dailyTipRepository),
        ),
        Provider<GetAllTips>(
          create: (_) => GetAllTips(dailyTipRepository),
        ),
        ChangeNotifierProvider<DailyTipProvider>(
          create: (context) =>
              DailyTipProvider(context.read<GetDailyTip>())..loadTip(),
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

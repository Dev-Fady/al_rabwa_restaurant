import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/core/services/api/dio_config.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/settings_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Register the settings cubit first so the app can still build if storage
  // initialization below fails.
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit());

  final cacheHelper = CacheHelper();
  await cacheHelper.init();
  getIt.registerSingleton<CacheHelper>(cacheHelper);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      ),
    ),
  );

  getIt.registerLazySingleton<Dio>(
    () => DioConfig.createDio(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<ApiService>(), getIt<CacheHelper>()),
  );

  getIt.registerFactory<StoreConfigCubit>(
    () => StoreConfigCubit(getIt<SettingsRepository>()),
  );
}

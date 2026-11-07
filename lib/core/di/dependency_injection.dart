import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_hive.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/core/services/api/dio_config.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/menu_categories_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/menu_categories_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/settings_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/data/datasources/menu_items_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/menu/data/repositories/menu_items_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
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

  try {
    await CacheHive.init();
  } catch (_) {
    // Hive is only used for the offline settings cache. If it cannot open,
    // keep the app running and let the repository fall back to the network.
  }

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

  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    SettingsLocalDataSourceImpl.new,
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: getIt<SettingsRemoteDataSource>(),
      localDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );

  getIt.registerFactory<StoreConfigCubit>(
    () => StoreConfigCubit(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton<MenuCategoriesRemoteDataSource>(
    () => MenuCategoriesRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<MenuCategoriesRepository>(
    () => MenuCategoriesRepositoryImpl(
      remoteDataSource: getIt<MenuCategoriesRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<HomeCategoriesCubit>(
    () => HomeCategoriesCubit(getIt<MenuCategoriesRepository>()),
  );

  getIt.registerLazySingleton<MenuItemsRemoteDataSource>(
    () => MenuItemsRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<MenuItemsRepository>(
    () => MenuItemsRepositoryImpl(
      remoteDataSource: getIt<MenuItemsRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<MenuCubit>(
    () => MenuCubit(
      getIt<MenuCategoriesRepository>(),
      getIt<MenuItemsRepository>(),
    ),
  );
}

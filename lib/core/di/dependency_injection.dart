import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/core/services/api/dio_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

Future<void> setupGetIt() async {
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

 
}

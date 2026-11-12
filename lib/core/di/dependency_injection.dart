import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_hive.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_quote_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_quote_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/repositories/cart_quote_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_quote_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:al_rabwa_restaurant/features/tables/data/datasources/tables_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/tables/data/repositories/tables_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/repositories/tables_repository.dart';
import 'package:al_rabwa_restaurant/core/services/api/dio_config.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/datasources/addresses_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/repositories/addresses_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/repositories/device_location_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/device_location_repository.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/add_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_list_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/menu_categories_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/menu_categories_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/settings_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_delivery_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/data/datasources/menu_items_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/menu/data/repositories/menu_items_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/item_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/features/registration/data/datasources/device_registration_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/registration/data/repositories/device_registration_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/registration/domain/repositories/device_registration_repository.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/data/datasources/account_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/settings/data/repositories/account_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/settings/domain/repositories/account_repository.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_cubit.dart';
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

  // Cart persistence — registered AFTER CacheHive.init() so the lazy
  // singletons can safely open the Hive box on first access.
  getIt.registerLazySingleton<CartLocalDataSource>(
    CartLocalDataSourceImpl.new,
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<CartLocalDataSource>()),
  );
  // One cart instance for the whole app (menu, details and nav badge).
  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(getIt<CartRepository>()),
  );

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

  getIt.registerLazySingleton<CartQuoteRemoteDataSource>(
    () => CartQuoteRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<CartQuoteLocalDataSource>(
    CartQuoteLocalDataSourceImpl.new,
  );

  getIt.registerLazySingleton<CartQuoteRepository>(
    () => CartQuoteRepositoryImpl(
      remoteDataSource: getIt<CartQuoteRemoteDataSource>(),
      localDataSource: getIt<CartQuoteLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CartQuoteCubit>(
    () => CartQuoteCubit(getIt<CartQuoteRepository>(), getIt<CartCubit>()),
  );

  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<OrdersRepository>(
    () =>
        OrdersRepositoryImpl(remoteDataSource: getIt<OrdersRemoteDataSource>()),
  );

  getIt.registerLazySingleton<TablesRemoteDataSource>(
    () => TablesRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<TablesRepository>(
    () =>
        TablesRepositoryImpl(remoteDataSource: getIt<TablesRemoteDataSource>()),
  );

  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      getIt<OrdersRepository>(),
      getIt<AddressesRepository>(),
      getIt<TablesRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeviceRegistrationRemoteDataSource>(
    () =>
        DeviceRegistrationRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<DeviceRegistrationRepository>(
    () => DeviceRegistrationRepositoryImpl(
      remoteDataSource: getIt<DeviceRegistrationRemoteDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerFactory<DeviceRegistrationCubit>(
    () => DeviceRegistrationCubit(getIt<DeviceRegistrationRepository>()),
  );

  getIt.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      remoteDataSource: getIt<AccountRemoteDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerFactory<DeleteMyDataCubit>(
    () => DeleteMyDataCubit(getIt<AccountRepository>()),
  );

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

  getIt.registerFactoryParam<ItemDetailsCubit, int, String>(
    (itemId, lang) =>
        ItemDetailsCubit(getIt<MenuItemsRepository>(), itemId, lang: lang),
  );

  getIt.registerLazySingleton<AddressesRemoteDataSource>(
    () => AddressesRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AddressesRepository>(
    () => AddressesRepositoryImpl(
      remoteDataSource: getIt<AddressesRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<DeviceLocationRepository>(
    () => const DeviceLocationRepositoryImpl(),
  );

  getIt.registerFactoryParam<AddAddressCubit, String, void>(
    (lang, _) => AddAddressCubit(
      getIt<AddressesRepository>(),
      getIt<DeviceLocationRepository>(),
      lang: lang,
    ),
  );

  getIt.registerFactoryParam<AddressListCubit, String, void>(
    (lang, _) => AddressListCubit(getIt<AddressesRepository>(), lang: lang),
  );

  getIt.registerFactoryParam<AddressDetailsCubit, int, String>(
    (id, lang) => AddressDetailsCubit(
      getIt<AddressesRepository>(),
      addressId: id,
      lang: lang,
    ),
  );

  getIt.registerFactoryParam<HomeDeliveryAddressCubit, String, void>(
    (lang, _) => HomeDeliveryAddressCubit(
      getIt<AddressesRepository>(),
      getIt<FlutterSecureStorage>(),
      lang: lang,
    ),
  );
}

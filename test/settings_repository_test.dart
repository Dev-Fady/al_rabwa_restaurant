import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/settings_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/settings_fixtures.dart';

class _FakeApiService implements ApiService {
  _FakeApiService({required this.payload});

  dynamic payload;
  Object? error;
  String? lastLang;
  String? lastLocale;

  @override
  Future<HttpResponse<dynamic>> getSettings({
    String? lang,
    String? xLocale,
  }) async {
    lastLang = lang;
    lastLocale = xLocale;
    final failure = error;
    if (failure != null) throw failure;
    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'settings'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CacheHelper cache;
  late _FakeApiService api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = CacheHelper();
    await cache.init();
    api = _FakeApiService(payload: settingsPayload());
  });

  SettingsRepositoryImpl buildRepository() {
    return SettingsRepositoryImpl(api, cache);
  }

  test('fetches and maps the settings payload', () async {
    final settings = await buildRepository().fetchSettings(lang: 'ar');

    expect(settings.restaurant.name, 'مطعم الربوة');
    expect(settings.primaryBanner?.title, 'مشاوي على الفحم');
    expect(settings.ordering.orderTypes, hasLength(3));
    expect(api.lastLang, 'ar');
    expect(api.lastLocale, 'ar');
  });

  test('throws a server failure when there is no cached payload', () async {
    api.error = DioException(
      requestOptions: RequestOptions(path: 'settings'),
      type: DioExceptionType.connectionError,
      message: 'no network',
    );

    await expectLater(
      buildRepository().fetchSettings(lang: 'ar'),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('serves the cached settings when a later request fails', () async {
    final repository = buildRepository();
    final fresh = await repository.fetchSettings(lang: 'ar');

    api.error = DioException(
      requestOptions: RequestOptions(path: 'settings'),
      type: DioExceptionType.connectionError,
    );

    final cached = await repository.fetchSettings(lang: 'ar');

    expect(cached.restaurant.name, fresh.restaurant.name);
    expect(cached.currency.symbol, 'ر.ق');
  });
}

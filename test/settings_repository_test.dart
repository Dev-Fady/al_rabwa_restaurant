import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/settings_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/data/repositories/settings_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

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

class _FakeLocalDataSource implements SettingsLocalDataSource {
  final Map<String, Map<String, dynamic>> store = {};

  int saves = 0;

  @override
  Future<void> save({
    required String lang,
    required Map<String, dynamic> payload,
  }) async {
    saves++;
    store[lang] = payload;
  }

  @override
  Map<String, dynamic>? read({required String lang}) => store[lang];

  @override
  Future<void> clear({required String lang}) async {
    store.remove(lang);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeApiService api;
  late _FakeLocalDataSource local;

  setUp(() {
    api = _FakeApiService(payload: settingsPayload());
    local = _FakeLocalDataSource();
  });

  SettingsRepositoryImpl buildRepository() {
    return SettingsRepositoryImpl(
      remoteDataSource: SettingsRemoteDataSourceImpl(apiService: api),
      localDataSource: local,
    );
  }

  test('fetches, maps, and caches the settings payload', () async {
    final result = await buildRepository().fetchSettings(lang: 'ar');
    final settings = result.getOrElse(
      () => fail('expected settings, got $result'),
    );

    expect(settings.restaurant.name, 'مطعم الربوة');
    expect(settings.primaryBanner?.title, 'مشاوي على الفحم');
    expect(settings.ordering.orderTypes, hasLength(3));
    expect(api.lastLang, 'ar');
    expect(api.lastLocale, 'ar');
    expect(local.store.containsKey('ar'), isTrue);
  });

  test('returns a server failure when there is no cached payload', () async {
    api.error = DioException(
      requestOptions: RequestOptions(path: 'settings'),
      type: DioExceptionType.connectionError,
      message: 'no network',
    );

    final result = await buildRepository().fetchSettings(lang: 'ar');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('expected a failure'),
    );
    expect(local.saves, 0);
  });

  test('serves the cached settings when a later request fails', () async {
    final repository = buildRepository();
    final fresh = await repository.fetchSettings(lang: 'ar');

    api.error = DioException(
      requestOptions: RequestOptions(path: 'settings'),
      type: DioExceptionType.connectionError,
    );

    final cached = await repository.fetchSettings(lang: 'ar');

    expect(fresh.isRight(), isTrue);
    expect(cached.isRight(), isTrue);
    final cachedSettings = cached.getOrElse(
      () => fail('expected cached settings'),
    );
    final freshSettings = fresh.getOrElse(
      () => fail('expected fresh settings'),
    );
    expect(cachedSettings.restaurant.name, freshSettings.restaurant.name);
    expect(cachedSettings.currency.symbol, 'ر.ق');
  });

  test('surfaces the backend message when success is false', () async {
    final payload = settingsPayload();
    payload['success'] = false;
    payload['message'] = 'الخدمة غير متاحة حالياً';
    api.payload = payload;

    final result = await buildRepository().fetchSettings(lang: 'ar');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'الخدمة غير متاحة حالياً'),
      (_) => fail('expected a failure'),
    );
  });

  test('rejects an empty response body', () async {
    api.payload = null;

    final result = await buildRepository().fetchSettings(lang: 'ar');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'Empty response from server.'),
      (_) => fail('expected a failure'),
    );
  });
}

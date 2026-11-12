import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/tables/data/datasources/tables_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/tables/data/models/table_response.dart';
import 'package:al_rabwa_restaurant/features/tables/data/repositories/tables_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

/// Response copied from `GET /api/tables`.
Map<String, dynamic> tablesPayload() {
  return {
    'data': [
      {'id': 3, 'name': 'T202'},
      {'id': 10, 'name': 'T282'},
      {'id': 2, 'name': 'T29'},
    ],
  };
}

class _FakeApiService implements ApiService {
  _FakeApiService({required this.payload});

  dynamic payload;
  Object? error;
  String? lastLang;
  String? lastLocale;

  @override
  Future<HttpResponse<dynamic>> getTables({
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
        requestOptions: RequestOptions(path: 'tables'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTablesRemoteDataSource implements TablesRemoteDataSource {
  _FakeTablesRemoteDataSource({this.tables = const []});

  List<DiningTable> tables;
  Object? error;
  String? lastLang;

  @override
  Future<List<DiningTable>> fetchTables({String lang = 'ar'}) async {
    lastLang = lang;
    final failure = error;
    if (failure != null) throw failure;
    return tables;
  }
}

void main() {
  group('TableListResponse', () {
    test('maps the tables and skips incomplete rows', () {
      final payload = tablesPayload();
      (payload['data'] as List<dynamic>).add({'id': 4});
      (payload['data'] as List<dynamic>).add({'name': 'T88'});

      final tables = TableListResponse.fromJson(payload).toEntities();

      expect(tables, hasLength(3));
      expect(tables.first.id, 3);
      expect(tables.first.name, 'T202');
      expect(tables.last.id, 2);
      expect(tables.last.name, 'T29');
    });
  });

  group('TablesRemoteDataSource', () {
    test('sends the language and maps the table list', () async {
      final api = _FakeApiService(payload: tablesPayload());
      final dataSource = TablesRemoteDataSourceImpl(apiService: api);

      final tables = await dataSource.fetchTables(lang: 'en');

      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
      expect(tables, hasLength(3));
      expect(tables[1].id, 10);
      expect(tables[1].name, 'T282');
    });

    test('returns an empty list when the restaurant has no tables', () async {
      final dataSource = TablesRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: {'data': <dynamic>[]}),
      );

      final tables = await dataSource.fetchTables();

      expect(tables, isEmpty);
    });

    test('surfaces the backend message when success is false', () async {
      final payload = tablesPayload();
      payload['success'] = false;
      payload['message'] = 'تعذّر تحميل الطاولات';
      final dataSource = TablesRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: payload),
      );

      await expectLater(
        dataSource.fetchTables(),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'تعذّر تحميل الطاولات',
          ),
        ),
      );
    });

    test('rejects an empty response body', () async {
      final dataSource = TablesRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: null),
      );

      await expectLater(
        dataSource.fetchTables(),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('TablesRepository', () {
    test('returns the tables', () async {
      final remote = _FakeTablesRemoteDataSource(
        tables: const [
          DiningTable(id: 3, name: 'T202'),
          DiningTable(id: 10, name: 'T282'),
        ],
      );
      final repository = TablesRepositoryImpl(remoteDataSource: remote);

      final result = await repository.fetchTables(lang: 'ar');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected tables'),
        (tables) => expect(tables.map((table) => table.id), [3, 10]),
      );
      expect(remote.lastLang, 'ar');
    });

    test('maps a transport error to a server failure', () async {
      final remote = _FakeTablesRemoteDataSource()
        ..error = DioException(
          requestOptions: RequestOptions(path: 'tables'),
          type: DioExceptionType.connectionError,
        );
      final repository = TablesRepositoryImpl(remoteDataSource: remote);

      final result = await repository.fetchTables();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });
}

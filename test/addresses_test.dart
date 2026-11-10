import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/datasources/addresses_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/models/address_response.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/repositories/addresses_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/errors/location_failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/device_location_repository.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/add_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/add_address_state.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_details_state.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_list_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_list_state.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/add_address_screen.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/address_details_screen.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/address_selection_screen.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_card.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_form_fields.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/address_kind_selector.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

const _qatarPoint = GeoPoint(latitude: 25.2854, longitude: 51.5310);
const _dubaiPoint = GeoPoint(latitude: 25.2048, longitude: 55.2708);

Map<String, dynamic> _addressPayload({bool deliverable = true}) => {
  'data': {
    'id': 1,
    'kind': 'home',
    'kind_label': 'المنزل',
    'label': 'البيت',
    'title': 'البيت',
    'summary': 'السد، شارع 901، مبنى 35، الطابق 2',
    'delivery_zone': null,
    'is_deliverable': deliverable,
    'area': 'السد',
    'street': 'شارع 901',
    'building': 'مبنى 35، الطابق 2',
    'notes': 'الباب الأخضر',
    'latitude': 25.2854,
    'longitude': 51.531,
    'last_used_at': '2026-11-09T13:32:18+00:00',
  },
};

Map<String, dynamic> _addressListPayload() {
  final first = Map<String, dynamic>.from(_addressPayload()['data'] as Map);
  final second = Map<String, dynamic>.from(first)
    ..['id'] = 3
    ..['label'] = 'الشركة'
    ..['title'] = 'الشركة'
    ..['building'] = 'مبنى 40، شقة 5';

  return {
    'data': [second, first],
  };
}

class _FakeApiService implements ApiService {
  _FakeApiService({required this.payload});

  dynamic payload;
  Object? error;
  Map<String, dynamic>? lastBody;
  String? lastLang;
  String? lastLocale;
  int getAddressesCalls = 0;
  int getAddressCalls = 0;
  int updateAddressCalls = 0;
  int setDefaultCalls = 0;
  int deleteAddressCalls = 0;
  int? lastAddressId;

  @override
  Future<HttpResponse<dynamic>> getAddresses({
    String? lang,
    String? xLocale,
  }) async {
    getAddressesCalls++;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'addresses'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  Future<HttpResponse<dynamic>> getAddress({
    required int id,
    String? lang,
    String? xLocale,
  }) async {
    getAddressCalls++;
    lastAddressId = id;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'addresses/$id'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  Future<HttpResponse<dynamic>> createAddress({
    required Map<String, dynamic> body,
    String? lang,
    String? xLocale,
  }) async {
    lastBody = body;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'addresses'),
        data: payload,
        statusCode: 201,
      ),
    );
  }

  @override
  Future<HttpResponse<dynamic>> updateAddress({
    required int id,
    required Map<String, dynamic> body,
    String? lang,
    String? xLocale,
  }) async {
    updateAddressCalls++;
    lastAddressId = id;
    lastBody = body;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'addresses/$id'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  Future<HttpResponse<dynamic>> setDefaultAddress({
    required int id,
    String? lang,
    String? xLocale,
  }) async {
    setDefaultCalls++;
    lastAddressId = id;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'addresses/$id/default'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  Future<HttpResponse<dynamic>> deleteAddress({
    required int id,
    String? lang,
    String? xLocale,
  }) async {
    deleteAddressCalls++;
    lastAddressId = id;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      null,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'addresses/$id'),
        statusCode: 204,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressesRepository implements AddressesRepository {
  Either<Failure, Address>? result;
  Either<Failure, List<Address>>? fetchResult;
  Either<Failure, Address>? detailsResult;
  Either<Failure, Address>? updateResult;
  Either<Failure, Address>? defaultResult;
  Either<Failure, Unit>? deleteResult;
  int calls = 0;
  int fetchCalls = 0;
  int fetchAddressCalls = 0;
  int updateCalls = 0;
  int setDefaultCalls = 0;
  int deleteCalls = 0;
  int? lastAddressId;
  int? lastUpdateId;
  int? lastDefaultId;
  int? lastDeleteId;
  AddressKind? lastKind;
  GeoPoint? lastPoint;
  String? lastLang;
  String? lastArea;

  @override
  Future<Either<Failure, List<Address>>> fetchAddresses({
    String lang = 'ar',
  }) async {
    fetchCalls++;
    lastLang = lang;
    return fetchResult ?? Right([_address()]);
  }

  @override
  Future<Either<Failure, Address>> fetchAddress({
    required int id,
    String lang = 'ar',
  }) async {
    fetchAddressCalls++;
    lastAddressId = id;
    lastLang = lang;
    return detailsResult ?? result ?? Right(_address());
  }

  @override
  Future<Either<Failure, Address>> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    calls++;
    lastKind = kind;
    lastPoint = point;
    lastLang = lang;
    lastArea = area;
    return result!;
  }

  @override
  Future<Either<Failure, Address>> updateAddress({
    required int id,
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    updateCalls++;
    lastUpdateId = id;
    lastKind = kind;
    lastPoint = point;
    lastLang = lang;
    lastArea = area;
    return updateResult ?? result ?? Right(_address());
  }

  @override
  Future<Either<Failure, Address>> setDefaultAddress({
    required int id,
    String lang = 'ar',
  }) async {
    setDefaultCalls++;
    lastDefaultId = id;
    lastLang = lang;
    return defaultResult ?? result ?? Right(_address());
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress({
    required int id,
    String lang = 'ar',
  }) async {
    deleteCalls++;
    lastDeleteId = id;
    lastLang = lang;
    return deleteResult ?? const Right(unit);
  }
}

class _FakeLocationRepository implements DeviceLocationRepository {
  Either<Failure, GeoPoint>? result;
  int calls = 0;

  @override
  Future<Either<Failure, GeoPoint>> currentLocation() async {
    calls++;
    return result!;
  }
}

Address _address({bool deliverable = true}) => AddressResponse.fromJson(
  _addressPayload(deliverable: deliverable),
).toEntity()!;

Widget _app(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddressModel', () {
    test('maps the API payload to an entity', () {
      final address = _address();

      expect(address.id, 1);
      expect(address.kind, AddressKind.home);
      expect(address.kindLabel, 'المنزل');
      expect(address.label, 'البيت');
      expect(address.summary, contains('شارع 901'));
      expect(address.deliveryZone, isNull);
      expect(address.isDeliverable, isTrue);
      expect(address.point?.latitude, 25.2854);
      expect(
        address.lastUsedAt?.toUtc(),
        DateTime.utc(2026, 11, 9, 13, 32, 18),
      );
    });

    test('maps an object delivery zone and an unknown kind', () {
      final payload = _addressPayload();
      payload['data']['kind'] = 'office';
      payload['data']['delivery_zone'] = {'name': 'السد'};
      payload['data'].remove('is_deliverable');

      final address = AddressResponse.fromJson(payload).toEntity()!;

      expect(address.kind, AddressKind.other);
      expect(address.deliveryZone, 'السد');
      expect(address.isDeliverable, isTrue);
    });

    test('displayName prefers the label, then title, then summary', () {
      final payload = _addressPayload();
      payload['data']['label'] = '  ';
      expect(
        AddressResponse.fromJson(payload).toEntity()!.displayName,
        'البيت',
      );

      payload['data']['title'] = '';
      expect(
        AddressResponse.fromJson(payload).toEntity()!.displayName,
        contains('شارع 901'),
      );
    });
  });

  group('AddressesRemoteDataSource', () {
    late _FakeApiService api;
    late AddressesRemoteDataSourceImpl dataSource;

    setUp(() {
      api = _FakeApiService(payload: _addressPayload());
      dataSource = AddressesRemoteDataSourceImpl(apiService: api);
    });

    test('rounds the coordinate and omits empty optional fields', () async {
      await dataSource.createAddress(
        kind: AddressKind.work,
        label: '  ',
        area: ' السد ',
        street: 'شارع 901',
        building: 'مبنى 35',
        notes: '',
        point: const GeoPoint(latitude: 25.28539999999, longitude: 51.531),
        lang: 'ar',
      );

      expect(api.lastBody, {
        'kind': 'work',
        'label': null,
        'area': 'السد',
        'street': 'شارع 901',
        'building': 'مبنى 35',
        'notes': null,
        'latitude': 25.2854,
        'longitude': 51.531,
      });
      expect(api.lastLang, 'ar');
      expect(api.lastLocale, 'ar');
    });

    test('throws a server failure when success is false', () async {
      api.payload = {'success': false, 'message': 'خارج نطاق التوصيل'};

      expect(
        () => dataSource.createAddress(
          kind: AddressKind.home,
          label: '',
          area: 'السد',
          street: 'شارع 901',
          building: 'مبنى 35',
          notes: '',
          point: _qatarPoint,
        ),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'خارج نطاق التوصيل',
          ),
        ),
      );
    });

    test('maps the saved address list and sends the language', () async {
      api.payload = _addressListPayload();

      final addresses = await dataSource.fetchAddresses(lang: 'en');

      expect(addresses, hasLength(2));
      expect(addresses.map((address) => address.id), [3, 1]);
      expect(addresses.first.displayName, 'الشركة');
      expect(addresses.last.displayName, 'البيت');
      expect(api.getAddressesCalls, 1);
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
    });

    test('returns an empty list when no address is saved', () async {
      api.payload = {'data': <dynamic>[]};

      final addresses = await dataSource.fetchAddresses();

      expect(addresses, isEmpty);
    });

    test('throws a server failure when the list response fails', () async {
      api.payload = {'success': false, 'message': 'Unauthorized'};

      expect(
        () => dataSource.fetchAddresses(),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Unauthorized',
          ),
        ),
      );
    });

    test('loads one address by id and sends the language', () async {
      final payload = _addressPayload();
      payload['data']['id'] = 3;

      api.payload = payload;

      final address = await dataSource.fetchAddress(id: 3, lang: 'en');

      expect(address.data?.id, 3);
      expect(address.toEntity()?.displayName, 'البيت');
      expect(api.getAddressCalls, 1);
      expect(api.lastAddressId, 3);
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
    });

    test('patches the address with the same payload shape', () async {
      final payload = _addressPayload();
      payload['data']['building'] = 'مبنى 40، شقة 5';

      api.payload = payload;

      final response = await dataSource.updateAddress(
        id: 3,
        kind: AddressKind.work,
        label: 'الشركة',
        area: ' السد ',
        street: 'شارع 901',
        building: 'مبنى 40، شقة 5',
        notes: 'الباب الأخضر',
        point: const GeoPoint(latitude: 25.28539999999, longitude: 51.531),
        lang: 'en',
      );

      expect(api.updateAddressCalls, 1);
      expect(api.lastAddressId, 3);
      expect(api.lastBody, {
        'kind': 'work',
        'label': 'الشركة',
        'area': 'السد',
        'street': 'شارع 901',
        'building': 'مبنى 40، شقة 5',
        'notes': 'الباب الأخضر',
        'latitude': 25.2854,
        'longitude': 51.531,
      });
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
      expect(response.data?.building, 'مبنى 40، شقة 5');
    });

    test('throws the API message when updating fails', () async {
      api.payload = {'success': false, 'message': 'العنوان غير موجود'};

      expect(
        () => dataSource.updateAddress(
          id: 99,
          kind: AddressKind.home,
          label: '',
          area: 'السد',
          street: 'شارع 901',
          building: 'مبنى 35',
          notes: '',
          point: _qatarPoint,
        ),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'العنوان غير موجود',
          ),
        ),
      );
    });

    test('marks an address as default and sends the language', () async {
      final payload = _addressPayload();
      payload['data']['id'] = 3;
      api.payload = payload;

      final response = await dataSource.setDefaultAddress(id: 3, lang: 'en');

      expect(response.data?.id, 3);
      expect(api.setDefaultCalls, 1);
      expect(api.lastAddressId, 3);
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
    });

    test('throws the API message when setting the default fails', () async {
      api.payload = {'success': false, 'message': 'Unauthorized'};

      expect(
        () => dataSource.setDefaultAddress(id: 3),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'Unauthorized',
          ),
        ),
      );
    });

    test('deletes an address and sends the language', () async {
      await dataSource.deleteAddress(id: 3, lang: 'en');

      expect(api.deleteAddressCalls, 1);
      expect(api.lastAddressId, 3);
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
    });
  });

  group('AddressesRepositoryImpl', () {
    test('wraps a transport error in a server failure', () async {
      final repository = AddressesRepositoryImpl(
        remoteDataSource: _RemoteDataSourceThrows(
          DioException(
            requestOptions: RequestOptions(path: 'addresses'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      final result = await repository.createAddress(
        kind: AddressKind.home,
        label: '',
        area: 'السد',
        street: 'شارع 901',
        building: 'مبنى 35',
        notes: '',
        point: _qatarPoint,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('wraps a transport error when loading addresses', () async {
      final repository = AddressesRepositoryImpl(
        remoteDataSource: _RemoteDataSourceThrows(
          DioException(
            requestOptions: RequestOptions(path: 'addresses'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      final result = await repository.fetchAddresses(lang: 'en');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('wraps a transport error when loading one address', () async {
      final repository = AddressesRepositoryImpl(
        remoteDataSource: _RemoteDataSourceThrows(
          DioException(
            requestOptions: RequestOptions(path: 'addresses/3'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      final result = await repository.fetchAddress(id: 3);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('wraps a transport error when updating an address', () async {
      final repository = AddressesRepositoryImpl(
        remoteDataSource: _RemoteDataSourceThrows(
          DioException(
            requestOptions: RequestOptions(path: 'addresses/3'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      final result = await repository.updateAddress(
        id: 3,
        kind: AddressKind.home,
        label: '',
        area: 'السد',
        street: 'شارع 901',
        building: 'مبنى 35',
        notes: '',
        point: _qatarPoint,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('wraps a transport error when setting the default', () async {
      final repository = AddressesRepositoryImpl(
        remoteDataSource: _RemoteDataSourceThrows(
          DioException(
            requestOptions: RequestOptions(path: 'addresses/3/default'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      final result = await repository.setDefaultAddress(id: 3);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('wraps a transport error when deleting an address', () async {
      final repository = AddressesRepositoryImpl(
        remoteDataSource: _RemoteDataSourceThrows(
          DioException(
            requestOptions: RequestOptions(path: 'addresses/3'),
            type: DioExceptionType.badResponse,
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: 'addresses/3'),
              statusCode: 404,
              data: {'message': 'عنوان غير موجود.'},
            ),
          ),
        ),
      );

      final result = await repository.deleteAddress(id: 3);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(
          failure,
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'عنوان غير موجود.',
          ),
        ),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('AddAddressCubit', () {
    late _FakeAddressesRepository repository;
    late _FakeLocationRepository location;
    late AddAddressCubit cubit;

    setUp(() {
      repository = _FakeAddressesRepository()..result = Right(_address());
      location = _FakeLocationRepository()..result = const Right(_qatarPoint);
      cubit = AddAddressCubit(repository, location, lang: 'en');
    });

    tearDown(() => cubit.close());

    test('selects the address kind', () async {
      expect(cubit.state.kind, AddressKind.home);

      cubit.selectKind(AddressKind.work);

      expect(cubit.state.kind, AddressKind.work);
    });

    test('saves inside Qatar and emits the created address', () async {
      cubit.selectKind(AddressKind.work);

      await cubit.save(
        point: _qatarPoint,
        label: 'البيت',
        area: 'السد',
        street: 'شارع 901',
        building: 'مبنى 35',
        notes: '',
      );

      expect(cubit.state.isSuccess, isTrue);
      expect(cubit.state.createdAddress?.id, 1);
      expect(repository.calls, 1);
      expect(repository.lastKind, AddressKind.work);
      expect(repository.lastLang, 'en');
      expect(repository.lastPoint, _qatarPoint);
    });

    test('updates the existing address in edit mode', () async {
      final updated = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'kind': 'work',
          'building': 'مبنى 40، شقة 5',
        },
      }).toEntity()!;
      repository.updateResult = Right(updated);

      cubit.startEditing(_address());
      cubit.selectKind(AddressKind.work);

      await cubit.save(
        point: _qatarPoint,
        label: 'الشركة',
        area: 'السد',
        street: 'شارع 901',
        building: 'مبنى 40، شقة 5',
        notes: '',
      );

      expect(cubit.state.isSuccess, isTrue);
      expect(cubit.state.createdAddress?.building, 'مبنى 40، شقة 5');
      expect(repository.updateCalls, 1);
      expect(repository.calls, 0);
      expect(repository.lastUpdateId, 1);
      expect(repository.lastKind, AddressKind.work);
      expect(repository.lastArea, 'السد');
    });

    test('rejects points outside Qatar without calling the API', () async {
      await cubit.save(
        point: _dubaiPoint,
        label: '',
        area: 'دبي',
        street: '',
        building: '',
        notes: '',
      );

      expect(cubit.state.status, AddAddressStatus.failure);
      expect(cubit.state.outsideQatar, isTrue);
      expect(repository.calls, 0);
    });

    test('emits the API message when saving fails', () async {
      repository.result = Left(ServerFailure('خارج نطاق التوصيل'));

      await cubit.save(
        point: _qatarPoint,
        area: 'السد',
        street: 'شارع 901',
        building: 'مبنى 35',
        label: '',
        notes: '',
      );

      expect(cubit.state.status, AddAddressStatus.failure);
      expect(cubit.state.errorMessage, 'خارج نطاق التوصيل');
      expect(cubit.state.outsideQatar, isFalse);
    });

    test('moves the map to the device location', () async {
      await cubit.useCurrentLocation();

      expect(cubit.state.focusPoint, _qatarPoint);
      expect(cubit.state.focusRequest, 1);
      expect(cubit.state.status, AddAddressStatus.initial);

      await cubit.useCurrentLocation();

      expect(cubit.state.focusRequest, 2);
    });

    test(
      'surfaces the location issue when the device location fails',
      () async {
        location.result = Left(LocationFailure(LocationIssue.permissionDenied));

        await cubit.useCurrentLocation();

        expect(cubit.state.status, AddAddressStatus.failure);
        expect(cubit.state.locationIssue, LocationIssue.permissionDenied);
        expect(cubit.state.focusPoint, isNull);
      },
    );
  });

  group('AddressListCubit', () {
    late _FakeAddressesRepository repository;
    late AddressListCubit cubit;

    setUp(() {
      repository = _FakeAddressesRepository()
        ..fetchResult = Right([_address()]);
      cubit = AddressListCubit(repository, lang: 'en');
    });

    tearDown(() => cubit.close());

    test('emits loading then the saved addresses', () async {
      final loading = cubit.load();
      expect(cubit.state.isLoading, isTrue);

      await loading;

      expect(cubit.state.status, AddressListStatus.success);
      expect(cubit.state.addresses, hasLength(1));
      expect(cubit.state.addresses.single.id, 1);
      expect(repository.fetchCalls, 1);
      expect(repository.lastLang, 'en');
    });

    test('emits the API message when loading fails', () async {
      repository.fetchResult = Left(ServerFailure('Unauthorized'));

      await cubit.load();

      expect(cubit.state.status, AddressListStatus.failure);
      expect(cubit.state.errorMessage, 'Unauthorized');
      expect(cubit.state.hasAddresses, isFalse);
    });

    test('keeps the loaded addresses when a later load fails', () async {
      await cubit.load();
      repository.fetchResult = Left(ServerFailure('offline'));

      await cubit.load();

      expect(cubit.state.status, AddressListStatus.failure);
      expect(cubit.state.hasAddresses, isTrue);
      expect(cubit.state.errorMessage, 'offline');
    });

    test('adopts the is_default flag returned by the list', () async {
      final flagged = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'id': 3,
          'is_default': true,
        },
      }).toEntity()!;
      repository.fetchResult = Right([flagged, _address()]);

      await cubit.load();

      expect(cubit.state.defaultAddressId, 3);
      expect(cubit.state.isDefault(3), isTrue);
      expect(cubit.state.isDefault(1), isFalse);
    });

    test('sets the default address and keeps the list', () async {
      final second = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'id': 3,
          'label': 'الشركة',
        },
      }).toEntity()!;
      repository.fetchResult = Right([second, _address()]);
      await cubit.load();

      final updated = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'id': 3,
          'label': 'الشركة',
        },
      }).toEntity()!;
      repository.defaultResult = Right(updated);

      await cubit.setDefault(3);

      expect(repository.setDefaultCalls, 1);
      expect(repository.lastDefaultId, 3);
      expect(repository.lastLang, 'en');
      expect(cubit.state.defaultAddressId, 3);
      expect(cubit.state.isDefault(3), isTrue);
      expect(cubit.state.settingDefaultId, isNull);
      expect(cubit.state.addresses, hasLength(2));
      expect(cubit.state.defaultError, isNull);
    });

    test('emits the API message when setting the default fails', () async {
      await cubit.load();
      repository.defaultResult = Left(ServerFailure('Unauthorized'));

      await cubit.setDefault(1);

      expect(cubit.state.defaultAddressId, isNull);
      expect(cubit.state.settingDefaultId, isNull);
      expect(cubit.state.defaultError, 'Unauthorized');
      expect(cubit.state.addresses, hasLength(1));
    });

    test('deletes an address and removes it from the list', () async {
      final second = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'id': 3,
          'label': 'الشركة',
          'is_default': true,
        },
      }).toEntity()!;
      repository.fetchResult = Right([second, _address()]);

      await cubit.load();
      expect(cubit.state.defaultAddressId, 3);

      await cubit.deleteAddress(3);

      expect(repository.deleteCalls, 1);
      expect(repository.lastDeleteId, 3);
      expect(repository.lastLang, 'en');
      expect(cubit.state.addresses.map((address) => address.id), [1]);
      expect(cubit.state.defaultAddressId, isNull);
      expect(cubit.state.deletingAddressId, isNull);
      expect(cubit.state.deleteError, isNull);
    });

    test(
      'keeps the list and emits the API message when deleting fails',
      () async {
        await cubit.load();
        repository.deleteResult = Left(ServerFailure('عنوان غير موجود.'));

        await cubit.deleteAddress(1);

        expect(cubit.state.addresses, hasLength(1));
        expect(cubit.state.deletingAddressId, isNull);
        expect(cubit.state.deleteError, 'عنوان غير موجود.');
      },
    );
  });

  group('AddressDetailsCubit', () {
    late _FakeAddressesRepository repository;
    late AddressDetailsCubit cubit;

    setUp(() {
      repository = _FakeAddressesRepository()
        ..detailsResult = Right(_address());
      cubit = AddressDetailsCubit(repository, addressId: 3, lang: 'en');
    });

    tearDown(() => cubit.close());

    test('emits loading then the address', () async {
      final loading = cubit.load();

      expect(cubit.state.isLoading, isTrue);

      await loading;

      expect(cubit.state.status, AddressDetailsStatus.success);
      expect(cubit.state.address?.id, 1);
      expect(cubit.state.hasError, isFalse);
      expect(repository.fetchAddressCalls, 1);
      expect(repository.lastAddressId, 3);
      expect(repository.lastLang, 'en');
    });

    test('emits the API message when loading fails', () async {
      repository.detailsResult = Left(ServerFailure('العنوان غير موجود'));

      await cubit.load();

      expect(cubit.state.status, AddressDetailsStatus.failure);
      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.address, isNull);
      expect(cubit.state.errorMessage, 'العنوان غير موجود');
    });

    test('applies an edited address without reloading', () async {
      await cubit.load();
      final edited = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'building': 'مبنى 40، شقة 5',
        },
      }).toEntity()!;

      cubit.applyAddress(edited);

      expect(cubit.state.address?.building, 'مبنى 40، شقة 5');
      expect(repository.fetchAddressCalls, 1);
    });

    test('deletes the address and marks it as deleted', () async {
      await cubit.load();

      await cubit.deleteAddress();

      expect(repository.deleteCalls, 1);
      expect(repository.lastDeleteId, 3);
      expect(repository.lastLang, 'en');
      expect(cubit.state.isDeleted, isTrue);
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.deleteError, isNull);
    });

    test('emits the API message when deleting fails', () async {
      await cubit.load();
      repository.deleteResult = Left(ServerFailure('عنوان غير موجود.'));

      await cubit.deleteAddress();

      expect(cubit.state.isDeleted, isFalse);
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.deleteError, 'عنوان غير موجود.');
      expect(cubit.state.address, isNotNull);
    });
  });

  group('AddressKindSelector', () {
    testWidgets('reports the tapped kind', (tester) async {
      AddressKind? selected;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressKindSelector(
              selected: AddressKind.home,
              onChanged: (kind) => selected = kind,
            ),
          ),
        ),
      );

      await tester.tap(find.text('العمل'));
      await tester.pumpAndSettle();

      expect(selected, AddressKind.work);
    });
  });

  group('AddressFormFields', () {
    testWidgets('requires the area, street and building', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controllers = List.generate(5, (_) => TextEditingController());
      addTearDown(() {
        for (final controller in controllers) {
          controller.dispose();
        }
      });

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: AddressFormFields(
                  labelController: controllers[0],
                  areaController: controllers[1],
                  streetController: controllers[2],
                  buildingController: controllers[3],
                  notesController: controllers[4],
                ),
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AddressFormFields)),
      )!;
      expect(find.text(l10n.addressAreaRequired), findsOneWidget);
      expect(find.text(l10n.addressStreetRequired), findsOneWidget);
      expect(find.text(l10n.addressBuildingRequired), findsOneWidget);

      controllers[1].text = 'السد';
      controllers[2].text = 'شارع 901';
      controllers[3].text = 'مبنى 35، الطابق 2';

      expect(formKey.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text(l10n.addressAreaRequired), findsNothing);
    });
  });

  group('AddAddressScreen', () {
    Widget buildScreen() {
      return _app(
        BlocProvider<AddAddressCubit>(
          create: (_) => AddAddressCubit(
            _FakeAddressesRepository(),
            _FakeLocationRepository(),
          ),
          child: const AddAddressScreen(),
        ),
      );
    }

    testWidgets('renders the map, kind selector and fields', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('أضف عنوانًا جديدًا'), findsOneWidget);
      expect(find.text('المنزل'), findsOneWidget);
      expect(find.text('اسم العنوان (اختياري)'), findsOneWidget);
      expect(find.text('حفظ العنوان'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps a wide layout free of overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('حفظ العنوان'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('prefills the form when editing an address', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repository = _FakeAddressesRepository();
      final cubit = AddAddressCubit(
        repository,
        _FakeLocationRepository(),
        lang: 'ar',
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        _app(
          BlocProvider<AddAddressCubit>.value(
            value: cubit,
            child: AddAddressScreen(existingAddress: _address()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('تعديل العنوان'), findsOneWidget);
      expect(find.text('حفظ التعديلات'), findsOneWidget);

      final values = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((widget) => widget.controller.text)
          .toList();
      expect(
        values,
        containsAll(<String>[
          'البيت',
          'السد',
          'شارع 901',
          'مبنى 35، الطابق 2',
          'الباب الأخضر',
        ]),
      );
      expect(find.text('25.28540, 51.53100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AddressDetailsScreen', () {
    Widget buildDetails(
      _FakeAddressesRepository repository, {
      bool load = true,
    }) {
      final cubit = AddressDetailsCubit(repository, addressId: 3, lang: 'ar');
      addTearDown(cubit.close);
      if (load) cubit.load();

      return _app(
        BlocProvider<AddressDetailsCubit>.value(
          value: cubit,
          child: const AddressDetailsScreen(),
        ),
      );
    }

    testWidgets('shows the loaded address and the edit action', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repository = _FakeAddressesRepository()
        ..detailsResult = Right(_address());

      await tester.pumpWidget(buildDetails(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('تفاصيل العنوان'), findsOneWidget);
      expect(find.text('بيانات العنوان'), findsOneWidget);
      expect(find.text('البيت'), findsOneWidget);
      expect(find.text('السد'), findsOneWidget);
      expect(find.text('شارع 901'), findsOneWidget);
      expect(find.text('مبنى 35، الطابق 2'), findsOneWidget);
      expect(find.text('تعديل العنوان'), findsOneWidget);
      expect(find.text('حذف العنوان'), findsOneWidget);
      expect(find.text('المنزل'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the failure state and retries', (tester) async {
      final repository = _FakeAddressesRepository()
        ..detailsResult = Left(ServerFailure(''));

      await tester.pumpWidget(buildDetails(repository));
      await tester.pump();
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AddressDetailsScreen)),
      )!;
      expect(find.text(l10n.addressDetailsError), findsOneWidget);
      expect(find.text(l10n.retry), findsOneWidget);

      repository.detailsResult = Right(_address());
      await tester.tap(find.text(l10n.retry));
      await tester.pump();
      await tester.pump();

      expect(find.text('البيت'), findsOneWidget);
      expect(find.text(l10n.addressDetailsError), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps a wide layout free of overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final repository = _FakeAddressesRepository()
        ..detailsResult = Right(_address());

      await tester.pumpWidget(buildDetails(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('البيت'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AddressCard', () {
    testWidgets('opens the details and edit actions from the menu', (
      tester,
    ) async {
      var detailsTaps = 0;
      var editTaps = 0;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              onTap: () {},
              onDetails: () => detailsTaps++,
              onEdit: () => editTaps++,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      expect(find.text('عرض التفاصيل'), findsOneWidget);
      expect(find.text('تعديل العنوان'), findsOneWidget);

      await tester.tap(find.text('عرض التفاصيل'));
      await tester.pumpAndSettle();
      expect(detailsTaps, 1);
      expect(editTaps, 0);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تعديل العنوان'));
      await tester.pumpAndSettle();
      expect(detailsTaps, 1);
      expect(editTaps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the menu when no action is wired', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sets the address as default from the menu', (tester) async {
      var defaultTaps = 0;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              onTap: () {},
              onSetDefault: () => defaultTaps++,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      expect(find.text('تعيين كافتراضي'), findsOneWidget);

      await tester.tap(find.text('تعيين كافتراضي'));
      await tester.pumpAndSettle();

      expect(defaultTaps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sets the address as default from the checkbox', (
      tester,
    ) async {
      var defaultTaps = 0;
      var cardTaps = 0;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              onTap: () => cardTaps++,
              onSetDefault: () => defaultTaps++,
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(defaultTaps, 1);
      expect(cardTaps, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('marks the default address and hides the action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              isDefault: true,
              onTap: () {},
              onSetDefault: () {},
            ),
          ),
        ),
      );

      expect(find.text('افتراضي'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      expect(find.text('تعيين كافتراضي'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('deletes the address from the menu', (tester) async {
      var deleteTaps = 0;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              onTap: () {},
              onDelete: () => deleteTaps++,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      expect(find.text('حذف العنوان'), findsOneWidget);

      await tester.tap(find.text('حذف العنوان'));
      await tester.pumpAndSettle();

      expect(deleteTaps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a spinner while the default is being saved', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: AddressCard(
              address: _address(),
              selected: false,
              isSettingDefault: true,
              onTap: () {},
              onSetDefault: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('AddressSelectionScreen', () {
    Widget buildSelection(
      _FakeAddressesRepository repository, {
      int? selectedAddressId,
    }) {
      final cubit = AddressListCubit(repository, lang: 'ar');
      addTearDown(cubit.close);
      cubit.load();

      return _app(
        BlocProvider<AddressListCubit>.value(
          value: cubit,
          child: AddressSelectionScreen(selectedAddressId: selectedAddressId),
        ),
      );
    }

    _FakeAddressesRepository repositoryWith(List<Address> addresses) {
      return _FakeAddressesRepository()..fetchResult = Right(addresses);
    }

    testWidgets('lists the saved addresses and the add option', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final first = _address();
      final second = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'id': 3,
          'label': 'الشركة',
          'title': 'الشركة',
        },
      }).toEntity()!;

      await tester.pumpWidget(
        buildSelection(repositoryWith([second, first]), selectedAddressId: 3),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('اختر عنوان التوصيل'), findsOneWidget);
      expect(find.text('العناوين المحفوظة'), findsOneWidget);
      expect(find.text('الشركة'), findsOneWidget);
      expect(find.text('البيت'), findsOneWidget);
      expect(find.text('أضف عنوانًا جديدًا'), findsOneWidget);
      expect(find.byKey(const ValueKey('address-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('address-1')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the empty state when nothing is saved', (tester) async {
      await tester.pumpWidget(buildSelection(repositoryWith(const [])));
      await tester.pump();
      await tester.pump();

      expect(find.text('لم تحفظ أي عنوان بعد.'), findsOneWidget);
      expect(find.text('أضف عنوانًا جديدًا'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the failure state and retries', (tester) async {
      final repository = _FakeAddressesRepository()
        ..fetchResult = Left(ServerFailure(''));

      await tester.pumpWidget(buildSelection(repository));
      await tester.pump();
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AddressSelectionScreen)),
      )!;
      expect(find.text(l10n.addressListError), findsOneWidget);
      expect(find.text(l10n.retry), findsOneWidget);

      repository.fetchResult = Right([_address()]);
      await tester.tap(find.text(l10n.retry));
      await tester.pump();
      await tester.pump();

      expect(find.text('البيت'), findsOneWidget);
      expect(find.text(l10n.addressListError), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps a wide layout free of overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildSelection(repositoryWith([_address()])));
      await tester.pump();
      await tester.pump();

      expect(find.text('البيت'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sets a saved address as the default from its checkbox', (
      tester,
    ) async {
      final repository = repositoryWith([_address()]);

      await tester.pumpWidget(buildSelection(repository));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      await tester.pump();

      expect(repository.setDefaultCalls, 1);
      expect(repository.lastDefaultId, 1);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(find.text('افتراضي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('deletes a saved address after confirmation', (tester) async {
      final repository = repositoryWith([_address()]);

      await tester.pumpWidget(buildSelection(repository));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف العنوان'));
      await tester.pumpAndSettle();

      expect(find.text('حذف العنوان؟'), findsOneWidget);
      expect(find.textContaining('البيت'), findsWidgets);

      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();

      expect(repository.deleteCalls, 1);
      expect(repository.lastDeleteId, 1);
      expect(find.text('البيت'), findsNothing);
      expect(find.text('لم تحفظ أي عنوان بعد.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the address when deleting fails', (tester) async {
      final repository = repositoryWith([_address()])
        ..deleteResult = Left(ServerFailure(''));

      await tester.pumpWidget(buildSelection(repository));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف العنوان'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AddressSelectionScreen)),
      )!;
      expect(find.text(l10n.addressDeleteError), findsOneWidget);
      expect(find.text('البيت'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pre-selects the default address', (tester) async {
      final flagged = AddressResponse.fromJson({
        'data': {
          ...(_addressPayload()['data'] as Map<String, dynamic>),
          'id': 3,
          'label': 'الشركة',
          'title': 'الشركة',
          'is_default': true,
        },
      }).toEntity()!;
      final repository = repositoryWith([flagged, _address()]);

      await tester.pumpWidget(buildSelection(repository));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      final checkboxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList(growable: false);
      expect(checkboxes.map((checkbox) => checkbox.value), [true, false]);
      expect(find.text('افتراضي'), findsOneWidget);

      final defaultCard = find.ancestor(
        of: find.text('الشركة'),
        matching: find.byType(AddressCard),
      );
      expect(
        find.descendant(
          of: defaultCard,
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'keeps the current delivery address selected over the default',
      (tester) async {
        final flagged = AddressResponse.fromJson({
          'data': {
            ...(_addressPayload()['data'] as Map<String, dynamic>),
            'id': 3,
            'label': 'الشركة',
            'title': 'الشركة',
            'is_default': true,
          },
        }).toEntity()!;
        final repository = repositoryWith([flagged, _address()]);

        await tester.pumpWidget(
          buildSelection(repository, selectedAddressId: 1),
        );
        await tester.pump();
        await tester.pump();

        final currentCard = find.ancestor(
          of: find.text('البيت'),
          matching: find.byType(AddressCard),
        );
        expect(
          find.descendant(
            of: currentCard,
            matching: find.byIcon(Icons.check_circle_rounded),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('fits a small phone at 2x text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(() {
        tester.view.reset();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      await tester.pumpWidget(buildSelection(repositoryWith([_address()])));
      await tester.pump();
      await tester.pump();

      expect(find.text('أضف عنوانًا جديدًا'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('البيت'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('البيت'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('returns the tapped address to the caller', (tester) async {
      final repository = repositoryWith([_address()]);
      final cubit = AddressListCubit(repository, lang: 'ar')..load();
      addTearDown(cubit.close);
      Address? picked;

      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    picked = await Navigator.of(context).push<Address>(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<AddressListCubit>.value(
                          value: cubit,
                          child: const AddressSelectionScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('البيت'));
      await tester.pumpAndSettle();

      expect(picked?.id, 1);
      expect(tester.takeException(), isNull);
    });
  });
}

class _RemoteDataSourceThrows implements AddressesRemoteDataSource {
  _RemoteDataSourceThrows(this.error);

  final Object error;

  @override
  Future<List<Address>> fetchAddresses({String lang = 'ar'}) async {
    throw error;
  }

  @override
  Future<AddressResponse> fetchAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw error;
  }

  @override
  Future<AddressResponse> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    throw error;
  }

  @override
  Future<AddressResponse> updateAddress({
    required int id,
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    throw error;
  }

  @override
  Future<AddressResponse> setDefaultAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw error;
  }

  @override
  Future<void> deleteAddress({required int id, String lang = 'ar'}) async {
    throw error;
  }
}

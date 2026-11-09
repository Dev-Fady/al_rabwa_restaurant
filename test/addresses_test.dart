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
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/add_address_screen.dart';
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

class _FakeApiService implements ApiService {
  _FakeApiService({required this.payload});

  dynamic payload;
  Object? error;
  Map<String, dynamic>? lastBody;
  String? lastLang;
  String? lastLocale;

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressesRepository implements AddressesRepository {
  Either<Failure, Address>? result;
  int calls = 0;
  AddressKind? lastKind;
  GeoPoint? lastPoint;
  String? lastLang;
  String? lastArea;

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
  });
}

class _RemoteDataSourceThrows implements AddressesRemoteDataSource {
  _RemoteDataSourceThrows(this.error);

  final Object error;

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
}

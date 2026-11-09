import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/registration/data/datasources/device_registration_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/registration/data/models/device_registration_response.dart';
import 'package:al_rabwa_restaurant/features/registration/data/repositories/device_registration_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/registration/domain/entities/device_session.dart';
import 'package:al_rabwa_restaurant/features/registration/domain/repositories/device_registration_repository.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_cubit.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_state.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/screens/device_registration_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeRepository implements DeviceRegistrationRepository {
  _FakeRepository({this.result, this.error});

  Either<Failure, DeviceSession>? result;
  Object? error;
  int calls = 0;
  String? lastName;
  String? lastPhone;
  String? lastLocale;

  @override
  Future<Either<Failure, DeviceSession>> registerDevice({
    required String name,
    required String phone,
    required String locale,
  }) async {
    calls++;
    lastName = name;
    lastPhone = phone;
    lastLocale = locale;

    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return result!;
  }
}

class _FakeRemoteDataSource implements DeviceRegistrationRemoteDataSource {
  _FakeRemoteDataSource({this.response, this.error});

  DeviceRegistrationResponse? response;
  Object? error;

  @override
  Future<DeviceRegistrationResponse> registerDevice({
    required String name,
    required String phone,
    required String locale,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return response!;
  }
}

class _FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> values = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

const _device = DeviceModel(
  id: 17,
  name: 'جودة',
  phone: '+974 555 1234',
  locale: 'ar',
);

const _session = DeviceSession(
  token: 'test-token',
  id: 17,
  name: 'جودة',
  phone: '+974 555 1234',
  locale: 'ar',
);

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
  ValueChanged<String>? onLocaleChanged,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = DeviceRegistrationCubit(repository);
  addTearDown(cubit.close);

  final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider.value(
          value: cubit,
          child: DeviceRegistrationScreen(onLocaleChanged: onLocaleChanged),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('home-screen')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DeviceRegistrationCubit', () {
    test('starts in the initial state', () {
      final cubit = DeviceRegistrationCubit(_FakeRepository());

      expect(cubit.state.status, DeviceRegistrationStatus.initial);
      expect(cubit.state.session, isNull);
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('emits submitting then success with the registered session', () async {
      final repository = _FakeRepository(result: const Right(_session));
      final cubit = DeviceRegistrationCubit(repository);

      final future = cubit.register(
        name: 'جودة',
        phone: '+974 555 1234',
        locale: 'ar',
      );

      expect(cubit.state.status, DeviceRegistrationStatus.submitting);
      await future;

      expect(cubit.state.status, DeviceRegistrationStatus.success);
      expect(cubit.state.session?.token, 'test-token');
      expect(cubit.state.errorMessage, isNull);
      expect(repository.lastName, 'جودة');
      expect(repository.lastPhone, '+974 555 1234');
      expect(repository.lastLocale, 'ar');

      await cubit.close();
    });

    test('emits failure with the repository message', () async {
      final repository = _FakeRepository(
        error: ServerFailure('تعذر تسجيل الجهاز'),
      );
      final cubit = DeviceRegistrationCubit(repository);

      await cubit.register(name: 'جودة', phone: '12345678', locale: 'ar');

      expect(cubit.state.status, DeviceRegistrationStatus.failure);
      expect(cubit.state.errorMessage, 'تعذر تسجيل الجهاز');
      expect(cubit.state.session, isNull);

      await cubit.close();
    });
  });

  group('DeviceRegistrationRepository', () {
    test('stores the returned token on success', () async {
      final storage = _FakeSecureStorage();
      final repository = DeviceRegistrationRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(
          response: const DeviceRegistrationResponse(
            data: _device,
            token: 'test-token',
          ),
        ),
        secureStorage: storage,
      );

      final result = await repository.registerDevice(
        name: 'جودة',
        phone: '+974 555 1234',
        locale: 'ar',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected a registered session'),
        (session) => expect(session.token, 'test-token'),
      );
      expect(storage.values['access_token'], 'test-token');
    });

    test('maps a remote failure without storing a token', () async {
      final storage = _FakeSecureStorage();
      final repository = DeviceRegistrationRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(
          error: ServerFailure('تعذر الاتصال'),
        ),
        secureStorage: storage,
      );

      final result = await repository.registerDevice(
        name: 'جودة',
        phone: '+974 555 1234',
        locale: 'ar',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'تعذر الاتصال'),
        (_) => fail('expected a failure'),
      );
      expect(storage.values, isEmpty);
    });

    test('rejects a response without a token', () async {
      final storage = _FakeSecureStorage();
      final repository = DeviceRegistrationRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(
          response: const DeviceRegistrationResponse(data: _device),
        ),
        secureStorage: storage,
      );

      final result = await repository.registerDevice(
        name: 'جودة',
        phone: '+974 555 1234',
        locale: 'ar',
      );

      expect(result.isLeft(), isTrue);
      expect(storage.values, isEmpty);
    });
  });

  group('DeviceRegistrationScreen', () {
    testWidgets('validates the name and phone before submitting', (
      tester,
    ) async {
      final repository = _FakeRepository(result: const Right(_session));
      await _pumpScreen(tester, repository: repository);

      await tester.tap(find.text('ابدأ الطلب'));
      await tester.pumpAndSettle();

      expect(find.text('يرجى إدخال اسمك.'), findsOneWidget);
      expect(find.text('يرجى إدخال رقم هاتفك.'), findsOneWidget);
      expect(repository.calls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('submits valid details and opens the home screen', (
      tester,
    ) async {
      final repository = _FakeRepository(result: const Right(_session));
      await _pumpScreen(tester, repository: repository);

      await tester.enterText(find.byType(TextFormField).at(0), 'جودة');
      await tester.enterText(find.byType(TextFormField).at(1), '+974 555 1234');
      await tester.tap(find.text('ابدأ الطلب'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repository.calls, 1);
      expect(repository.lastName, 'جودة');
      expect(repository.lastPhone, '+974 555 1234');
      expect(repository.lastLocale, 'ar');
      expect(find.text('home-screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the backend error and stays on the form', (
      tester,
    ) async {
      final repository = _FakeRepository(
        error: ServerFailure('تعذر تسجيل الجهاز'),
      );
      await _pumpScreen(tester, repository: repository);

      await tester.enterText(find.byType(TextFormField).at(0), 'جودة');
      await tester.enterText(find.byType(TextFormField).at(1), '+974 555 1234');
      await tester.tap(find.text('ابدأ الطلب'));
      await tester.pumpAndSettle();

      expect(find.text('تعذر تسجيل الجهاز'), findsOneWidget);
      expect(find.text('home-screen'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone at 2x text scale', (tester) async {
      final repository = _FakeRepository(result: const Right(_session));
      await _pumpScreen(
        tester,
        repository: repository,
        size: const Size(320, 640),
        textScale: 2,
      );

      expect(find.text('ابدأ الطلب'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a two-column layout on wide screens', (tester) async {
      final repository = _FakeRepository(result: const Right(_session));
      await _pumpScreen(
        tester,
        repository: repository,
        size: const Size(1280, 900),
      );

      expect(find.text('ابدأ الطلب'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

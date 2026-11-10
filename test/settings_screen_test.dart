import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/domain/repositories/account_repository.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/delete_my_data_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/screens/settings_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/settings_fixtures.dart';

class _FakeRepository implements SettingsRepository {
  _FakeRepository({this.result, this.error});

  RestaurantSettings? result;
  Object? error;

  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(result!);
  }
}

class _FakeAccountRepository implements AccountRepository {
  _FakeAccountRepository({this.result});

  Either<Failure, Unit>? result;
  int deleteCalls = 0;

  @override
  Future<Either<Failure, Unit>> deleteMyData() async {
    deleteCalls++;
    return result ?? Right(unit);
  }
}

RestaurantSettings _syncSettings({
  bool enabled = true,
  bool acceptingOrdersNow = true,
  Map<String, dynamic>? workingHours = const {'from': '10:13', 'to': '22:14'},
  String closedMessage = '',
  StoreContact? contact,
}) {
  final base = sampleSettingsWithoutImages();
  return base.copyWith(
    restaurant: base.restaurant.copyWith(
      name: 'مطعم سينك',
      tagline: 'طعم يجمعنا',
      logo: '',
    ),
    ordering: OrderingSettings(
      enabled: enabled,
      acceptingOrdersNow: acceptingOrdersNow,
      closedMessage: closedMessage,
      orderTypes: base.ordering.orderTypes,
      paymentMethods: base.ordering.paymentMethods,
      workingHours: workingHours ?? const {},
    ),
    contact: contact ?? base.contact,
  );
}

Future<StoreConfigCubit> _pumpStore(
  WidgetTester tester, {
  required _FakeRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
  SettingsCubit? settingsCubit,
  DeleteMyDataCubit? deleteCubit,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = StoreConfigCubit(repository);
  addTearDown(cubit.close);
  final settings = settingsCubit ?? SettingsCubit();
  if (settingsCubit == null) addTearDown(settings.close);
  final delete = deleteCubit ?? DeleteMyDataCubit(_FakeAccountRepository());
  if (deleteCubit == null) addTearDown(delete.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: settings),
        BlocProvider.value(value: delete),
      ],
      child: MaterialApp(
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
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
  return cubit;
}

void main() {
  testWidgets('renders the restaurant identity, hours and menu language', (
    tester,
  ) async {
    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
    );

    expect(find.text('مطعم سينك'), findsOneWidget);
    expect(find.text('طعم يجمعنا'), findsOneWidget);
    expect(find.text('أوقات العمل'), findsOneWidget);
    expect(find.text('10:13 – 22:14'), findsOneWidget);
    expect(find.text('مفتوح الآن'), findsOneWidget);
    expect(find.text('لغة المنيو'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('تواصل معنا'), findsOneWidget);
    expect(find.text('لا توجد بيانات تواصل متاحة حالياً.'), findsOneWidget);
    expect(find.text('بدعم من SmartMenues'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching the language updates the app locale', (tester) async {
    final settingsCubit = SettingsCubit();
    addTearDown(settingsCubit.close);

    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
      settingsCubit: settingsCubit,
    );

    await tester.tap(find.text('English'));
    await tester.pump();

    expect(settingsCubit.state.locale.languageCode, 'en');
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the closed state with the configured message', (
    tester,
  ) async {
    await _pumpStore(
      tester,
      repository: _FakeRepository(
        result: _syncSettings(
          enabled: false,
          acceptingOrdersNow: false,
          closedMessage: 'نستقبلكم قريبًا',
        ),
      ),
    );

    expect(find.text('10:13 – 22:14'), findsOneWidget);
    expect(find.text('نستقبلكم قريبًا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lists every contact value the backend provides', (tester) async {
    await _pumpStore(
      tester,
      repository: _FakeRepository(
        result: _syncSettings(
          contact: const StoreContact(
            phone: '+974 5551 2345',
            whatsapp: '97455512345',
            instagram: '@sync2027',
            facebook: 'sync2027',
            location: 'الدوحة، قطر',
          ),
        ),
      ),
    );

    expect(find.text('تواصل معنا'), findsOneWidget);
    expect(find.text('الهاتف'), findsOneWidget);
    expect(find.text('+974 5551 2345'), findsOneWidget);
    expect(find.text('واتساب'), findsOneWidget);
    expect(find.text('97455512345'), findsOneWidget);
    expect(find.text('إنستغرام'), findsOneWidget);
    expect(find.text('@sync2027'), findsOneWidget);
    expect(find.text('فيسبوك'), findsOneWidget);
    expect(find.text('sync2027'), findsOneWidget);
    expect(find.text('الموقع'), findsOneWidget);
    expect(find.text('الدوحة، قطر'), findsOneWidget);
    expect(find.text('لا توجد بيانات تواصل متاحة حالياً.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete-my-data action asks for confirmation first', (
    tester,
  ) async {
    final account = _FakeAccountRepository();
    final deleteCubit = DeleteMyDataCubit(account);
    addTearDown(deleteCubit.close);

    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
      deleteCubit: deleteCubit,
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byTooltip('حذف بياناتي'), findsOneWidget);

    await tester.tap(find.byTooltip('حذف بياناتي'));
    await tester.pumpAndSettle();

    expect(find.text('حذف بياناتي؟'), findsOneWidget);
    expect(account.deleteCalls, 0);

    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(find.text('حذف بياناتي؟'), findsNothing);
    expect(account.deleteCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirming deletes the device data and reports success', (
    tester,
  ) async {
    final account = _FakeAccountRepository();
    final deleteCubit = DeleteMyDataCubit(account);
    addTearDown(deleteCubit.close);

    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
      deleteCubit: deleteCubit,
    );

    await tester.tap(find.byTooltip('حذف بياناتي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف البيانات'));
    await tester.pumpAndSettle();

    expect(account.deleteCalls, 1);
    expect(deleteCubit.state.isDeleted, isTrue);
    expect(find.text('تم حذف بياناتك بنجاح.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the localized error when deletion fails', (tester) async {
    final account = _FakeAccountRepository(result: Left(ServerFailure('')));
    final deleteCubit = DeleteMyDataCubit(account);
    addTearDown(deleteCubit.close);

    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
      deleteCubit: deleteCubit,
    );

    await tester.tap(find.byTooltip('حذف بياناتي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف البيانات'));
    await tester.pumpAndSettle();

    expect(account.deleteCalls, 1);
    expect(
      find.text('تعذّر حذف بياناتك، يرجى المحاولة مرة أخرى.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides working hours when the backend has none', (tester) async {
    await _pumpStore(
      tester,
      repository: _FakeRepository(
        result: _syncSettings(
          enabled: false,
          acceptingOrdersNow: false,
          workingHours: null,
        ),
      ),
    );

    expect(find.text('أوقات العمل'), findsNothing);
    expect(find.text('لغة المنيو'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the failure state and recovers on retry', (tester) async {
    final repository = _FakeRepository(error: Exception('offline'));
    await _pumpStore(tester, repository: repository);

    expect(
      find.text('تعذر تحميل بيانات المطعم، تحقق من اتصالك وحاول مرة أخرى.'),
      findsOneWidget,
    );
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    repository.error = null;
    repository.result = _syncSettings();
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('مطعم سينك'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a small phone at 2x text scale without overflow', (
    tester,
  ) async {
    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.text('مطعم سينك'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('العربية'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تواصل معنا'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('تواصل معنا'), findsOneWidget);
    expect(find.text('لا توجد بيانات تواصل متاحة حالياً.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers the content on wide screens', (tester) async {
    await _pumpStore(
      tester,
      repository: _FakeRepository(result: _syncSettings()),
      size: const Size(1280, 900),
    );

    final contentWidth = tester
        .getSize(find.byKey(const ValueKey('store-content')))
        .width;
    expect(contentWidth, lessThanOrEqualTo(460));
    expect(find.text('مطعم سينك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

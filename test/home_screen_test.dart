import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/screens/home_screen.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/categories_fixtures.dart';
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

class _FakeCategoriesRepository implements MenuCategoriesRepository {
  @override
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  }) async {
    return Right(sampleCategories());
  }
}

Future<StoreConfigCubit> _pumpHome(
  WidgetTester tester, {
  required _FakeRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = StoreConfigCubit(repository);
  addTearDown(cubit.close);
  final categoriesCubit = HomeCategoriesCubit(_FakeCategoriesRepository());
  addTearDown(categoriesCubit.close);

  await tester.pumpWidget(
    MaterialApp(
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: categoriesCubit),
        ],
        child: const HomeScreen(),
      ),
    ),
  );
  // The category marquee scrolls continuously, so wait a fixed number of
  // frames instead of `pumpAndSettle`.
  await tester.pump();
  await tester.pump();
  await tester.pump();
  return cubit;
}

void main() {
  testWidgets('renders the restaurant content from the settings payload', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettings()),
    );

    expect(find.text('مطعم الربوة'), findsOneWidget);
    expect(find.text('مشاوي على الفحم'), findsOneWidget);
    expect(find.text('نكهة تستاهل التجربة'), findsOneWidget);
    expect(find.text('توصيل'), findsOneWidget);
    expect(find.text('استلام من المطعم'), findsOneWidget);
    expect(find.text('داخل المطعم'), findsOneWidget);
    expect(find.text('مفتوح الآن — نستقبل طلباتك'), findsOneWidget);
    expect(find.text('نقدًا'), findsOneWidget);
    expect(find.text('ر.ق · QAR'), findsOneWidget);
    expect(find.text('تصفح المنيو'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders optional fees, reservations and contact details', (
    tester,
  ) async {
    final base = sampleSettingsWithoutImages();
    final settings = base.copyWith(
      ordering: OrderingSettings(
        enabled: true,
        acceptingOrdersNow: true,
        orderTypes: base.ordering.orderTypes,
        paymentMethods: base.ordering.paymentMethods,
        deliveryFee: 5,
        taxPercent: 2.5,
        servicePercent: 10,
        requireCustomerLocation: true,
        workingHours: const {
          'friday': {'open': '13:00', 'close': '23:00'},
        },
        deliveryZones: const [
          {'id': 1, 'name': 'الدوحة'},
        ],
      ),
      contact: const StoreContact(
        phone: '+97433363803',
        whatsapp: '97433363803',
        instagram: 'alrabwah',
        location: 'الدوحة، قطر',
      ),
      reservationsEnabled: true,
      onlinePaymentEnabled: true,
      onlinePaymentGateway: 'visa',
    );

    await _pumpHome(tester, repository: _FakeRepository(result: settings));

    await tester.scrollUntilVisible(
      find.text('رسوم التوصيل'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('رسوم التوصيل'), findsOneWidget);
    expect(find.text('5.000 ر.ق'), findsOneWidget);
    expect(find.text('الضريبة'), findsOneWidget);
    expect(find.text('2.5%'), findsOneWidget);
    expect(find.text('رسوم الخدمة'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    expect(find.text('متاح'), findsNWidgets(2));
    expect(find.text('ساعات العمل'), findsOneWidget);
    expect(find.text('تحديد الموقع'), findsOneWidget);
    expect(find.text('مطلوب'), findsOneWidget);
    expect(find.text('نقدًا • visa'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تواصل معنا'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('الهاتف'), findsOneWidget);
    expect(find.text('واتساب'), findsOneWidget);
    expect(find.text('إنستغرام'), findsOneWidget);
    expect(find.text('الموقع'), findsOneWidget);
    expect(find.text('+97433363803'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the failure state and recovers on retry', (tester) async {
    final repository = _FakeRepository(error: Exception('offline'));
    await _pumpHome(tester, repository: repository);

    expect(
      find.text('تعذر تحميل بيانات المطعم، تحقق من اتصالك وحاول مرة أخرى.'),
      findsOneWidget,
    );
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    repository.error = null;
    repository.result = sampleSettingsWithoutImages();
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('مشاوي على الفحم'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsNothing);
  });

  testWidgets('fits a small phone at 2x text scale without overflow', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettingsWithoutImages()),
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.text('مشاوي على الفحم'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تصفح المنيو'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('تصفح المنيو'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swipes between promo banners and updates the dots', (
    tester,
  ) async {
    final base = sampleSettingsWithoutImages();
    final first = base.home.banners.first;
    final settings = base.copyWith(
      home: base.home.copyWith(
        banners: [
          first,
          first.copyWith(
            id: 4,
            title: 'طازج من البحر',
            subtitle: 'روبيان مشوي بالليمون والثوم',
          ),
        ],
      ),
    );

    await _pumpHome(tester, repository: _FakeRepository(result: settings));

    expect(find.text('مشاوي على الفحم'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-dot-1')), findsOneWidget);
    // The active dot is the wider lime pill.
    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-0'))).width,
      18,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-1'))).width,
      6,
    );

    // In RTL the next page sits to the left, so swipe towards the start.
    await tester.drag(find.byType(PageView), const Offset(350, 0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('طازج من البحر'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-0'))).width,
      6,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-1'))).width,
      18,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('advances the promo banner automatically', (tester) async {
    final base = sampleSettingsWithoutImages();
    final first = base.home.banners.first;
    final settings = base.copyWith(
      home: base.home.copyWith(
        banners: [
          first,
          first.copyWith(
            id: 4,
            title: 'طازج من البحر',
            subtitle: 'روبيان مشوي بالليمون والثوم',
          ),
        ],
      ),
    );

    await _pumpHome(tester, repository: _FakeRepository(result: settings));

    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-0'))).width,
      18,
    );

    // 4s on screen + the slide animation.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('طازج من البحر'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-1'))).width,
      18,
    );

    // Wraps back to the first banner.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      tester.getSize(find.byKey(const ValueKey('home-banner-dot-0'))).width,
      18,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the menu categories under the banner', (tester) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettingsWithoutImages()),
    );

    expect(find.text('اكتشف المنيو'), findsOneWidget);
    expect(find.text('أطباق ساخنة'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers the content on wide screens', (tester) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettingsWithoutImages()),
      size: const Size(1280, 900),
    );

    final bannerWidth = tester
        .getSize(find.bySemanticsLabel('مشاوي على الفحم'))
        .width;
    expect(bannerWidth, lessThanOrEqualTo(760));
    expect(tester.takeException(), isNull);
  });
}

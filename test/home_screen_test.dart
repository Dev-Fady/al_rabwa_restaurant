import 'dart:async';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_delivery_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/screens/home_screen.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

/// Keeps the settings request pending so the loading state stays on screen.
class _PendingRepository implements SettingsRepository {
  final Completer<Either<Failure, RestaurantSettings>> completer = Completer();

  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) {
    return completer.future;
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

class _FakeAddressesRepository implements AddressesRepository {
  _FakeAddressesRepository([this.addresses = const []]);

  final List<Address> addresses;

  @override
  Future<Either<Failure, List<Address>>> fetchAddresses({
    String lang = 'ar',
  }) async {
    return Right(addresses);
  }

  @override
  Future<Either<Failure, Address>> fetchAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Address>> setDefaultAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress({
    required int id,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }
}

Address _address({
  required int id,
  required String label,
  bool isDefault = false,
}) {
  return Address(
    id: id,
    kind: AddressKind.home,
    kindLabel: 'المنزل',
    label: label,
    title: label,
    summary: 'الدوحة',
    deliveryZone: null,
    isDeliverable: true,
    area: 'الدوحة',
    street: 'شارع 1',
    building: 'مبنى 2',
    notes: '',
    point: null,
    lastUsedAt: null,
    isDefault: isDefault,
  );
}

class _FakeMenuItemsRepository implements MenuItemsRepository {
  int? lastCategoryId;

  @override
  Future<Either<Failure, MenuCategoryItems>> fetchItems({
    required int categoryId,
    String lang = 'ar',
  }) async {
    lastCategoryId = categoryId;
    return const Right(MenuCategoryItems(items: []));
  }

  @override
  Future<Either<Failure, MenuItemDetails>> fetchItemDetails({
    required int itemId,
    String lang = 'ar',
  }) async {
    return Right(MenuItemDetails(item: MenuItem(id: itemId)));
  }
}

Future<StoreConfigCubit> _pumpHome(
  WidgetTester tester, {
  required SettingsRepository repository,
  List<Address> addresses = const [],
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = StoreConfigCubit(repository);
  addTearDown(cubit.close);
  final categoriesCubit = HomeCategoriesCubit(_FakeCategoriesRepository());
  addTearDown(categoriesCubit.close);
  final deliveryAddressCubit = HomeDeliveryAddressCubit(
    _FakeAddressesRepository(addresses),
    const FlutterSecureStorage(),
  )..load();
  addTearDown(deliveryAddressCubit.close);
  final cartCubit = CartCubit();
  addTearDown(cartCubit.close);

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
          BlocProvider.value(value: deliveryAddressCubit),
          BlocProvider.value(value: cartCubit),
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

typedef _HomeRouterHarness = ({
  MenuCubit menuCubit,
  _FakeMenuItemsRepository itemsRepository,
  GoRouter router,
});

/// Pumps the home page inside a small router with stubbed menu routes so
/// navigation started from the home content can be asserted.
Future<_HomeRouterHarness> _pumpHomeWithRouter(
  WidgetTester tester, {
  required RestaurantSettings settings,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final storeCubit = StoreConfigCubit(_FakeRepository(result: settings));
  addTearDown(storeCubit.close);
  final categoriesCubit = HomeCategoriesCubit(_FakeCategoriesRepository());
  addTearDown(categoriesCubit.close);
  final itemsRepository = _FakeMenuItemsRepository();
  final menuCubit = MenuCubit(_FakeCategoriesRepository(), itemsRepository);
  addTearDown(menuCubit.close);
  final deliveryAddressCubit = HomeDeliveryAddressCubit(
    _FakeAddressesRepository(),
    const FlutterSecureStorage(),
  );
  addTearDown(deliveryAddressCubit.close);
  final cartCubit = CartCubit();
  addTearDown(cartCubit.close);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.menu,
        builder: (context, state) => const Scaffold(body: Text('menu-screen')),
      ),
      GoRoute(
        path: '/menu/item/:itemId',
        builder: (context, state) =>
            Scaffold(body: Text('item-${state.pathParameters['itemId']}')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: storeCubit),
        BlocProvider.value(value: categoriesCubit),
        BlocProvider.value(value: menuCubit),
        BlocProvider.value(value: deliveryAddressCubit),
        BlocProvider.value(value: cartCubit),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();

  return (
    menuCubit: menuCubit,
    itemsRepository: itemsRepository,
    router: router,
  );
}

/// Settings with a single banner that links to [linkType]'s target.
RestaurantSettings _settingsWithBanner({
  required String linkType,
  int? categoryId,
  int? itemId,
}) {
  final base = sampleSettingsWithoutImages();
  return base.copyWith(
    home: base.home.copyWith(
      banners: [
        base.home.banners.first.copyWith(
          linkType: linkType,
          categoryId: categoryId,
          itemId: itemId,
          buttonText: 'جرّبه الآن',
        ),
      ],
    ),
  );
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

  testWidgets('shows the saved default address in the delivery bar', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettingsWithoutImages()),
      addresses: [
        _address(id: 1, label: 'البيت'),
        _address(id: 2, label: 'العمل', isDefault: true),
      ],
    );
    await tester.pump();

    expect(find.textContaining('العمل'), findsOneWidget);
    expect(find.textContaining('البيت'), findsNothing);
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

  testWidgets('shows a shimmer skeleton while the settings load', (
    tester,
  ) async {
    final repository = _PendingRepository();
    await _pumpHome(tester, repository: repository);

    expect(find.byKey(const ValueKey('home-loading-shimmer')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    repository.completer.complete(Right(sampleSettingsWithoutImages()));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('home-loading-shimmer')), findsNothing);
    expect(find.text('مشاوي على الفحم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keeps the loading shimmer layout overflow-free on a small phone',
    (tester) async {
      await _pumpHome(
        tester,
        repository: _PendingRepository(),
        size: const Size(320, 640),
        textScale: 2,
      );

      expect(
        find.byKey(const ValueKey('home-loading-shimmer')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

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

  testWidgets('opens the menu on the section tapped in the carousel', (
    tester,
  ) async {
    final harness = await _pumpHomeWithRouter(
      tester,
      settings: sampleSettingsWithoutImages(),
    );

    await tester.tap(find.text('مشاوي علي الفحم'));
    await tester.pump();
    await tester.pump();

    expect(find.text('menu-screen'), findsOneWidget);
    expect(harness.menuCubit.state.selectedCategory?.id, 11);
    expect(harness.itemsRepository.lastCategoryId, 11);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the banner section from its button', (tester) async {
    final harness = await _pumpHomeWithRouter(
      tester,
      settings: _settingsWithBanner(linkType: 'category', categoryId: 13),
    );

    await tester.tap(find.text('جرّبه الآن'));
    await tester.pump();
    await tester.pump();

    expect(find.text('menu-screen'), findsOneWidget);
    expect(harness.menuCubit.state.selectedCategory?.id, 13);
    expect(harness.itemsRepository.lastCategoryId, 13);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the banner dish from its button', (tester) async {
    final harness = await _pumpHomeWithRouter(
      tester,
      settings: _settingsWithBanner(linkType: 'item', itemId: 36),
    );

    await tester.tap(find.text('جرّبه الآن'));
    await tester.pump();
    await tester.pump();

    expect(find.text('item-36'), findsOneWidget);
    expect(harness.router.state.uri.path, AppRoutes.menuItemPath(36));
    expect(tester.takeException(), isNull);
  });
}

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/data/models/menu_item_details_response.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/item_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/item_details_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/menu_fixtures.dart';
import 'helpers/settings_fixtures.dart';

class _FakeItemsRepository implements MenuItemsRepository {
  _FakeItemsRepository({this.details});

  MenuItemDetails? details;
  Object? error;
  int calls = 0;
  int? lastItemId;
  String? lastLang;

  @override
  Future<Either<Failure, MenuCategoryItems>> fetchItems({
    required int categoryId,
    String lang = 'ar',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MenuItemDetails>> fetchItemDetails({
    required int itemId,
    String lang = 'ar',
  }) async {
    calls++;
    lastItemId = itemId;
    lastLang = lang;
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(details ?? const MenuItemDetails(item: MenuItem(id: 40)));
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  final RestaurantSettings settings;

  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    return Right(settings);
  }
}

MenuItemDetails _sampleDetails({String image = ''}) {
  return MenuItemDetailsResponse.fromJson(
    itemDetailsPayload(image: image),
  ).toEntity()!;
}

Future<ItemDetailsCubit> _pumpDetails(
  WidgetTester tester, {
  _FakeItemsRepository? repository,
  CartCubit? cartCubit,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final storeCubit = StoreConfigCubit(
    _FakeSettingsRepository(sampleSettings()),
  );
  addTearDown(storeCubit.close);
  final cubit = ItemDetailsCubit(
    repository ?? _FakeItemsRepository(details: _sampleDetails()),
    40,
  );
  addTearDown(cubit.close);
  final cart = cartCubit ?? CartCubit();
  addTearDown(cart.close);

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
          BlocProvider.value(value: storeCubit),
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: cart),
        ],
        child: const ItemDetailsScreen(),
      ),
    ),
  );
  cubit.load();
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  test('the dish route matches its menu location', () {
    final match = AppRouter.router.configuration.findMatch(
      Uri.parse(AppRoutes.menuItemPath(40)),
    );

    expect(match.isError, isFalse);
    expect(match.pathParameters['itemId'], '40');
  });

  group('MenuItemDetailsResponse', () {
    test('maps the dish and its category', () {
      final details = _sampleDetails(
        image:
            'https://al-rabwah.smartmenues.com/storage/restaurants/2/items/1742219720_1.jpg',
      );

      expect(details.item.id, 40);
      expect(details.item.categoryId, 11);
      expect(details.item.name, 'دجاج مسحب (700 غ)');
      expect(details.item.price, 35);
      expect(details.item.hasImage, isTrue);
      expect(details.category?.id, 11);
      expect(details.category?.name, 'مشاوي علي الفحم');
    });

    test('returns null when the payload has no dish', () {
      final details = MenuItemDetailsResponse.fromJson({
        'success': true,
        'data': null,
      }).toEntity();

      expect(details, isNull);
    });
  });

  group('ItemDetailsCubit', () {
    test('loads the dish in the requested language', () async {
      final repository = _FakeItemsRepository(details: _sampleDetails());
      final cubit = ItemDetailsCubit(repository, 40, lang: 'en');
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, MenuStatus.success);
      expect(cubit.state.details?.item.id, 40);
      expect(repository.lastItemId, 40);
      expect(repository.lastLang, 'en');
    });

    test('exposes the failure message and retries', () async {
      final repository = _FakeItemsRepository(details: _sampleDetails())
        ..error = ServerFailure('انقطع الاتصال');
      final cubit = ItemDetailsCubit(repository, 40);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.status, MenuStatus.failure);
      expect(cubit.state.errorMessage, 'انقطع الاتصال');

      repository.error = null;
      await cubit.retry();

      expect(cubit.state.status, MenuStatus.success);
      expect(cubit.state.details, isNotNull);
      expect(repository.calls, 2);
    });
  });

  group('ItemDetailsScreen', () {
    testWidgets('renders the dish, category, price and instructions', (
      tester,
    ) async {
      await _pumpDetails(tester);

      expect(find.text('مشاوي علي الفحم'), findsOneWidget);
      expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
      expect(find.text('يُحضّر طازجًا عند الطلب'), findsOneWidget);
      expect(find.text('35.000 ر.ق'), findsOneWidget);
      expect(find.text('الكمية'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('تعليمات خاصة'), findsOneWidget);
      expect(find.text('أضف إلى السلة - 35.000 ر.ق'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('increments and decrements the quantity and total', (
      tester,
    ) async {
      await _pumpDetails(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      expect(find.text('أضف إلى السلة - 70.000 ر.ق'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('أضف إلى السلة - 35.000 ر.ق'), findsOneWidget);
    });

    testWidgets('adds the dish with its quantity and notes to the cart', (
      tester,
    ) async {
      final cart = CartCubit();
      await _pumpDetails(tester, cartCubit: cart);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('أضف إلى السلة - 70.000 ر.ق'));
      await tester.pumpAndSettle();

      expect(cart.state.itemsCount, 1);
      expect(cart.state.totalQuantity, 2);
      expect(cart.state.subtotal, 70);
      expect(find.text('أُضيف إلى السلة'), findsOneWidget);
    });

    testWidgets('retries after the dish fails to load', (tester) async {
      final repository = _FakeItemsRepository(details: _sampleDetails())
        ..error = ServerFailure('انقطع الاتصال');
      await _pumpDetails(tester, repository: repository);

      expect(find.text('تعذر تحميل تفاصيل الطبق.'), findsOneWidget);

      repository.error = null;
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
      expect(find.text('تعذر تحميل تفاصيل الطبق.'), findsNothing);
    });

    testWidgets('fits a small phone at 2x text scale without overflow', (
      tester,
    ) async {
      await _pumpDetails(tester, size: const Size(320, 640), textScale: 2);

      expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/data/models/menu_items_response.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/menu_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/menu_fixtures.dart';
import 'helpers/settings_fixtures.dart';

class _FakeCategoriesRepository implements MenuCategoriesRepository {
  _FakeCategoriesRepository({this.result = const [], this.error});

  List<MenuCategory> result;
  Object? error;
  int calls = 0;
  String? lastLang;

  @override
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  }) async {
    calls++;
    lastLang = lang;
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(result);
  }
}

class _FakeItemsRepository implements MenuItemsRepository {
  _FakeItemsRepository({this.result = const {}});

  Map<int, MenuCategoryItems> result;
  Object? error;
  int calls = 0;
  int? lastCategoryId;
  String? lastLang;

  @override
  Future<Either<Failure, MenuCategoryItems>> fetchItems({
    required int categoryId,
    String lang = 'ar',
  }) async {
    calls++;
    lastCategoryId = categoryId;
    lastLang = lang;
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(result[categoryId] ?? const MenuCategoryItems(items: []));
  }

  @override
  Future<Either<Failure, MenuItemDetails>> fetchItemDetails({
    required int itemId,
    String lang = 'ar',
  }) async {
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(MenuItemDetails(item: MenuItem(id: itemId)));
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

Future<MenuCubit> _pumpMenu(
  WidgetTester tester, {
  _FakeCategoriesRepository? categoriesRepository,
  _FakeItemsRepository? itemsRepository,
  CartCubit? cartCubit,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final categories =
      categoriesRepository ??
      _FakeCategoriesRepository(result: menuCategoriesFixture());
  final items =
      itemsRepository ?? _FakeItemsRepository(result: menuItemsFixture());

  final storeCubit = StoreConfigCubit(
    _FakeSettingsRepository(sampleSettings()),
  );
  addTearDown(storeCubit.close);
  final menuCubit = MenuCubit(categories, items);
  addTearDown(menuCubit.close);
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
          BlocProvider.value(value: menuCubit),
          BlocProvider.value(value: cart),
        ],
        child: const MenuScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return menuCubit;
}

void main() {
  group('MenuItemsResponse', () {
    test('maps dishes and the category summary', () {
      final payload = MenuItemsResponse.fromJson(
        menuItemsPayloadWithImages(),
      ).toEntity();

      expect(payload.items, hasLength(1));
      final item = payload.items.single;
      expect(item.id, 40);
      expect(item.categoryId, 11);
      expect(item.name, 'دجاج مسحب (700 غ)');
      expect(item.price, 35);
      expect(item.hasImage, isTrue);
      expect(item.image, contains('1742219720_1.jpg'));
      expect(item.hasDiscount, isFalse);

      expect(payload.category?.id, 11);
      expect(payload.category?.itemsCount, 12);
      expect(payload.category?.displayStyle, CategoryDisplayStyle.large);
    });

    test('parses the grid display style', () {
      final payload = MenuItemsResponse.fromJson({
        'data': <dynamic>[],
        'category': {
          'id': 13,
          'name': 'أطباق غربية',
          'image': null,
          'display_style': 'grid',
          'items_count': 12,
        },
      }).toEntity();

      expect(payload.category?.displayStyle, CategoryDisplayStyle.grid);
      expect(payload.items, isEmpty);
    });

    test('parses dishes sold by weight that expose a range', () {
      final payload = MenuItemsResponse.fromJson(
        menuItemsPayloadWithWeightRange(),
      ).toEntity();

      expect(payload.items, hasLength(2));

      final mixedGrill = payload.items.first;
      expect(mixedGrill.name, 'مشاوي مشكلة');
      expect(mixedGrill.price, 39);
      expect(mixedGrill.soldByWeight, isTrue);
      expect(mixedGrill.weight, 0.25);
      expect(mixedGrill.weightRange?.min, 0.25);
      expect(mixedGrill.weightRange?.max, 10);
      expect(mixedGrill.weightRange?.step, 0.25);
      expect(mixedGrill.weightRange?.choices.first, 0.25);
      expect(mixedGrill.weightRange?.choices, hasLength(40));
      expect(mixedGrill.hasOptions, isTrue);
      expect(mixedGrill.defaultOption?.id, 7);
      expect(mixedGrill.defaultWeight, 0.25);
      expect(mixedGrill.options.map((option) => option.name), [
        'نفر واحد',
        'نفرين',
      ]);
      expect(mixedGrill.options.last.price, 30);
      expect(mixedGrill.hasAddons, isTrue);
      expect(mixedGrill.addons.map((addon) => addon.name), [
        'إضافة أرز',
        'إضافة صوص',
        'إضافة خبز',
      ]);
      expect(mixedGrill.addons.first.price, 5);
      expect(mixedGrill.hasVideo, isTrue);

      final chicken = payload.items.last;
      expect(chicken.soldByWeight, isFalse);
      expect(chicken.weight, isNull);
      expect(chicken.defaultOption, isNull);
      expect(chicken.defaultWeight, 1);
      expect(chicken.hasWeightRange, isFalse);
      expect(chicken.hasOptions, isFalse);
      expect(chicken.hasAddons, isTrue);
      expect(chicken.addons.single.name, 'إضافة أرز');

      expect(payload.category?.displayStyle, CategoryDisplayStyle.grid);
    });

    test('keeps a numeric weight payload working', () {
      final item = MenuItemModel.fromJson({
        'id': 1,
        'price': 10,
        'sold_by_weight': true,
        'weight': 2.5,
      }).toEntity();

      expect(item.soldByWeight, isTrue);
      expect(item.weight, 2.5);
    });

    test('keeps safe defaults for missing item fields', () {
      final item = const MenuItemModel(name: '  ').toEntity();

      expect(item.id, isNull);
      expect(item.name, '');
      expect(item.price, 0);
      expect(item.hasImage, isFalse);
      expect(item.hasDiscount, isFalse);
    });
  });

  group('MenuCubit', () {
    test('loads categories and the first category items once', () async {
      final categoriesRepository = _FakeCategoriesRepository(
        result: menuCategoriesFixture(),
      );
      final itemsRepository = _FakeItemsRepository(result: menuItemsFixture());
      final cubit = MenuCubit(
        categoriesRepository,
        itemsRepository,
        lang: 'ar',
      );

      await cubit.loadIfNeeded();
      await cubit.loadIfNeeded();

      expect(cubit.state.categoriesStatus, MenuStatus.success);
      expect(cubit.state.categories, hasLength(3));
      expect(cubit.state.selectedCategory?.id, 11);
      expect(cubit.state.itemsStatus, MenuStatus.success);
      expect(cubit.state.items, hasLength(3));
      expect(categoriesRepository.calls, 1);
      expect(itemsRepository.lastCategoryId, 11);
      await cubit.close();
    });

    test('loads the dishes of the newly selected category', () async {
      final categoriesRepository = _FakeCategoriesRepository(
        result: menuCategoriesFixture(),
      );
      final itemsRepository = _FakeItemsRepository(result: menuItemsFixture());
      final cubit = MenuCubit(categoriesRepository, itemsRepository);

      await cubit.load();
      await cubit.selectCategory(cubit.state.categories[2]);

      expect(cubit.state.selectedCategory?.id, 13);
      expect(
        cubit.state.selectedCategory?.displayStyle,
        CategoryDisplayStyle.grid,
      );
      expect(cubit.state.items.map((item) => item.name), [
        'بيتزا مارغريتا',
        'برجر لحم',
      ]);
      expect(itemsRepository.lastCategoryId, 13);
      await cubit.close();
    });

    test('reloads in the selected language', () async {
      final categoriesRepository = _FakeCategoriesRepository(
        result: menuCategoriesFixture(),
      );
      final itemsRepository = _FakeItemsRepository(result: menuItemsFixture());
      final cubit = MenuCubit(categoriesRepository, itemsRepository);

      await cubit.load(lang: 'en');

      expect(categoriesRepository.lastLang, 'en');
      expect(itemsRepository.lastLang, 'en');
      await cubit.close();
    });

    test('emits a failure when categories cannot load', () async {
      final categoriesRepository = _FakeCategoriesRepository(
        error: ServerFailure('تعذر الاتصال بالخادم'),
      );
      final itemsRepository = _FakeItemsRepository();
      final cubit = MenuCubit(categoriesRepository, itemsRepository);

      await cubit.load();

      expect(cubit.state.categoriesStatus, MenuStatus.failure);
      expect(cubit.state.itemsStatus, MenuStatus.failure);
      expect(cubit.state.errorMessage, 'تعذر الاتصال بالخادم');
      await cubit.close();
    });

    test('retries the dishes after an items failure', () async {
      final categoriesRepository = _FakeCategoriesRepository(
        result: menuCategoriesFixture(),
      );
      final itemsRepository = _FakeItemsRepository(result: menuItemsFixture())
        ..error = ServerFailure('انقطع الاتصال');
      final cubit = MenuCubit(categoriesRepository, itemsRepository);

      await cubit.load();
      expect(cubit.state.itemsStatus, MenuStatus.failure);

      itemsRepository.error = null;
      await cubit.retryItems();

      expect(cubit.state.itemsStatus, MenuStatus.success);
      expect(cubit.state.items, hasLength(3));
      await cubit.close();
    });
  });

  group('MenuScreen', () {
    testWidgets('renders the header, categories, hero and dishes', (
      tester,
    ) async {
      await _pumpMenu(tester);

      expect(find.text('المنيو'), findsOneWidget);
      expect(find.text('مطعم الربوة'), findsOneWidget);
      expect(find.text('ابحث عن طبقك المفضل'), findsOneWidget);
      // Tab + hero banner.
      expect(find.text('مشاوي علي الفحم'), findsNWidgets(2));
      expect(find.text('3 أصناف'), findsOneWidget);
      expect(find.text('تصفح جميع الأقسام'), findsOneWidget);
      expect(find.text('اختر طبقك وأضف لسلة'), findsOneWidget);
      expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
      expect(find.text('35.000 ر.ق'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches to the list display style', (tester) async {
      await _pumpMenu(tester);

      await tester.ensureVisible(find.text('أطباق ساخنة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('أطباق ساخنة'));
      await tester.pumpAndSettle();

      expect(find.text('شوربة عدس'), findsOneWidget);
      expect(find.byKey(const ValueKey('menu-list-60')), findsOneWidget);
      expect(find.text('صنفان'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches to the grid display style', (tester) async {
      await _pumpMenu(tester);

      await tester.ensureVisible(find.text('أطباق غربية'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('أطباق غربية'));
      await tester.pumpAndSettle();

      expect(find.text('بيتزا مارغريتا'), findsOneWidget);
      expect(find.byKey(const ValueKey('menu-grid-70')), findsOneWidget);
      expect(find.byKey(const ValueKey('menu-grid-71')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adds dishes to the cart from the list and totals them', (
      tester,
    ) async {
      final cart = CartCubit();
      await _pumpMenu(tester, cartCubit: cart);

      await tester.ensureVisible(find.text('أطباق ساخنة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('أطباق ساخنة'));
      await tester.pumpAndSettle();

      final tile = find.byKey(const ValueKey('menu-list-60'));
      await tester.tap(
        find.descendant(of: tile, matching: find.byIcon(Icons.add)),
      );
      await tester.pumpAndSettle();

      expect(cart.state.itemsCount, 1);
      expect(cart.state.subtotal, 15);
      expect(find.text('عرض السلة'), findsOneWidget);
      expect(find.text('صنف واحد'), findsOneWidget);
      // Dish price + cart total.
      expect(find.text('15.000 ر.ق'), findsNWidgets(2));

      await tester.tap(
        find.descendant(of: tile, matching: find.byIcon(Icons.add)),
      );
      await tester.pumpAndSettle();

      expect(cart.state.totalQuantity, 2);
      expect(cart.state.subtotal, 30);
      expect(find.text('30.000 ر.ق'), findsOneWidget);

      await tester.tap(
        find.descendant(of: tile, matching: find.byIcon(Icons.remove)),
      );
      await tester.pumpAndSettle();

      expect(cart.state.totalQuantity, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('quick-add uses the default option and starting weight', (
      tester,
    ) async {
      final items = MenuItemsResponse.fromJson(
        menuItemsPayloadWithWeightRange(),
      ).toEntity();
      final cart = CartCubit();
      await _pumpMenu(
        tester,
        categoriesRepository: _FakeCategoriesRepository(
          result: const [
            MenuCategory(
              id: 6,
              name: 'مشاوي',
              displayStyle: CategoryDisplayStyle.grid,
              itemsCount: 2,
            ),
          ],
        ),
        itemsRepository: _FakeItemsRepository(result: {6: items}),
        cartCubit: cart,
      );

      final tile = find.byKey(const ValueKey('menu-grid-31'));
      await tester.tap(
        find.descendant(of: tile, matching: find.byIcon(Icons.add)),
      );
      await tester.pumpAndSettle();

      final line = cart.state.lines.single;
      expect(line.option?.id, 7);
      expect(line.weight, 0.25);
      expect(cart.state.subtotal, 9.75);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filters dishes by name and clears the search', (tester) async {
      await _pumpMenu(tester);

      await tester.enterText(find.byType(TextField), 'ريش');
      await tester.pumpAndSettle();

      expect(find.text('ريش (250 غ)'), findsOneWidget);
      expect(find.text('دجاج مسحب (700 غ)'), findsNothing);
      expect(find.text('تصفح جميع الأقسام'), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
      expect(find.text('تصفح جميع الأقسام'), findsOneWidget);
    });

    testWidgets('shows an empty search state', (tester) async {
      await _pumpMenu(tester);

      await tester.enterText(find.byType(TextField), 'لا يوجد');
      await tester.pumpAndSettle();

      expect(find.text('لا توجد أطباق مطابقة لبحثك.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retries when loading the dishes fails', (tester) async {
      final itemsRepository = _FakeItemsRepository(result: menuItemsFixture())
        ..error = ServerFailure('انقطع الاتصال');
      await _pumpMenu(tester, itemsRepository: itemsRepository);

      expect(find.text('تعذر تحميل الأطباق.'), findsOneWidget);

      itemsRepository.error = null;
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone at 2x text scale without overflow', (
      tester,
    ) async {
      await _pumpMenu(tester, size: const Size(320, 640), textScale: 2);

      expect(find.text('المنيو'), findsOneWidget);
      expect(find.text('ابحث عن طبقك المفضل'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

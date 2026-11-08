import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/menu_categories_screen.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_categories_grid.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/categories_fixtures.dart';
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

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    return Right(sampleSettingsWithoutImages());
  }
}

Future<void> _pumpCategories(
  WidgetTester tester, {
  required _FakeCategoriesRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final storeCubit = StoreConfigCubit(_FakeSettingsRepository());
  addTearDown(storeCubit.close);
  final categoriesCubit = HomeCategoriesCubit(repository);
  addTearDown(categoriesCubit.close);
  final menuCubit = MenuCubit(repository, _FakeItemsRepository());
  addTearDown(menuCubit.close);

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
          BlocProvider.value(value: categoriesCubit),
          BlocProvider.value(value: menuCubit),
        ],
        child: const MenuCategoriesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MenuCubit.openCategory', () {
    test('loads the menu before selecting the tapped section', () async {
      final categoriesRepository = _FakeCategoriesRepository(
        result: sampleCategories(),
      );
      final itemsRepository = _FakeItemsRepository();
      final cubit = MenuCubit(categoriesRepository, itemsRepository);

      await cubit.openCategory(sampleCategories()[2]);

      expect(categoriesRepository.calls, 1);
      expect(cubit.state.selectedCategory?.id, 13);
      expect(itemsRepository.lastCategoryId, 13);
      await cubit.close();
    });
  });

  group('MenuCategoriesScreen', () {
    testWidgets('renders the header, back link, hero and section cards', (
      tester,
    ) async {
      await _pumpCategories(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
      );

      expect(find.text('أقسام المنيو'), findsOneWidget);
      expect(find.text('اختر ما تشتهيه'), findsOneWidget);
      expect(find.text('العودة إلى الرئيسية'), findsOneWidget);
      expect(find.text('جميع النكهات في مكان واحد'), findsOneWidget);
      expect(find.text('تصفّح قائمة مطعم مطعم الربوة (13)'), findsOneWidget);
      expect(find.text('مشاوي علي الفحم'), findsOneWidget);
      expect(find.text('29 صنفًا'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('menu-category-card-11')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the failure state and recovers on retry', (
      tester,
    ) async {
      final repository = _FakeCategoriesRepository(
        error: ServerFailure('تعذر الاتصال بالخادم'),
      );
      await _pumpCategories(tester, repository: repository);

      expect(find.text('تعذر تحميل أقسام المنيو.'), findsOneWidget);
      expect(find.text('العودة إلى الرئيسية'), findsOneWidget);

      repository.error = null;
      repository.result = sampleCategories();
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('جميع النكهات في مكان واحد'), findsOneWidget);
      expect(find.text('مشاوي علي الفحم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays the cards out in a wider grid on tablets', (
      tester,
    ) async {
      await _pumpCategories(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
        size: const Size(900, 1200),
      );

      final first = tester.getTopLeft(
        find.byKey(const ValueKey('menu-category-card-11')),
      );
      final second = tester.getTopLeft(
        find.byKey(const ValueKey('menu-category-card-12')),
      );
      final third = tester.getTopLeft(
        find.byKey(const ValueKey('menu-category-card-13')),
      );
      final fourth = tester.getTopLeft(
        find.byKey(const ValueKey('menu-category-card-14')),
      );

      expect(second.dy, first.dy);
      expect(third.dy, first.dy);
      expect(fourth.dy, greaterThan(first.dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone at 2x text scale without overflow', (
      tester,
    ) async {
      await _pumpCategories(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
        size: const Size(320, 640),
        textScale: 2,
      );

      expect(find.text('أقسام المنيو'), findsOneWidget);
      expect(find.text('العودة إلى الرئيسية'), findsOneWidget);
      expect(find.text('مشاوي علي الفحم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MenuCategoriesGrid', () {
    testWidgets('opens the tapped section', (tester) async {
      MenuCategory? tapped;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: MenuCategoriesGrid(
                categories: sampleCategories(),
                itemsLabel: (category) => '${category.itemsCount}',
                onCategoryTap: (category) => tapped = category,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('menu-category-card-14')));
      await tester.pump();

      expect(tapped?.id, 14);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('router opens the all-sections page', (tester) async {
    final categoriesRepository = _FakeCategoriesRepository(
      result: sampleCategories(),
    );
    final itemsRepository = _FakeItemsRepository();
    final storeCubit = StoreConfigCubit(_FakeSettingsRepository());
    addTearDown(storeCubit.close);
    final categoriesCubit = HomeCategoriesCubit(categoriesRepository);
    addTearDown(categoriesCubit.close);
    final menuCubit = MenuCubit(categoriesRepository, itemsRepository);
    addTearDown(menuCubit.close);
    final cartCubit = CartCubit();
    addTearDown(cartCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: storeCubit),
          BlocProvider.value(value: categoriesCubit),
          BlocProvider.value(value: menuCubit),
          BlocProvider.value(value: cartCubit),
        ],
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
          locale: const Locale('ar'),
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    AppRouter.router.go(AppRoutes.menuCategories);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('أقسام المنيو'), findsOneWidget);
    expect(find.textContaining('الصفحة غير موجودة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

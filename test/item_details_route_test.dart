import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/data/models/menu_item_details_response.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/item_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/menu_fixtures.dart';
import 'helpers/settings_fixtures.dart';

class _Repo implements MenuItemsRepository {
  @override
  Future<Either<Failure, MenuCategoryItems>> fetchItems({
    required int categoryId,
    String lang = 'ar',
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, MenuItemDetails>> fetchItemDetails({
    required int itemId,
    String lang = 'ar',
  }) async => Right(
    MenuItemDetailsResponse.fromJson(itemDetailsPayload(image: '')).toEntity()!,
  );
}

class _Categories implements MenuCategoriesRepository {
  @override
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  }) async => const Right([]);
}

class _Settings implements SettingsRepository {
  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async => Right(sampleSettings());
}

void main() {
  testWidgets('router opens the dish page', (tester) async {
    getIt.registerFactoryParam<ItemDetailsCubit, int, String>(
      (itemId, lang) => ItemDetailsCubit(_Repo(), itemId, lang: lang),
    );
    addTearDown(getIt.reset);
    final store = StoreConfigCubit(_Settings());
    addTearDown(store.close);
    final menu = MenuCubit(_Categories(), _Repo());
    addTearDown(menu.close);
    final cart = CartCubit();
    addTearDown(cart.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: store),
          BlocProvider.value(value: menu),
          BlocProvider.value(value: cart),
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

    AppRouter.router.go(AppRoutes.menuItemPath(40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('دجاج مسحب (700 غ)'), findsOneWidget);
    expect(find.textContaining('الصفحة غير موجودة'), findsNothing);
  });
}

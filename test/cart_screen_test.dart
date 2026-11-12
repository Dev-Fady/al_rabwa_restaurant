import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/cart/data/models/cart_quote_response.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_quote_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/screens/cart_screen.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/cart_quote_summary.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/settings_fixtures.dart';

const _grill = MenuItem(
  id: 31,
  name: 'مشاوي مشكلة',
  price: 39,
  soldByWeight: true,
  options: [MenuItemOption(id: 7, name: 'نفر واحد')],
);

CartQuote _sampleQuote() {
  return CartQuoteResponse.fromJson({
    'data': {
      'lines': [
        {
          'item_id': 31,
          'name': 'مشاوي مشكلة',
          'option': {'id': 7, 'name': 'نفر واحد', 'price': 0},
          'addons': <dynamic>[],
          'quantity': 0.25,
          'unit_price': 39,
          'total': 9.75,
          'note': null,
        },
      ],
      'coupon': null,
      'subtotal': 9.75,
      'discount': 0,
      'tax': 0.975,
      'service_charge': 0.488,
      'delivery_fee': 0,
      'total': 11.213,
      'address_required': false,
      'accepting_orders_now': true,
      'closed_message': null,
    },
  }).toEntity()!;
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    return Right(sampleSettingsWithoutImages());
  }
}

class _FakeQuoteRepository implements CartQuoteRepository {
  _FakeQuoteRepository({this.quote, this.cached});

  CartQuote? quote;
  CartQuote? cached;

  @override
  Future<Either<Failure, CartQuote>> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  }) async {
    final quote = this.quote;
    if (quote == null) return Left(ServerFailure('no quote'));
    return Right(quote);
  }

  @override
  CartQuote? getCachedQuote({required Cart cart, String lang = 'ar'}) {
    return cached;
  }
}

typedef _CartHarness = ({CartCubit cartCubit, CartQuoteCubit quoteCubit});

Future<_CartHarness> _pumpCart(
  WidgetTester tester, {
  bool withItem = false,
  CartQuote? quote,
  CartQuote? cached,
  bool withRouter = false,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cartCubit = CartCubit();
  if (withItem) {
    cartCubit.add(
      _grill,
      weight: 0.25,
      option: const MenuItemOption(id: 7, name: 'نفر واحد'),
    );
  }
  addTearDown(cartCubit.close);

  final quoteCubit = CartQuoteCubit(
    _FakeQuoteRepository(quote: quote, cached: cached),
    cartCubit,
  );
  addTearDown(quoteCubit.close);

  final storeCubit = StoreConfigCubit(_FakeSettingsRepository());
  addTearDown(storeCubit.close);

  final providers = [
    BlocProvider.value(value: cartCubit),
    BlocProvider.value(value: quoteCubit),
    BlocProvider.value(value: storeCubit),
  ];

  final Widget app;
  if (withRouter) {
    final router = GoRouter(
      initialLocation: AppRoutes.cart,
      routes: [
        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.menu,
          builder: (context, state) =>
              const Scaffold(body: Text('menu-screen')),
        ),
        GoRoute(
          path: AppRoutes.checkout,
          builder: (context, state) =>
              const Scaffold(body: Text('checkout-screen')),
        ),
      ],
    );
    addTearDown(router.dispose);

    app = MaterialApp.router(
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
      routerConfig: router,
    );
  } else {
    app = MaterialApp(
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
      home: const CartScreen(),
    );
  }

  await tester.pumpWidget(MultiBlocProvider(providers: providers, child: app));
  await tester.pumpAndSettle();

  return (cartCubit: cartCubit, quoteCubit: quoteCubit);
}

void main() {
  testWidgets('shows the empty state and opens the menu', (tester) async {
    await _pumpCart(tester, withRouter: true);

    expect(find.text('سلتك فارغة'), findsOneWidget);
    expect(find.text('تصفح المنيو'), findsOneWidget);

    await tester.tap(find.text('تصفح المنيو'));
    await tester.pumpAndSettle();

    expect(find.text('menu-screen'), findsOneWidget);
  });

  testWidgets('renders the server quote totals for the cart', (tester) async {
    await _pumpCart(tester, withItem: true, quote: _sampleQuote());

    expect(find.text('مشاوي مشكلة'), findsOneWidget);
    expect(find.text('نفر واحد'), findsOneWidget);
    expect(find.text('ملخص الطلب'), findsOneWidget);
    expect(find.text('9.750 ر.ق'), findsNWidgets(2));
    expect(find.text('0.975 ر.ق'), findsOneWidget);
    expect(find.text('0.488 ر.ق'), findsOneWidget);
    expect(find.text('11.213 ر.ق'), findsOneWidget);
  });

  testWidgets('keeps the cached quote visible when refreshing fails', (
    tester,
  ) async {
    await _pumpCart(
      tester,
      withItem: true,
      cached: _sampleQuote(),
      quote: null,
    );

    expect(find.text('11.213 ر.ق'), findsOneWidget);
    expect(
      find.text('يتم عرض آخر إجمالي محفوظ. اسحب للتحديث.'),
      findsOneWidget,
    );
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('opens checkout from the cart summary', (tester) async {
    await _pumpCart(
      tester,
      withItem: true,
      quote: _sampleQuote(),
      withRouter: true,
    );

    final checkoutButton = find.text('إتمام الطلب');
    expect(checkoutButton, findsOneWidget);

    await tester.ensureVisible(checkoutButton);
    await tester.pumpAndSettle();
    await tester.tap(checkoutButton);
    await tester.pumpAndSettle();

    expect(find.text('checkout-screen'), findsOneWidget);
  });

  testWidgets('fits a narrow screen with large text without overflow', (
    tester,
  ) async {
    await _pumpCart(
      tester,
      withItem: true,
      quote: _sampleQuote(),
      size: const Size(320, 640),
      textScale: 1.5,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('11.213 ر.ق'), findsOneWidget);
  });

  testWidgets('uses a two-column layout on wide screens', (tester) async {
    await _pumpCart(
      tester,
      withItem: true,
      quote: _sampleQuote(),
      size: const Size(1200, 900),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('11.213 ر.ق'), findsOneWidget);
    expect(find.text('مشاوي مشكلة'), findsOneWidget);
    expect(tester.getSize(find.byType(CartQuoteSummary)).width, 340);
  });
}

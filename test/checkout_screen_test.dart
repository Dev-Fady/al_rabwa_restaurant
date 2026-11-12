import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/data/models/cart_quote_response.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_quote_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/screens/checkout_screen.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_bottom_bar.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/orders/data/models/order_response.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/orders_page.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/repositories/tables_repository.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/settings_fixtures.dart';

const _grill = MenuItem(
  id: 31,
  name: 'مشاوي مشكلة',
  price: 39,
  soldByWeight: true,
  options: [MenuItemOption(id: 7, name: 'نفر واحد')],
);

const _address = Address(
  id: 5,
  kind: AddressKind.home,
  kindLabel: 'المنزل',
  label: 'بيتي',
  title: 'بيتي',
  summary: 'الدوحة، شارع الكورنيش',
  deliveryZone: 'الدوحة',
  isDeliverable: true,
  area: 'الدوحة',
  street: 'شارع الكورنيش',
  building: '12',
  notes: '',
  point: GeoPoint(latitude: 25.2854, longitude: 51.531),
  lastUsedAt: null,
  isDefault: true,
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

Order _sampleOrder() {
  return OrderResponse.fromJson({
    'data': {
      'id': 25,
      'number': 12,
      'type': {'value': 'takeaway', 'label': 'استلام من المطعم'},
      'status': {
        'value': 'pending',
        'label': 'جديد',
        'is_open': true,
        'message': 'استلمنا طلبك رقم 12.',
      },
      'payment': {
        'method': {'value': 'cash', 'label': 'نقدًا'},
        'status': {'value': 'unpaid', 'label': 'غير مدفوع'},
      },
      'notes': 'Test order - please ignore',
      'subtotal': 9.75,
      'discount': 0,
      'tax': 0.975,
      'service_charge': 0.488,
      'delivery_fee': 0,
      'total': 11.213,
      'items': <dynamic>[],
    },
  }).toEntity()!;
}

RestaurantSettings _closedSettings() {
  final base = sampleSettingsWithoutImages();
  final ordering = base.ordering;
  return base.copyWith(
    ordering: OrderingSettings(
      enabled: false,
      acceptingOrdersNow: false,
      closedMessage: 'مغلق الآن — نفتح قريبًا',
      orderTypes: ordering.orderTypes,
      paymentMethods: ordering.paymentMethods,
    ),
  );
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

class _FakeQuoteRepository implements CartQuoteRepository {
  @override
  Future<Either<Failure, CartQuote>> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  }) async {
    return Right(_sampleQuote());
  }

  @override
  CartQuote? getCachedQuote({required Cart cart, String lang = 'ar'}) => null;
}

class _FakeOrdersRepository implements OrdersRepository {
  Order? order;
  Object? error;
  int calls = 0;
  OrderDraft? lastDraft;
  String? lastIdempotencyKey;

  @override
  Future<Either<Failure, Order>> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  }) async {
    calls++;
    lastDraft = draft;
    lastIdempotencyKey = idempotencyKey;

    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(order ?? _sampleOrder());
  }

  @override
  Future<Either<Failure, OrdersPage>> fetchOrders({
    required int page,
    String status = 'current',
    String lang = 'ar',
  }) async {
    return const Right(OrdersPage());
  }

  @override
  Future<Either<Failure, Order>> fetchOrderDetails({
    required int orderId,
    String lang = 'ar',
  }) async {
    return Left(ServerFailure('not used'));
  }
}

class _FakeAddressesRepository implements AddressesRepository {
  _FakeAddressesRepository(this.addresses);

  final List<Address> addresses;
  Object? error;

  @override
  Future<Either<Failure, List<Address>>> fetchAddresses({
    String lang = 'ar',
  }) async {
    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(addresses);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTablesRepository implements TablesRepository {
  _FakeTablesRepository(this.tables);

  final List<DiningTable> tables;
  Object? error;

  @override
  Future<Either<Failure, List<DiningTable>>> fetchTables({
    String lang = 'ar',
  }) async {
    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(tables);
  }
}

typedef _CheckoutHarness = ({
  CartCubit cartCubit,
  CheckoutCubit checkoutCubit,
  _FakeOrdersRepository orders,
  _FakeAddressesRepository addresses,
  _FakeTablesRepository tables,
});

Future<_CheckoutHarness> _pumpCheckout(
  WidgetTester tester, {
  String orderType = 'delivery',
  RestaurantSettings? settings,
  List<Address> addresses = const [_address],
  List<DiningTable> tables = const [
    DiningTable(id: 3, name: 'T202'),
    DiningTable(id: 10, name: 'T282'),
  ],
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cartCubit = CartCubit()
    ..add(
      _grill,
      weight: 0.25,
      option: const MenuItemOption(id: 7, name: 'نفر واحد'),
    )
    ..setOrderType(orderType);
  addTearDown(cartCubit.close);

  final quoteCubit = CartQuoteCubit(_FakeQuoteRepository(), cartCubit);
  addTearDown(quoteCubit.close);

  final storeCubit = StoreConfigCubit(
    _FakeSettingsRepository(settings ?? sampleSettingsWithoutImages()),
  );
  addTearDown(storeCubit.close);

  final orders = _FakeOrdersRepository();
  final addressesRepository = _FakeAddressesRepository(addresses);
  final tablesRepository = _FakeTablesRepository(tables);
  final checkoutCubit = CheckoutCubit(
    orders,
    addressesRepository,
    tablesRepository,
  );
  addTearDown(checkoutCubit.close);

  final providers = [
    BlocProvider.value(value: cartCubit),
    BlocProvider.value(value: quoteCubit),
    BlocProvider.value(value: storeCubit),
    BlocProvider.value(value: checkoutCubit),
  ];

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: providers,
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
        home: const CheckoutScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return (
    cartCubit: cartCubit,
    checkoutCubit: checkoutCubit,
    orders: orders,
    addresses: addressesRepository,
    tables: tablesRepository,
  );
}

void main() {
  testWidgets('renders delivery address, payment and the quote totals', (
    tester,
  ) async {
    await _pumpCheckout(tester);

    expect(find.text('إتمام الطلب'), findsOneWidget);
    expect(find.text('بيتي'), findsOneWidget);
    expect(find.text('نقدًا عند الاستلام'), findsOneWidget);
    expect(find.text('نفر واحد'), findsOneWidget);
    expect(find.text('ملخص الطلب'), findsOneWidget);
    expect(find.text('11.213 ر.ق'), findsWidgets);
    expect(find.text('إرسال الطلب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the checkout form visible above the bottom bar', (
    tester,
  ) async {
    await _pumpCheckout(tester);

    final bottomBar = find.byType(CheckoutBottomBar);
    expect(bottomBar, findsOneWidget);
    expect(tester.getSize(bottomBar).height, lessThan(220));
    expect(
      tester.getTopLeft(bottomBar).dy,
      greaterThan(tester.getTopLeft(find.text('بيتي')).dy),
    );
  });

  testWidgets('places a delivery order and shows the confirmation', (
    tester,
  ) async {
    final harness = await _pumpCheckout(tester);

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(harness.orders.calls, 1);
    expect(harness.orders.lastDraft?.orderType, 'delivery');
    expect(harness.orders.lastDraft?.paymentMethod, 'cash');
    expect(harness.orders.lastDraft?.addressId, 5);

    expect(find.text('تم استلام طلبك'), findsOneWidget);
    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(find.text('استلمنا طلبك رقم 12.'), findsOneWidget);
    expect(harness.cartCubit.state.isEmpty, isTrue);
  });

  testWidgets('takeaway hides the address and submits without one', (
    tester,
  ) async {
    final harness = await _pumpCheckout(tester, orderType: 'takeaway');

    expect(find.text('عنوان التوصيل'), findsNothing);
    expect(find.text('بيتي'), findsNothing);

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(harness.orders.calls, 1);
    expect(harness.orders.lastDraft?.orderType, 'takeaway');
    expect(harness.orders.lastDraft?.addressId, isNull);
  });

  testWidgets('dine-in requires a table before it can be submitted', (
    tester,
  ) async {
    final harness = await _pumpCheckout(tester, orderType: 'dine_in');

    expect(find.text('الطاولة'), findsOneWidget);
    expect(find.text('اختر رقم الطاولة'), findsOneWidget);
    expect(find.text('اختر طاولة للمتابعة.'), findsOneWidget);
    expect(find.text('عنوان التوصيل'), findsNothing);

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(harness.orders.calls, 0);
  });

  testWidgets('places a dine-in order with the chosen table', (tester) async {
    final harness = await _pumpCheckout(tester, orderType: 'dine_in');

    final dropdown = find.byType(DropdownButton<int>);
    expect(dropdown, findsOneWidget);
    tester.widget<DropdownButton<int>>(dropdown).onChanged?.call(10);
    await tester.pumpAndSettle();

    expect(find.text('T282'), findsOneWidget);
    expect(find.text('اختر طاولة للمتابعة.'), findsNothing);

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(harness.orders.calls, 1);
    expect(harness.orders.lastDraft?.orderType, 'dine_in');
    expect(harness.orders.lastDraft?.diningTableId, 10);
    expect(harness.orders.lastDraft?.addressId, isNull);
    expect(find.text('تم استلام طلبك'), findsOneWidget);
  });

  testWidgets(
    'switches from dine-in to takeaway from the order-type selector',
    (tester) async {
      final harness = await _pumpCheckout(tester, orderType: 'dine_in');

      final takeawayOption = find.textContaining('استلام من المطعم');
      expect(takeawayOption, findsOneWidget);

      await tester.tap(takeawayOption);
      await tester.pumpAndSettle();

      expect(harness.cartCubit.state.orderType, 'takeaway');
      expect(find.text('الطاولة'), findsNothing);
      expect(find.text('اختر طاولة للمتابعة.'), findsNothing);
    },
  );

  testWidgets('a closed store shows its message and blocks checkout', (
    tester,
  ) async {
    final harness = await _pumpCheckout(tester, settings: _closedSettings());

    expect(find.text('مغلق الآن — نفتح قريبًا'), findsOneWidget);

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(harness.orders.calls, 0);
  });

  testWidgets('shows the address failure with a retry action', (tester) async {
    final harness = await _pumpCheckout(tester);
    harness.addresses.error = ServerFailure('انقطع الاتصال');

    harness.checkoutCubit.loadAddresses(lang: 'ar');
    await tester.pumpAndSettle();

    expect(find.text('انقطع الاتصال'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('shows the submit failure inline', (tester) async {
    final harness = await _pumpCheckout(tester);
    harness.orders.error = ServerFailure('تعذّر إنشاء الطلب');

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(find.text('تعذّر إنشاء الطلب'), findsOneWidget);
    expect(find.text('تم استلام طلبك'), findsNothing);
  });

  testWidgets('fits a narrow screen at 2x text without overflow', (
    tester,
  ) async {
    await _pumpCheckout(tester, size: const Size(320, 640), textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.text('استلام من المطعم'), findsOneWidget);
    expect(find.text('إرسال الطلب'), findsOneWidget);
  });

  testWidgets('fits the dine-in table picker on a narrow 2x screen', (
    tester,
  ) async {
    await _pumpCheckout(
      tester,
      orderType: 'dine_in',
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('الطاولة'), findsOneWidget);
    expect(find.text('إرسال الطلب'), findsOneWidget);
  });

  testWidgets('uses two columns on wide screens', (tester) async {
    await _pumpCheckout(tester, size: const Size(1200, 900));

    expect(tester.takeException(), isNull);
    expect(find.text('مشاوي مشكلة'), findsOneWidget);
    expect(find.text('بيتي'), findsOneWidget);
  });

  testWidgets('switches delivery address from the address dropdown', (
    tester,
  ) async {
    const secondAddress = Address(
      id: 9,
      kind: AddressKind.work,
      kindLabel: 'العمل',
      label: 'مكتبي',
      title: 'مكتبي',
      summary: 'الدفنة، برج السلام',
      deliveryZone: 'الدفنة',
      isDeliverable: true,
      area: 'الدفنة',
      street: 'برج السلام',
      building: '3',
      notes: '',
      point: GeoPoint(latitude: 25.32, longitude: 51.53),
      lastUsedAt: null,
      isDefault: false,
    );

    final harness = await _pumpCheckout(
      tester,
      addresses: const [_address, secondAddress],
    );

    expect(find.text('بيتي'), findsOneWidget);

    final dropdown = find.byType(DropdownButton<int>).first;
    expect(dropdown, findsOneWidget);
    tester.widget<DropdownButton<int>>(dropdown).onChanged?.call(9);
    await tester.pumpAndSettle();

    expect(find.text('مكتبي'), findsOneWidget);
    expect(harness.checkoutCubit.state.selectedAddress?.id, 9);
  });

  testWidgets('shows add address button when there are no saved addresses', (
    tester,
  ) async {
    await _pumpCheckout(tester, addresses: const []);

    expect(find.text('أضف عنوانًا جديدًا'), findsOneWidget);
    expect(find.text('أضف عنوان توصيل لإتمام الطلب.'), findsOneWidget);
  });
}

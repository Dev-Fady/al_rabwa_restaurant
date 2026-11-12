import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/orders_page.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/screens/orders_screen.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/widgets/order_card.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/settings_fixtures.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    return Right(sampleSettingsWithoutImages());
  }
}

typedef _PageBuilder = OrdersPage Function(int page, String status);

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository(this.builder);

  final _PageBuilder builder;
  int calls = 0;
  int? lastPage;
  String? lastStatus;
  Object? error;

  @override
  Future<Either<Failure, OrdersPage>> fetchOrders({
    required int page,
    String status = 'current',
    String lang = 'ar',
  }) async {
    calls++;
    lastPage = page;
    lastStatus = status;

    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }

    return Right(builder(page, status));
  }

  @override
  Future<Either<Failure, Order>> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  }) async {
    return Left(ServerFailure('not used'));
  }

  @override
  Future<Either<Failure, Order>> fetchOrderDetails({
    required int orderId,
    String lang = 'ar',
  }) async {
    return Left(ServerFailure('not used'));
  }
}

Order _order({
  int id = 25,
  int number = 12,
  String type = 'takeaway',
  String status = 'pending',
  String statusLabel = 'جديد',
  String table = '',
  OrderAddress? address,
  String notes = 'Test order - please ignore',
  List<OrderItem>? items,
}) {
  return Order(
    id: id,
    number: number,
    type: OrderTypeInfo(
      value: type,
      label: switch (type) {
        'delivery' => 'توصيل',
        'dine_in' => 'داخل المطعم',
        _ => 'استلام من المطعم',
      },
    ),
    status: OrderStatusInfo(
      value: status,
      label: statusLabel,
      isOpen: true,
      message: 'استلمنا طلبك رقم $number.',
    ),
    payment: const OrderPaymentInfo(
      methodValue: 'cash',
      methodLabel: 'نقدًا',
      statusValue: 'unpaid',
      statusLabel: 'غير مدفوع',
    ),
    customerName: 'أحمد',
    customerPhone: '+974 5555 1234',
    address: address,
    table: table,
    notes: notes,
    subtotal: 9.75,
    tax: 0.975,
    serviceCharge: 0.488,
    total: 11.213,
    createdAt: DateTime.utc(2026, 11, 12, 13, 55, 35),
    items:
        items ??
        const [
          OrderItem(
            itemId: 31,
            name: 'مشاوي مشكلة',
            quantity: 0.25,
            unitPrice: 39,
            total: 9.75,
            options: ['نفر واحد'],
          ),
        ],
  );
}

typedef _OrdersHarness = ({
  OrdersCubit ordersCubit,
  _FakeOrdersRepository repository,
});

Future<_OrdersHarness> _pumpOrders(
  WidgetTester tester, {
  required _FakeOrdersRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
  bool load = true,
  GoRouter? router,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final storeCubit = StoreConfigCubit(_FakeSettingsRepository());
  addTearDown(storeCubit.close);

  final ordersCubit = OrdersCubit(repository);
  addTearDown(ordersCubit.close);

  final app = router == null
      ? MaterialApp(
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
          home: const OrdersScreen(),
        )
      : MaterialApp.router(
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
        );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: storeCubit),
        BlocProvider.value(value: ordersCubit),
      ],
      child: app,
    ),
  );

  if (load) {
    await ordersCubit.load();
    await tester.pumpAndSettle();
  }

  return (ordersCubit: ordersCubit, repository: repository);
}

void main() {
  testWidgets('renders the order summary without opening the details', (
    tester,
  ) async {
    final repository = _FakeOrdersRepository(
      (page, status) =>
          OrdersPage(orders: [_order()], currentPage: 1, lastPage: 1, total: 1),
    );

    await _pumpOrders(tester, repository: repository);

    expect(find.text('طلباتي'), findsOneWidget);
    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.textContaining('استلام من المطعم'), findsOneWidget);
    expect(find.text('11.213 ر.ق'), findsOneWidget);
    expect(find.text('عرض التفاصيل'), findsOneWidget);
    expect(find.text('مشاوي مشكلة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the order details page when a card is tapped', (
    tester,
  ) async {
    final repository = _FakeOrdersRepository(
      (page, status) =>
          OrdersPage(orders: [_order()], currentPage: 1, lastPage: 1, total: 1),
    );
    final router = GoRouter(
      initialLocation: '/orders',
      routes: [
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
          routes: [
            GoRoute(
              path: ':orderId',
              builder: (context, state) => Scaffold(
                body: Text('order ${state.pathParameters['orderId']}'),
              ),
            ),
          ],
        ),
      ],
    );

    await _pumpOrders(tester, repository: repository, router: router);
    await tester.tap(find.text('عرض التفاصيل'));
    await tester.pumpAndSettle();

    expect(find.text('order 25'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches between current and past orders', (tester) async {
    final repository = _FakeOrdersRepository((page, status) {
      if (status == 'past') {
        return OrdersPage(
          orders: [
            _order(
              id: 24,
              number: 11,
              type: 'delivery',
              address: const OrderAddress(
                area: 'السد',
                street: 'شارع 901',
                building: 'مبنى 35، الطابق 2',
              ),
            ),
          ],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        );
      }

      return OrdersPage(
        orders: [_order()],
        currentPage: 1,
        lastPage: 1,
        total: 1,
      );
    });

    await _pumpOrders(tester, repository: repository);

    expect(find.text('طلب رقم 12'), findsOneWidget);

    await tester.tap(find.text('السابقة'));
    await tester.pumpAndSettle();

    expect(repository.lastStatus, 'past');
    expect(find.text('طلب رقم 11'), findsOneWidget);
    expect(find.textContaining('توصيل'), findsOneWidget);
    expect(find.text('السد, شارع 901, مبنى 35، الطابق 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the empty state for the active filter', (tester) async {
    final repository = _FakeOrdersRepository(
      (page, status) => const OrdersPage(currentPage: 1, lastPage: 1, total: 0),
    );

    await _pumpOrders(tester, repository: repository);

    expect(find.text('لا توجد طلبات حالية الآن.'), findsOneWidget);
    expect(find.text('تصفح المنيو'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the failure message and retries the first page', (
    tester,
  ) async {
    final repository = _FakeOrdersRepository(
      (page, status) =>
          OrdersPage(orders: [_order()], currentPage: 1, lastPage: 1, total: 1),
    )..error = ServerFailure('انقطع الاتصال');

    await _pumpOrders(tester, repository: repository);

    expect(find.text('انقطع الاتصال'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(repository.calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loads the next page when the first page is short', (
    tester,
  ) async {
    final repository = _FakeOrdersRepository((page, status) {
      if (page == 1) {
        return OrdersPage(
          orders: [_order()],
          currentPage: 1,
          lastPage: 2,
          total: 2,
        );
      }

      return OrdersPage(
        orders: [_order(id: 24, number: 11)],
        currentPage: 2,
        lastPage: 2,
        total: 2,
      );
    });

    await _pumpOrders(tester, repository: repository);

    expect(repository.calls, greaterThanOrEqualTo(2));
    expect(repository.lastPage, 2);
    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(find.text('طلب رقم 11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays responsive on a small phone with large text', (
    tester,
  ) async {
    final repository = _FakeOrdersRepository(
      (page, status) => OrdersPage(
        orders: [
          _order(
            type: 'delivery',
            address: const OrderAddress(
              area: 'السد',
              street: 'شارع 901',
              building: 'مبنى 35، الطابق 2',
            ),
          ),
        ],
        currentPage: 1,
        lastPage: 1,
        total: 1,
      ),
    );

    await _pumpOrders(
      tester,
      repository: repository,
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers a bounded list on a wide window', (tester) async {
    final repository = _FakeOrdersRepository(
      (page, status) => OrdersPage(
        orders: [_order(), _order(id: 24, number: 11)],
        currentPage: 1,
        lastPage: 1,
        total: 2,
      ),
    );

    await _pumpOrders(
      tester,
      repository: repository,
      size: const Size(1280, 900),
    );

    final card = find.byType(OrderCard).first;
    expect(tester.getSize(card).width, lessThanOrEqualTo(860));
    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(find.text('طلب رقم 11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

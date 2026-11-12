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
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/screens/order_details_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/settings_fixtures.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Either<Failure, RestaurantSettings>> fetchSettings({
    String lang = 'ar',
  }) async {
    return Right(sampleSettingsWithoutImages());
  }
}

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository({this.order});

  Order? order;
  Object? error;
  int calls = 0;
  int? lastOrderId;
  String? lastLang;

  @override
  Future<Either<Failure, Order>> fetchOrderDetails({
    required int orderId,
    String lang = 'ar',
  }) async {
    calls++;
    lastOrderId = orderId;
    lastLang = lang;

    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(order ?? _order());
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
  Future<Either<Failure, OrdersPage>> fetchOrders({
    required int page,
    String status = 'current',
    String lang = 'ar',
  }) async {
    return const Right(OrdersPage());
  }
}

Order _order() {
  return Order(
    id: 25,
    number: 12,
    type: const OrderTypeInfo(value: 'delivery', label: 'توصيل'),
    status: const OrderStatusInfo(
      value: 'pending',
      label: 'جديد',
      isOpen: true,
      message: 'استلمنا طلبك رقم 12.',
    ),
    payment: const OrderPaymentInfo(
      methodValue: 'cash',
      methodLabel: 'نقدًا',
      statusValue: 'unpaid',
      statusLabel: 'غير مدفوع',
    ),
    customerName: 'أحمد',
    customerPhone: '+974 5555 1234',
    address: const OrderAddress(
      area: 'السد',
      street: 'شارع 901',
      building: 'مبنى 35',
      notes: 'الباب الأخضر',
    ),
    table: 'T87',
    carNumber: 'Q-123',
    companyName: 'شركة الربوة',
    notes: 'Test order - please ignore',
    couponCode: 'SAVE10',
    subtotal: 9.75,
    tax: 0.975,
    serviceCharge: 0.488,
    total: 11.213,
    createdAt: DateTime.utc(2026, 11, 12, 13, 55, 35),
    items: const [
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

Future<OrderDetailsCubit> _pumpDetails(
  WidgetTester tester, {
  required _FakeOrdersRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
  bool load = true,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final storeCubit = StoreConfigCubit(_FakeSettingsRepository());
  addTearDown(storeCubit.close);

  final detailsCubit = OrderDetailsCubit(repository, 25);
  addTearDown(detailsCubit.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: storeCubit),
        BlocProvider.value(value: detailsCubit),
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
        home: const OrderDetailsScreen(),
      ),
    ),
  );

  if (load) {
    await detailsCubit.load();
    await tester.pumpAndSettle();
  }

  return detailsCubit;
}

void main() {
  testWidgets('renders the order, customer, items and totals', (tester) async {
    final repository = _FakeOrdersRepository(order: _order());

    await _pumpDetails(tester, repository: repository);

    expect(find.text('تفاصيل الطلب'), findsOneWidget);
    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('استلمنا طلبك رقم 12.'), findsOneWidget);
    expect(find.text('أحمد'), findsOneWidget);
    expect(find.text('+974 5555 1234'), findsOneWidget);
    expect(find.textContaining('السد, شارع 901'), findsOneWidget);
    expect(find.textContaining('T87'), findsOneWidget);
    expect(find.textContaining('Q-123'), findsOneWidget);
    expect(find.textContaining('شركة الربوة'), findsOneWidget);
    expect(find.text('مشاوي مشكلة'), findsOneWidget);
    expect(find.text('نفر واحد'), findsOneWidget);
    expect(find.text('Test order - please ignore'), findsOneWidget);
    expect(find.text('نقدًا'), findsOneWidget);
    expect(find.text('غير مدفوع'), findsOneWidget);
    expect(find.textContaining('SAVE10'), findsOneWidget);
    expect(find.text('9.750 ر.ق'), findsNWidgets(2));
    expect(find.text('0.975 ر.ق'), findsOneWidget);
    expect(find.text('0.488 ر.ق'), findsOneWidget);
    expect(find.text('11.213 ر.ق'), findsOneWidget);
    expect(repository.lastOrderId, 25);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the failure message and retries', (tester) async {
    final repository = _FakeOrdersRepository()
      ..error = ServerFailure('تعذّر تحميل تفاصيل الطلب');

    final cubit = await _pumpDetails(tester, repository: repository);

    expect(find.text('تعذّر تحميل تفاصيل الطلب'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(repository.calls, 2);
    expect(cubit.state.hasOrder, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a spinner while the order loads', (tester) async {
    final repository = _FakeOrdersRepository(order: _order());

    await _pumpDetails(tester, repository: repository, load: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays responsive on a small phone with large text', (
    tester,
  ) async {
    final repository = _FakeOrdersRepository(order: _order());

    await _pumpDetails(
      tester,
      repository: repository,
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers a bounded page on a wide window', (tester) async {
    final repository = _FakeOrdersRepository(order: _order());

    await _pumpDetails(
      tester,
      repository: repository,
      size: const Size(1280, 900),
    );

    final list = find.byType(ListView);
    final contentLeft = tester.getTopLeft(find.text('طلب رقم 12')).dx;
    expect(list, findsOneWidget);
    expect(contentLeft, greaterThan(280));
    expect(find.text('طلب رقم 12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

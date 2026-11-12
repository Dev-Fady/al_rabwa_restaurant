import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_state.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/orders/data/models/order_response.dart';
import 'package:al_rabwa_restaurant/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/repositories/tables_repository.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

/// Response copied from `POST /api/orders?lang=ar`.
Map<String, dynamic> orderPayload() {
  return {
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
      'customer_name': 'أحمد',
      'customer_phone': '+974 5555 1234',
      'address': null,
      'table': null,
      'car_number': null,
      'company_name': null,
      'notes': 'Test order - please ignore',
      'coupon_code': null,
      'subtotal': 9.75,
      'discount': 0,
      'tax': 0.975,
      'service_charge': 0.488,
      'delivery_fee': 0,
      'total': 11.213,
      'created_at': '2026-11-12T13:55:35+00:00',
      'items': [
        {
          'item_id': 31,
          'name': 'مشاوي مشكلة',
          'image':
              'https://sync2027.smartmenues.com/storage/restaurants/1/demo/mixed.jpg',
          'quantity': 0.25,
          'unit_price': 39,
          'total': 9.75,
          'note': null,
          'options': ['نفر واحد'],
          'addons': <dynamic>[],
        },
      ],
    },
  };
}

Order sampleOrder() => OrderResponse.fromJson(orderPayload()).toEntity()!;

const _grill = MenuItem(
  id: 31,
  name: 'مشاوي مشكلة',
  price: 39,
  soldByWeight: true,
  options: [MenuItemOption(id: 7, name: 'نفر واحد')],
);

const _chicken = MenuItem(id: 40, name: 'دجاج مسحب', price: 35);

Cart weightedCart() {
  return const Cart().add(
    _grill,
    weight: 0.25,
    option: const MenuItemOption(id: 7, name: 'نفر واحد'),
  );
}

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

class _FakeApiService implements ApiService {
  _FakeApiService({required this.payload});

  dynamic payload;
  Object? error;
  Map<String, dynamic>? lastBody;
  String? lastLang;
  String? lastLocale;
  String? lastIdempotencyKey;

  @override
  Future<HttpResponse<dynamic>> createOrder({
    required Map<String, dynamic> body,
    required String idempotencyKey,
    String? lang,
    String? xLocale,
  }) async {
    lastBody = body;
    lastLang = lang;
    lastLocale = xLocale;
    lastIdempotencyKey = idempotencyKey;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'orders'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  _FakeOrdersRemoteDataSource({this.order});

  Order? order;
  Object? error;
  Cart? lastCart;
  OrderDraft? lastDraft;
  String? lastLang;
  String? lastIdempotencyKey;

  @override
  Future<Order> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  }) async {
    lastCart = cart;
    lastDraft = draft;
    lastLang = lang;
    lastIdempotencyKey = idempotencyKey;

    final failure = error;
    if (failure != null) throw failure;
    return order ?? sampleOrder();
  }
}

class _FakeAddressesRepository implements AddressesRepository {
  _FakeAddressesRepository({this.addresses = const []});

  List<Address> addresses;
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
  _FakeTablesRepository({this.tables = const []});

  List<DiningTable> tables;
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

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository({this.order});

  Order? order;
  Object? error;
  int calls = 0;
  Cart? lastCart;
  OrderDraft? lastDraft;
  String? lastLang;
  String? lastIdempotencyKey;

  @override
  Future<Either<Failure, Order>> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  }) async {
    calls++;
    lastCart = cart;
    lastDraft = draft;
    lastLang = lang;
    lastIdempotencyKey = idempotencyKey;

    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(order ?? sampleOrder());
  }
}

void main() {
  group('OrderResponse', () {
    test('maps the created order, its totals and its items', () {
      final order = sampleOrder();

      expect(order.id, 25);
      expect(order.number, 12);
      expect(order.displayNumber, 12);
      expect(order.type.value, 'takeaway');
      expect(order.type.displayLabel, 'استلام من المطعم');
      expect(order.status.value, 'pending');
      expect(order.status.label, 'جديد');
      expect(order.status.isOpen, isTrue);
      expect(order.status.message, 'استلمنا طلبك رقم 12.');
      expect(order.payment.methodValue, 'cash');
      expect(order.payment.displayMethod, 'نقدًا');
      expect(order.payment.statusValue, 'unpaid');
      expect(order.payment.displayStatus, 'غير مدفوع');
      expect(order.customerName, 'أحمد');
      expect(order.notes, 'Test order - please ignore');
      expect(order.subtotal, 9.75);
      expect(order.tax, 0.975);
      expect(order.serviceCharge, 0.488);
      expect(order.total, 11.213);
      expect(order.createdAt, DateTime.utc(2026, 11, 12, 13, 55, 35));
      expect(order.items, hasLength(1));
      expect(order.items.single.itemId, 31);
      expect(order.items.single.quantity, 0.25);
      expect(order.items.single.options, ['نفر واحد']);
      expect(order.items.single.hasAddons, isFalse);
    });

    test('falls back to the id and keeps object-shaped option names', () {
      final payload = orderPayload();
      final data = payload['data'] as Map<String, dynamic>;
      data.remove('number');
      (data['items'] as List<dynamic>).single['options'] = [
        {'name': 'نفر واحد'},
      ];

      final order = OrderResponse.fromJson(payload).toEntity()!;

      expect(order.displayNumber, 25);
      expect(order.items.single.options, ['نفر واحد']);
    });
  });

  group('OrdersRemoteDataSource', () {
    test('sends a delivery order with its address and weight line', () async {
      final api = _FakeApiService(payload: orderPayload());
      final dataSource = OrdersRemoteDataSourceImpl(apiService: api);

      final order = await dataSource.createOrder(
        cart: weightedCart(),
        draft: const OrderDraft(
          orderType: 'delivery',
          paymentMethod: 'cash',
          addressId: 5,
          notes: '  Test order - please ignore  ',
        ),
        idempotencyKey: 'order-key-1',
        lang: 'ar',
      );

      expect(order.id, 25);
      expect(api.lastLang, 'ar');
      expect(api.lastLocale, 'ar');
      expect(api.lastIdempotencyKey, 'order-key-1');
      expect(api.lastBody?['type'], 'delivery');
      expect(api.lastBody?['payment_method'], 'cash');
      expect(api.lastBody?['address_id'], 5);
      expect(api.lastBody?['notes'], 'Test order - please ignore');

      final line =
          (api.lastBody?['lines'] as List<dynamic>).single
              as Map<String, dynamic>;
      expect(line['item_id'], 31);
      expect(line['option_id'], 7);
      expect(line['addons'], isEmpty);
      expect(line['quantity'], 0.25);
      expect(line['note'], isNull);
    });

    test('sends a takeaway order without an address', () async {
      final api = _FakeApiService(payload: orderPayload());
      final dataSource = OrdersRemoteDataSourceImpl(apiService: api);
      final cart = const Cart().add(
        _chicken,
        quantity: 2,
        notes: 'بدون بصل',
        addons: [const MenuItemAddon(id: 34, name: 'إضافة أرز', price: 5)],
      );

      await dataSource.createOrder(
        cart: cart,
        draft: const OrderDraft(
          orderType: 'takeaway',
          paymentMethod: 'cash',
          addressId: 5,
        ),
        idempotencyKey: 'order-key-2',
        lang: 'en',
      );

      expect(api.lastBody?['type'], 'takeaway');
      expect(api.lastBody?.containsKey('address_id'), isFalse);
      expect(api.lastBody?.containsKey('notes'), isFalse);

      final line =
          (api.lastBody?['lines'] as List<dynamic>).single
              as Map<String, dynamic>;
      expect(line['quantity'], 2);
      expect(line['addons'], [34]);
      expect(line['note'], 'بدون بصل');
      expect(api.lastLang, 'en');
    });

    test('sends a dine-in order with its table and no address', () async {
      final api = _FakeApiService(payload: orderPayload());
      final dataSource = OrdersRemoteDataSourceImpl(apiService: api);

      await dataSource.createOrder(
        cart: weightedCart(),
        draft: const OrderDraft(
          orderType: 'dine_in',
          paymentMethod: 'cash',
          diningTableId: 3,
          addressId: 5,
        ),
        idempotencyKey: 'order-key-4',
      );

      expect(api.lastBody?['type'], 'dine_in');
      expect(api.lastBody?['dining_table_id'], 3);
      expect(api.lastBody?.containsKey('address_id'), isFalse);
    });

    test('surfaces the backend message when success is false', () async {
      final payload = orderPayload();
      payload['success'] = false;
      payload['message'] = 'العنوان خارج نطاق التوصيل';
      final dataSource = OrdersRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: payload),
      );

      await expectLater(
        dataSource.createOrder(
          cart: weightedCart(),
          draft: const OrderDraft(
            orderType: 'delivery',
            paymentMethod: 'cash',
            addressId: 5,
          ),
          idempotencyKey: 'order-key-3',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'العنوان خارج نطاق التوصيل',
          ),
        ),
      );
    });
  });

  group('OrdersRepository', () {
    test('returns the created order', () async {
      final remote = _FakeOrdersRemoteDataSource(order: sampleOrder());
      final repository = OrdersRepositoryImpl(remoteDataSource: remote);

      final result = await repository.createOrder(
        cart: weightedCart(),
        draft: const OrderDraft(
          orderType: 'delivery',
          paymentMethod: 'cash',
          addressId: 5,
        ),
        idempotencyKey: 'repo-key',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected a created order'),
        (order) => expect(order.number, 12),
      );
      expect(remote.lastDraft?.addressId, 5);
      expect(remote.lastIdempotencyKey, 'repo-key');
    });

    test('maps a network error to a server failure', () async {
      final remote = _FakeOrdersRemoteDataSource()
        ..error = DioException(
          requestOptions: RequestOptions(path: 'orders'),
          type: DioExceptionType.connectionError,
        );
      final repository = OrdersRepositoryImpl(remoteDataSource: remote);

      final result = await repository.createOrder(
        cart: weightedCart(),
        draft: const OrderDraft(orderType: 'takeaway', paymentMethod: 'cash'),
        idempotencyKey: 'repo-key',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('CheckoutCubit', () {
    test('loads addresses and selects the default one', () async {
      final cubit = CheckoutCubit(
        _FakeOrdersRepository(),
        _FakeAddressesRepository(addresses: const [_address]),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);

      await cubit.loadAddresses(lang: 'ar');

      expect(cubit.state.addressStatus, CheckoutAddressStatus.success);
      expect(cubit.state.hasAddresses, isTrue);
      expect(cubit.state.selectedAddress?.id, 5);
    });

    test('keeps the failure message when addresses cannot load', () async {
      final cubit = CheckoutCubit(
        _FakeOrdersRepository(),
        _FakeAddressesRepository()..error = ServerFailure('انقطع الاتصال'),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);

      await cubit.loadAddresses(lang: 'ar');

      expect(cubit.state.addressStatus, CheckoutAddressStatus.failure);
      expect(cubit.state.hasAddressError, isTrue);
      expect(cubit.state.addressError, 'انقطع الاتصال');
    });

    test('loads the dine-in tables without preselecting one', () async {
      final tables = _FakeTablesRepository(
        tables: const [
          DiningTable(id: 3, name: 'T202'),
          DiningTable(id: 10, name: 'T282'),
        ],
      );
      final cubit = CheckoutCubit(
        _FakeOrdersRepository(),
        _FakeAddressesRepository(),
        tables,
      );
      addTearDown(cubit.close);

      await cubit.loadTables(lang: 'ar');

      expect(cubit.state.tableStatus, CheckoutTableStatus.success);
      expect(cubit.state.hasTables, isTrue);
      expect(cubit.state.selectedTable, isNull);
    });

    test('keeps the chosen table when the list refreshes', () async {
      final tables = _FakeTablesRepository(
        tables: const [
          DiningTable(id: 3, name: 'T202'),
          DiningTable(id: 10, name: 'T282'),
        ],
      );
      final cubit = CheckoutCubit(
        _FakeOrdersRepository(),
        _FakeAddressesRepository(),
        tables,
      );
      addTearDown(cubit.close);

      await cubit.loadTables(lang: 'ar');
      cubit.selectTable(const DiningTable(id: 10, name: 'T282'));
      await cubit.loadTables(lang: 'ar');

      expect(cubit.state.selectedTable?.id, 10);
    });

    test('drops the chosen table when it disappears', () async {
      final tables = _FakeTablesRepository(
        tables: const [
          DiningTable(id: 3, name: 'T202'),
          DiningTable(id: 10, name: 'T282'),
        ],
      );
      final cubit = CheckoutCubit(
        _FakeOrdersRepository(),
        _FakeAddressesRepository(),
        tables,
      );
      addTearDown(cubit.close);

      await cubit.loadTables(lang: 'ar');
      cubit.selectTable(const DiningTable(id: 10, name: 'T282'));
      tables.tables = const [DiningTable(id: 3, name: 'T202')];
      await cubit.loadTables(lang: 'ar');

      expect(cubit.state.selectedTable, isNull);
    });

    test('keeps the failure message when tables cannot load', () async {
      final tables = _FakeTablesRepository()
        ..error = ServerFailure('تعذّر تحميل الطاولات');
      final cubit = CheckoutCubit(
        _FakeOrdersRepository(),
        _FakeAddressesRepository(),
        tables,
      );
      addTearDown(cubit.close);

      await cubit.loadTables(lang: 'ar');

      expect(cubit.state.tableStatus, CheckoutTableStatus.failure);
      expect(cubit.state.hasTableError, isTrue);
      expect(cubit.state.tableError, 'تعذّر تحميل الطاولات');
    });

    test('submits the order and exposes the confirmation', () async {
      final orders = _FakeOrdersRepository(order: sampleOrder());
      final cubit = CheckoutCubit(
        orders,
        _FakeAddressesRepository(),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);
      const draft = OrderDraft(
        orderType: 'delivery',
        paymentMethod: 'cash',
        addressId: 5,
        notes: 'Test order - please ignore',
      );

      await cubit.submit(cart: weightedCart(), draft: draft, lang: 'ar');

      expect(cubit.state.submitStatus, CheckoutSubmitStatus.success);
      expect(cubit.state.hasOrder, isTrue);
      expect(cubit.state.order?.number, 12);
      expect(orders.lastDraft?.notes, 'Test order - please ignore');
      expect(orders.lastLang, 'ar');
    });

    test('reuses the idempotency key when retrying the same order', () async {
      final orders = _FakeOrdersRepository()
        ..error = ServerFailure('رفض الطلب');
      final cubit = CheckoutCubit(
        orders,
        _FakeAddressesRepository(),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);
      const draft = OrderDraft(orderType: 'takeaway', paymentMethod: 'cash');

      await cubit.submit(cart: weightedCart(), draft: draft);
      final firstKey = orders.lastIdempotencyKey;
      expect(firstKey, isNotNull);

      orders.error = null;
      await cubit.submit(cart: weightedCart(), draft: draft);

      expect(orders.calls, 2);
      expect(orders.lastIdempotencyKey, firstKey);
    });

    test('generates a new idempotency key for the next order', () async {
      final orders = _FakeOrdersRepository(order: sampleOrder());
      final cubit = CheckoutCubit(
        orders,
        _FakeAddressesRepository(),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);
      const draft = OrderDraft(orderType: 'takeaway', paymentMethod: 'cash');

      await cubit.submit(cart: weightedCart(), draft: draft);
      final firstKey = orders.lastIdempotencyKey;

      await cubit.submit(cart: weightedCart(), draft: draft);

      expect(orders.calls, 2);
      expect(orders.lastIdempotencyKey, isNot(firstKey));
    });

    test('keeps the failure message when the order is rejected', () async {
      final orders = _FakeOrdersRepository()
        ..error = ServerFailure('رفض الطلب');
      final cubit = CheckoutCubit(
        orders,
        _FakeAddressesRepository(),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);

      await cubit.submit(
        cart: weightedCart(),
        draft: const OrderDraft(orderType: 'takeaway', paymentMethod: 'cash'),
      );

      expect(cubit.state.submitStatus, CheckoutSubmitStatus.failure);
      expect(cubit.state.hasSubmitError, isTrue);
      expect(cubit.state.submitError, 'رفض الطلب');
      expect(cubit.state.hasOrder, isFalse);
    });

    test('does not send a second request while submitting', () async {
      final orders = _FakeOrdersRepository(order: sampleOrder());
      final cubit = CheckoutCubit(
        orders,
        _FakeAddressesRepository(),
        _FakeTablesRepository(),
      );
      addTearDown(cubit.close);
      const draft = OrderDraft(orderType: 'takeaway', paymentMethod: 'cash');

      final first = cubit.submit(cart: weightedCart(), draft: draft);
      final second = cubit.submit(cart: weightedCart(), draft: draft);
      await Future.wait([first, second]);

      expect(orders.calls, 1);
    });
  });
}

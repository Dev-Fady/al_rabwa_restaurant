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
import 'package:al_rabwa_restaurant/features/orders/domain/entities/orders_page.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/order_details_state.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/orders_state.dart';
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

/// Response copied from `GET /api/orders?lang=ar&status=current&page=1`.
Map<String, dynamic> orderListPayload({
  int page = 1,
  int lastPage = 1,
  int total = 5,
  List<Map<String, dynamic>>? data,
}) {
  final orders = data ?? [orderPayload()['data'] as Map<String, dynamic>];

  return {
    'data': orders,
    'links': {
      'first': 'https://sync2027.smartmenues.com/api/orders?page=1',
      'last': 'https://sync2027.smartmenues.com/api/orders?page=$lastPage',
      'prev': null,
      'next': page < lastPage
          ? 'https://sync2027.smartmenues.com/api/orders?page=${page + 1}'
          : null,
    },
    'meta': {
      'current_page': page,
      'from': 1,
      'last_page': lastPage,
      'links': <dynamic>[],
      'path': 'https://sync2027.smartmenues.com/api/orders',
      'per_page': 20,
      'to': orders.length,
      'total': total,
    },
  };
}

Order testOrder(int id, {int? number, String type = 'takeaway'}) {
  return Order(
    id: id,
    number: number ?? id,
    type: OrderTypeInfo(
      value: type,
      label: type == 'delivery' ? 'توصيل' : 'استلام من المطعم',
    ),
    status: const OrderStatusInfo(value: 'pending', label: 'جديد'),
    payment: const OrderPaymentInfo(
      methodValue: 'cash',
      methodLabel: 'نقدًا',
      statusValue: 'unpaid',
      statusLabel: 'غير مدفوع',
    ),
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
  int? lastOrdersPage;
  String? lastOrdersStatus;
  int? lastOrderId;

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
  Future<HttpResponse<dynamic>> getOrders({
    String? lang,
    String? status,
    int? page,
    String? xLocale,
  }) async {
    lastLang = lang;
    lastLocale = xLocale;
    lastOrdersStatus = status;
    lastOrdersPage = page;

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
  Future<HttpResponse<dynamic>> getOrderDetails({
    required int orderId,
    String? lang,
    String? xLocale,
  }) async {
    lastOrderId = orderId;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'orders/$orderId'),
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
  OrdersPage? ordersPage;
  Object? error;
  Cart? lastCart;
  OrderDraft? lastDraft;
  String? lastLang;
  String? lastIdempotencyKey;
  int? lastOrdersPage;
  String? lastOrdersStatus;
  String? lastOrdersLang;
  int? lastOrderId;
  String? lastOrderDetailsLang;

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

  @override
  Future<OrdersPage> fetchOrders({
    required int page,
    String status = 'current',
    String lang = 'ar',
  }) async {
    lastOrdersPage = page;
    lastOrdersStatus = status;
    lastOrdersLang = lang;

    final failure = error;
    if (failure != null) throw failure;
    return ordersPage ?? const OrdersPage();
  }

  @override
  Future<Order> fetchOrderDetails({
    required int orderId,
    String lang = 'ar',
  }) async {
    lastOrderId = orderId;
    lastOrderDetailsLang = lang;

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
  OrdersPage? ordersPage;
  Object? error;
  Object? fetchError;
  int calls = 0;
  int fetchCalls = 0;
  Cart? lastCart;
  OrderDraft? lastDraft;
  String? lastLang;
  String? lastIdempotencyKey;
  int? lastPage;
  String? lastStatus;
  String? lastFetchLang;
  int? lastDetailsOrderId;
  String? lastDetailsLang;

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

  @override
  Future<Either<Failure, OrdersPage>> fetchOrders({
    required int page,
    String status = 'current',
    String lang = 'ar',
  }) async {
    fetchCalls++;
    lastPage = page;
    lastStatus = status;
    lastFetchLang = lang;

    final failure = fetchError;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(ordersPage ?? const OrdersPage());
  }

  @override
  Future<Either<Failure, Order>> fetchOrderDetails({
    required int orderId,
    String lang = 'ar',
  }) async {
    lastDetailsOrderId = orderId;
    lastDetailsLang = lang;

    final failure = fetchError ?? error;
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

  group('OrderListResponse', () {
    test('maps the orders and pagination meta', () {
      final page = OrderListResponse.fromJson(
        orderListPayload(lastPage: 3, total: 42),
      ).toEntity();

      expect(page.orders, hasLength(1));
      expect(page.orders.single.number, 12);
      expect(page.currentPage, 1);
      expect(page.lastPage, 3);
      expect(page.total, 42);
      expect(page.hasMore, isTrue);
      expect(page.isEmpty, isFalse);
    });

    test('maps delivery address, table and corporate fields', () {
      final data = orderPayload()['data'] as Map<String, dynamic>;
      data['address'] = {
        'area': 'السد',
        'street': 'شارع 901',
        'building': 'مبنى 35، الطابق 2',
        'notes': 'الباب الأخضر',
        'latitude': 25.2854,
        'longitude': 51.531,
      };
      data['table'] = 'T87';
      data['car_number'] = 'Q-123';
      data['company_name'] = 'شركة الربوة';

      final order = OrderResponse.fromJson({'data': data}).toEntity()!;

      expect(order.hasAddress, isTrue);
      expect(order.address!.area, 'السد');
      expect(order.address!.summary, 'السد, شارع 901, مبنى 35، الطابق 2');
      expect(order.hasTable, isTrue);
      expect(order.table, 'T87');
      expect(order.hasCarNumber, isTrue);
      expect(order.carNumber, 'Q-123');
      expect(order.companyName, 'شركة الربوة');
    });

    test('treats a missing data list as an empty page', () {
      final page = OrderListResponse.fromJson({
        'meta': {'current_page': 2, 'last_page': 4, 'total': 80},
      }).toEntity();

      expect(page.orders, isEmpty);
      expect(page.isEmpty, isTrue);
      expect(page.currentPage, 2);
      expect(page.lastPage, 4);
      expect(page.total, 80);
      expect(page.hasMore, isTrue);
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

    test('fetches a page with the requested status and language', () async {
      final api = _FakeApiService(
        payload: orderListPayload(page: 2, lastPage: 3, total: 42),
      );
      final dataSource = OrdersRemoteDataSourceImpl(apiService: api);

      final page = await dataSource.fetchOrders(
        page: 2,
        status: 'past',
        lang: 'en',
      );

      expect(page.currentPage, 2);
      expect(page.lastPage, 3);
      expect(page.total, 42);
      expect(page.orders.single.number, 12);
      expect(api.lastOrdersPage, 2);
      expect(api.lastOrdersStatus, 'past');
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
    });

    test('surfaces the backend message when the history fails', () async {
      final payload = orderListPayload();
      payload['success'] = false;
      payload['message'] = 'انتهت الجلسة';
      final dataSource = OrdersRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: payload),
      );

      await expectLater(
        dataSource.fetchOrders(page: 1),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'انتهت الجلسة',
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

    test('returns the requested order page', () async {
      final remote = _FakeOrdersRemoteDataSource()
        ..ordersPage = const OrdersPage(
          orders: [Order(id: 25, number: 12)],
          currentPage: 2,
          lastPage: 3,
          total: 42,
        );
      final repository = OrdersRepositoryImpl(remoteDataSource: remote);

      final result = await repository.fetchOrders(
        page: 2,
        status: 'past',
        lang: 'en',
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected an order page'), (page) {
        expect(page.orders.single.number, 12);
        expect(page.currentPage, 2);
        expect(page.lastPage, 3);
        expect(page.total, 42);
      });
      expect(remote.lastOrdersPage, 2);
      expect(remote.lastOrdersStatus, 'past');
      expect(remote.lastOrdersLang, 'en');
    });

    test('maps a history network error to a server failure', () async {
      final remote = _FakeOrdersRemoteDataSource()
        ..error = DioException(
          requestOptions: RequestOptions(path: 'orders'),
          type: DioExceptionType.connectionError,
        );
      final repository = OrdersRepositoryImpl(remoteDataSource: remote);

      final result = await repository.fetchOrders(page: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('OrderDetails', () {
    test('fetches one order with the requested id and language', () async {
      final api = _FakeApiService(payload: orderPayload());
      final dataSource = OrdersRemoteDataSourceImpl(apiService: api);

      final order = await dataSource.fetchOrderDetails(orderId: 25, lang: 'en');

      expect(order.id, 25);
      expect(order.number, 12);
      expect(order.items.single.name, 'مشاوي مشكلة');
      expect(api.lastOrderId, 25);
      expect(api.lastLang, 'en');
      expect(api.lastLocale, 'en');
    });

    test('surfaces the backend message when the order cannot load', () async {
      final payload = orderPayload();
      payload['success'] = false;
      payload['message'] = 'الطلب غير موجود';
      final dataSource = OrdersRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: payload),
      );

      await expectLater(
        dataSource.fetchOrderDetails(orderId: 99),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'الطلب غير موجود',
          ),
        ),
      );
    });

    test('rejects an empty order body', () async {
      final dataSource = OrdersRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: <String, dynamic>{}),
      );

      await expectLater(
        dataSource.fetchOrderDetails(orderId: 99),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('repository returns the order and forwards the language', () async {
      final remote = _FakeOrdersRemoteDataSource(order: sampleOrder());
      final repository = OrdersRepositoryImpl(remoteDataSource: remote);

      final result = await repository.fetchOrderDetails(
        orderId: 25,
        lang: 'en',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected the order'),
        (order) => expect(order.number, 12),
      );
      expect(remote.lastOrderId, 25);
      expect(remote.lastOrderDetailsLang, 'en');
    });

    test('repository maps a network error to a server failure', () async {
      final remote = _FakeOrdersRemoteDataSource()
        ..error = DioException(
          requestOptions: RequestOptions(path: 'orders/25'),
          type: DioExceptionType.connectionError,
        );
      final repository = OrdersRepositoryImpl(remoteDataSource: remote);

      final result = await repository.fetchOrderDetails(orderId: 25);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('OrderDetailsCubit', () {
    test('emits loading then the requested order', () async {
      final repository = _FakeOrdersRepository(order: sampleOrder());
      final cubit = OrderDetailsCubit(repository, 25, lang: 'en');
      addTearDown(cubit.close);

      final loading = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OrderDetailsState>().having(
            (state) => state.status,
            'status',
            OrdersStatus.loading,
          ),
          isA<OrderDetailsState>()
              .having((state) => state.status, 'status', OrdersStatus.success)
              .having((state) => state.order?.number, 'order number', 12),
        ]),
      );

      await cubit.load();
      await loading;

      expect(cubit.state.hasOrder, isTrue);
      expect(repository.lastDetailsOrderId, 25);
      expect(repository.lastDetailsLang, 'en');
    });

    test('keeps the API message when the order fails to load', () async {
      final repository = _FakeOrdersRepository()
        ..fetchError = ServerFailure('الطلب غير موجود');
      final cubit = OrderDetailsCubit(repository, 99);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, OrdersStatus.failure);
      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.errorMessage, 'الطلب غير موجود');
    });

    test('retries the request after a failure', () async {
      final repository = _FakeOrdersRepository()
        ..fetchError = ServerFailure('انقطع الاتصال');
      final cubit = OrderDetailsCubit(repository, 25);
      addTearDown(cubit.close);

      await cubit.load();
      repository
        ..fetchError = null
        ..order = sampleOrder();
      await cubit.retry();

      expect(cubit.state.status, OrdersStatus.success);
      expect(cubit.state.order?.id, 25);
      expect(repository.lastDetailsOrderId, 25);
    });

    test('reloads the order when the language changes', () async {
      final repository = _FakeOrdersRepository(order: sampleOrder());
      final cubit = OrderDetailsCubit(repository, 25);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.load(lang: 'en');

      expect(cubit.state.lang, 'en');
      expect(repository.lastDetailsLang, 'en');
    });
  });

  group('OrdersCubit', () {
    test('loads the first page and exposes the pagination state', () async {
      final repository = _FakeOrdersRepository()
        ..ordersPage = OrdersPage(
          orders: [sampleOrder()],
          currentPage: 1,
          lastPage: 3,
          total: 42,
        );
      final cubit = OrdersCubit(repository, lang: 'en');
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, OrdersStatus.success);
      expect(cubit.state.orders, hasLength(1));
      expect(cubit.state.orders.single.number, 12);
      expect(cubit.state.currentPage, 1);
      expect(cubit.state.lastPage, 3);
      expect(cubit.state.total, 42);
      expect(cubit.state.hasMore, isTrue);
      expect(repository.lastPage, 1);
      expect(repository.lastStatus, 'current');
      expect(repository.lastFetchLang, 'en');
    });

    test('appends the next page without duplicating orders', () async {
      final repository = _FakeOrdersRepository()
        ..ordersPage = OrdersPage(
          orders: [sampleOrder()],
          currentPage: 1,
          lastPage: 2,
          total: 2,
        );
      final cubit = OrdersCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      repository.ordersPage = OrdersPage(
        orders: [sampleOrder(), testOrder(24, number: 11)],
        currentPage: 2,
        lastPage: 2,
        total: 2,
      );
      await cubit.loadMore();

      expect(cubit.state.orders.map((order) => order.id), [25, 24]);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(repository.lastPage, 2);
    });

    test('does not request a page beyond the last one', () async {
      final repository = _FakeOrdersRepository()
        ..ordersPage = OrdersPage(
          orders: [sampleOrder()],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        );
      final cubit = OrdersCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.loadMore();

      expect(repository.fetchCalls, 1);
    });

    test('switching the filter reloads from the first page', () async {
      final repository = _FakeOrdersRepository()
        ..ordersPage = OrdersPage(
          orders: [sampleOrder()],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        );
      final cubit = OrdersCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      repository.ordersPage = OrdersPage(
        orders: [testOrder(24, number: 11)],
        currentPage: 1,
        lastPage: 1,
        total: 1,
      );
      await cubit.changeFilter(OrdersFilter.past);

      expect(cubit.state.filter, OrdersFilter.past);
      expect(cubit.state.orders.single.id, 24);
      expect(repository.lastPage, 1);
      expect(repository.lastStatus, 'past');
    });

    test('keeps the failure message when the first page fails', () async {
      final repository = _FakeOrdersRepository()
        ..fetchError = ServerFailure('انقطع الاتصال');
      final cubit = OrdersCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, OrdersStatus.failure);
      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.errorMessage, 'انقطع الاتصال');
    });

    test('keeps the visible orders when loading more fails', () async {
      final repository = _FakeOrdersRepository()
        ..ordersPage = OrdersPage(
          orders: [sampleOrder()],
          currentPage: 1,
          lastPage: 2,
          total: 2,
        );
      final cubit = OrdersCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      repository.fetchError = ServerFailure('تعذّر تحميل المزيد');
      await cubit.loadMore();

      expect(cubit.state.orders, hasLength(1));
      expect(cubit.state.hasLoadMoreError, isTrue);
      expect(cubit.state.loadMoreError, 'تعذّر تحميل المزيد');
      expect(cubit.state.isLoadingMore, isFalse);
    });

    test('refreshes the first page without blanking the list', () async {
      final repository = _FakeOrdersRepository()
        ..ordersPage = OrdersPage(
          orders: [sampleOrder()],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        );
      final cubit = OrdersCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      final refreshed = cubit.refresh();

      expect(cubit.state.isRefreshing, isTrue);
      expect(cubit.state.orders, hasLength(1));

      await refreshed;

      expect(repository.fetchCalls, 2);
      expect(repository.lastPage, 1);
      expect(cubit.state.isRefreshing, isFalse);
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

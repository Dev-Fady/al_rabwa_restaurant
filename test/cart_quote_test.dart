import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_quote_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_quote_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/models/cart_quote_response.dart';
import 'package:al_rabwa_restaurant/features/cart/data/repositories/cart_quote_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_quote_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

/// Response copied from `POST /api/cart/quote?lang=ar`.
Map<String, dynamic> cartQuotePayload() {
  return {
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
  };
}

CartQuote sampleQuote() =>
    CartQuoteResponse.fromJson(cartQuotePayload()).toEntity()!;

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

class _FakeApiService implements ApiService {
  _FakeApiService({required this.payload});

  dynamic payload;
  Object? error;
  Map<String, dynamic>? lastBody;
  String? lastLang;
  String? lastLocale;

  @override
  Future<HttpResponse<dynamic>> quoteCart({
    required Map<String, dynamic> body,
    String? lang,
    String? xLocale,
  }) async {
    lastBody = body;
    lastLang = lang;
    lastLocale = xLocale;

    final failure = error;
    if (failure != null) throw failure;

    return HttpResponse<dynamic>(
      payload,
      Response<dynamic>(
        requestOptions: RequestOptions(path: 'cart/quote'),
        data: payload,
        statusCode: 200,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalDataSource implements CartQuoteLocalDataSource {
  final Map<String, Map<String, dynamic>> store = {};

  @override
  Future<void> save({
    required String key,
    required Map<String, dynamic> payload,
  }) async {
    store[key] = payload;
  }

  @override
  Map<String, dynamic>? read({required String key}) => store[key];

  @override
  Future<void> clear({required String key}) async {
    store.remove(key);
  }
}

class _FakeRemoteDataSource implements CartQuoteRemoteDataSource {
  _FakeRemoteDataSource(this.response);

  CartQuoteResponse response;
  Object? error;
  int calls = 0;
  Cart? lastCart;
  String? lastLang;

  @override
  Future<CartQuoteResponse> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  }) async {
    calls++;
    lastCart = cart;
    lastLang = lang;

    final failure = error;
    if (failure != null) throw failure;
    return response;
  }
}

class _FakeQuoteRepository implements CartQuoteRepository {
  _FakeQuoteRepository({this.quote, this.cached});

  CartQuote? quote;
  CartQuote? cached;
  Object? error;
  int fetchCalls = 0;
  Cart? lastCart;
  String? lastLang;

  @override
  Future<Either<Failure, CartQuote>> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  }) async {
    fetchCalls++;
    lastCart = cart;
    lastLang = lang;

    final failure = error;
    if (failure != null) {
      return Left(
        failure is Failure ? failure : ServerFailure(failure.toString()),
      );
    }
    return Right(quote ?? sampleQuote());
  }

  @override
  CartQuote? getCachedQuote({required Cart cart, String lang = 'ar'}) => cached;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartQuoteResponse', () {
    test('maps the quote, its line and the fees', () {
      final quote = sampleQuote();

      expect(quote.lines, hasLength(1));
      expect(quote.lines.single.itemId, 31);
      expect(quote.lines.single.name, 'مشاوي مشكلة');
      expect(quote.lines.single.option?.id, 7);
      expect(quote.lines.single.quantity, 0.25);
      expect(quote.lines.single.unitPrice, 39);
      expect(quote.lines.single.total, 9.75);
      expect(quote.subtotal, 9.75);
      expect(quote.discount, 0);
      expect(quote.tax, 0.975);
      expect(quote.serviceCharge, 0.488);
      expect(quote.deliveryFee, 0);
      expect(quote.total, 11.213);
      expect(quote.addressRequired, isFalse);
      expect(quote.acceptingOrdersNow, isTrue);
      expect(quote.closedMessage, isEmpty);
      expect(quote.coupon, isNull);
    });

    test('accepts a coupon code string and an object', () {
      final withCode = Map<String, dynamic>.from(cartQuotePayload());
      (withCode['data'] as Map<String, dynamic>)['coupon'] = 'SAVE10';
      expect(
        CartQuoteResponse.fromJson(withCode).toEntity()?.coupon?.code,
        'SAVE10',
      );

      final withObject = Map<String, dynamic>.from(cartQuotePayload());
      (withObject['data'] as Map<String, dynamic>)['coupon'] = {
        'code': 'SAVE10',
        'discount': 2.5,
      };
      final coupon = CartQuoteResponse.fromJson(withObject).toEntity()?.coupon;
      expect(coupon?.code, 'SAVE10');
      expect(coupon?.discount, 2.5);
    });
  });

  group('CartQuoteRemoteDataSource', () {
    test('sends the order type, weight and option of a cart line', () async {
      final api = _FakeApiService(payload: cartQuotePayload());
      final dataSource = CartQuoteRemoteDataSourceImpl(apiService: api);

      final response = await dataSource.fetchQuote(
        cart: weightedCart().withOrderType('takeaway'),
        lang: 'ar',
      );

      expect(response.data, isNotNull);
      expect(api.lastLang, 'ar');
      expect(api.lastLocale, 'ar');
      expect(api.lastBody?['type'], 'takeaway');

      final lines = api.lastBody?['lines'] as List<dynamic>;
      final line = lines.single as Map<String, dynamic>;
      expect(line['item_id'], 31);
      expect(line['option_id'], 7);
      expect(line['addons'], isEmpty);
      expect(line['quantity'], 0.25);
      expect(line['note'], isNull);
    });

    test(
      'sends whole quantities, add-on ids and notes for normal dishes',
      () async {
        final api = _FakeApiService(payload: cartQuotePayload());
        final dataSource = CartQuoteRemoteDataSourceImpl(apiService: api);
        final cart = const Cart().add(
          _chicken,
          quantity: 2,
          notes: 'بدون بصل',
          addons: [const MenuItemAddon(id: 34, name: 'إضافة أرز', price: 5)],
        );

        await dataSource.fetchQuote(cart: cart, lang: 'en');

        final line =
            (api.lastBody?['lines'] as List<dynamic>).single
                as Map<String, dynamic>;
        expect(line['quantity'], 2);
        expect(line['addons'], [34]);
        expect(line['note'], 'بدون بصل');
        expect(api.lastLang, 'en');
      },
    );

    test('surfaces the backend message when success is false', () async {
      final payload = cartQuotePayload();
      payload['success'] = false;
      payload['message'] = 'السلة غير صالحة';
      final dataSource = CartQuoteRemoteDataSourceImpl(
        apiService: _FakeApiService(payload: payload),
      );

      await expectLater(
        dataSource.fetchQuote(cart: weightedCart()),
        throwsA(
          isA<ServerFailure>().having(
            (failure) => failure.message,
            'message',
            'السلة غير صالحة',
          ),
        ),
      );
    });
  });

  group('CartQuoteRepository', () {
    test(
      'caches a successful quote and keeps it after a failed refresh',
      () async {
        final remote = _FakeRemoteDataSource(
          CartQuoteResponse.fromJson(cartQuotePayload()),
        );
        final local = _FakeLocalDataSource();
        final repository = CartQuoteRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: local,
        );
        final cart = weightedCart();

        final fresh = await repository.fetchQuote(cart: cart, lang: 'ar');
        expect(fresh.isRight(), isTrue);
        expect(local.store, hasLength(1));
        expect(
          repository.getCachedQuote(cart: cart, lang: 'ar')?.total,
          11.213,
        );

        remote.error = DioException(
          requestOptions: RequestOptions(path: 'cart/quote'),
          type: DioExceptionType.connectionError,
        );

        final failed = await repository.fetchQuote(cart: cart, lang: 'ar');
        expect(failed.isLeft(), isTrue);
        expect(
          repository.getCachedQuote(cart: cart, lang: 'ar')?.total,
          11.213,
        );
      },
    );

    test('restores nested lines and a coupon from the cache', () async {
      final payload = cartQuotePayload();
      (payload['data'] as Map<String, dynamic>)['coupon'] = {
        'code': 'SAVE10',
        'discount': 2.5,
      };
      final repository = CartQuoteRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(
          CartQuoteResponse.fromJson(payload),
        ),
        localDataSource: _FakeLocalDataSource(),
      );

      await repository.fetchQuote(cart: weightedCart(), lang: 'ar');
      final cached = repository.getCachedQuote(
        cart: weightedCart(),
        lang: 'ar',
      );

      expect(cached?.lines.single.option?.id, 7);
      expect(cached?.lines.single.quantity, 0.25);
      expect(cached?.coupon?.code, 'SAVE10');
      expect(cached?.coupon?.discount, 2.5);
    });

    test('returns a failure when the request fails without a cache', () async {
      final remote =
          _FakeRemoteDataSource(CartQuoteResponse.fromJson(cartQuotePayload()))
            ..error = DioException(
              requestOptions: RequestOptions(path: 'cart/quote'),
              type: DioExceptionType.connectionError,
            );
      final repository = CartQuoteRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: _FakeLocalDataSource(),
      );

      final result = await repository.fetchQuote(cart: weightedCart());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a failure'),
      );
    });

    test('does not reuse a cache from a different cart', () async {
      final remote = _FakeRemoteDataSource(
        CartQuoteResponse.fromJson(cartQuotePayload()),
      );
      final repository = CartQuoteRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: _FakeLocalDataSource(),
      );

      await repository.fetchQuote(cart: weightedCart(), lang: 'ar');
      remote.error = DioException(
        requestOptions: RequestOptions(path: 'cart/quote'),
        type: DioExceptionType.connectionError,
      );

      final otherCart = const Cart().add(_chicken);
      final result = await repository.fetchQuote(cart: otherCart, lang: 'ar');

      expect(result.isLeft(), isTrue);
    });
  });

  group('CartQuoteCubit', () {
    test('does not quote until the cart tab enables it', () async {
      final cartCubit = CartCubit();
      final repository = _FakeQuoteRepository(quote: sampleQuote());
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cartCubit.add(_grill, weight: 0.25);
      await pumpEventQueue();

      expect(repository.fetchCalls, 0);
      expect(cubit.state.hasQuote, isFalse);
    });

    test('loads and emits the quote when enabled', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(quote: sampleQuote());
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();

      expect(repository.fetchCalls, 1);
      expect(cubit.state.status, CartQuoteStatus.success);
      expect(cubit.state.quote?.total, 11.213);
      expect(cubit.state.isFromCache, isFalse);
    });

    test('requotes when the cart or order type changes', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(quote: sampleQuote());
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();
      expect(repository.fetchCalls, 1);

      cartCubit.setOrderType('takeaway');
      await pumpEventQueue();
      expect(repository.fetchCalls, 2);
      expect(repository.lastCart?.orderType, 'takeaway');

      cartCubit.add(_chicken);
      await pumpEventQueue();
      expect(repository.fetchCalls, 3);
      expect(repository.lastCart?.itemsCount, 2);
    });

    test('keeps the cached quote when the request fails', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(cached: sampleQuote())
        ..error = ServerFailure('انقطع الاتصال');
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();

      expect(cubit.state.status, CartQuoteStatus.failure);
      expect(cubit.state.quote?.total, 11.213);
      expect(cubit.state.isFromCache, isTrue);
      expect(cubit.state.errorMessage, 'انقطع الاتصال');
    });

    test('clears the quote when the cart becomes empty', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(quote: sampleQuote());
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();
      expect(cubit.state.hasQuote, isTrue);

      cartCubit.clear();
      await pumpEventQueue();

      expect(cubit.state.hasQuote, isFalse);
      expect(cubit.state.status, CartQuoteStatus.initial);
    });

    test('reloads the quote in the new language', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(quote: sampleQuote());
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();
      expect(repository.lastLang, 'ar');

      cubit.setLang('en');
      await pumpEventQueue();

      expect(repository.lastLang, 'en');
      expect(cubit.state.lang, 'en');
    });

    test('does not refetch the same cart on a repeated enable', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(quote: sampleQuote());
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();
      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();

      expect(repository.fetchCalls, 1);
    });

    test('retries when the cart tab is reopened after a failure', () async {
      final cartCubit = CartCubit()..add(_grill, weight: 0.25);
      final repository = _FakeQuoteRepository(quote: sampleQuote())
        ..error = ServerFailure('انقطع الاتصال');
      final cubit = CartQuoteCubit(repository, cartCubit);
      addTearDown(cartCubit.close);
      addTearDown(cubit.close);

      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();
      expect(cubit.state.status, CartQuoteStatus.failure);
      expect(repository.fetchCalls, 1);

      repository.error = null;
      cubit.enable(lang: 'ar', cart: cartCubit.state);
      await pumpEventQueue();

      expect(repository.fetchCalls, 2);
      expect(cubit.state.status, CartQuoteStatus.success);
    });
  });
}

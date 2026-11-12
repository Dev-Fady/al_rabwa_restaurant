import 'package:al_rabwa_restaurant/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @POST(ApiConstants.device)
  Future<HttpResponse<dynamic>> registerDevice({
    @Body() required Map<String, dynamic> body,
    @Header('x-locale') String? xLocale,
  });

  @DELETE(ApiConstants.me)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> deleteMyData();

  @GET(ApiConstants.settings)
  Future<HttpResponse<dynamic>> getSettings({
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.categories)
  Future<HttpResponse<dynamic>> getCategories({
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.categoryItems)
  Future<HttpResponse<dynamic>> getCategoryItems({
    @Path('id') required int categoryId,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.itemDetails)
  Future<HttpResponse<dynamic>> getItemDetails({
    @Path('id') required int itemId,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @POST(ApiConstants.cartQuote)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> quoteCart({
    @Body() required Map<String, dynamic> body,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @POST(ApiConstants.orders)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> createOrder({
    @Body() required Map<String, dynamic> body,
    @Header('Idempotency-Key') required String idempotencyKey,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  /// Paginated order history.
  ///
  /// [status] is `current` for still-open orders, `past` for completed or
  /// cancelled ones, and omitted for everything.
  @GET(ApiConstants.orders)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> getOrders({
    @Query('lang') String? lang,
    @Query('status') String? status,
    @Query('page') int? page,
    @Header('x-locale') String? xLocale,
  });

  /// One order from the customer's history.
  @GET(ApiConstants.orderDetails)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> getOrderDetails({
    @Path('id') required int orderId,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.tables)
  Future<HttpResponse<dynamic>> getTables({
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.addresses)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> getAddresses({
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.addressDetails)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> getAddress({
    @Path('id') required int id,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @POST(ApiConstants.addresses)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> createAddress({
    @Body() required Map<String, dynamic> body,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @PATCH(ApiConstants.addressDetails)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> updateAddress({
    @Path('id') required int id,
    @Body() required Map<String, dynamic> body,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @POST(ApiConstants.addressDefault)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> setDefaultAddress({
    @Path('id') required int id,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @DELETE(ApiConstants.addressDetails)
  @Extra(<String, Object>{'requiresToken': true})
  Future<HttpResponse<dynamic>> deleteAddress({
    @Path('id') required int id,
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });
}

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
}

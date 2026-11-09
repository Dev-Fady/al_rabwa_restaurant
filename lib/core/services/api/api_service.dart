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
}

import 'package:al_rabwa_restaurant/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  @GET(ApiConstants.user)
  Future<HttpResponse<dynamic>> getProfile({
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.settings)
  Future<HttpResponse<dynamic>> getSettings({
    @Query('lang') String? lang,
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.orders)
  Future<HttpResponse<dynamic>> getOrders({
    @Header('x-locale') String? xLocale,
  });

  @GET(ApiConstants.logout)
  Future<HttpResponse<dynamic>> logout({@Header('x-locale') String? xLocale});

  /// Permanently deletes the authenticated user's account.
  @GET(ApiConstants.deleteAccount)
  Future<HttpResponse<dynamic>> deleteAccount({
    @Header('x-locale') String? xLocale,
  });
}

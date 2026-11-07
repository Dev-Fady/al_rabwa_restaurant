import 'package:al_rabwa_restaurant/core/error/api_error_handler.dart';
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioException(DioException dioException) {
    return ServerFailure(ApiErrorHandler.handle(dioException));
  }

  factory ServerFailure.fromError(dynamic error) {
    return ServerFailure(ApiErrorHandler.handle(error));
  }
}

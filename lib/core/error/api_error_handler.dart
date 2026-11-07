import 'package:al_rabwa_restaurant/core/error/api_error_model.dart';
import 'package:dio/dio.dart';
class ApiErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "انتهى وقت الاتصال بالخادم (Connection timeout).";
        case DioExceptionType.sendTimeout:
          return "انتهى وقت إرسال الطلب (Send timeout).";
        case DioExceptionType.receiveTimeout:
          return "انتهى وقت استلام الرد (Receive timeout).";
        case DioExceptionType.badCertificate:
          return "شهادة أمان غير صالحة (Bad Certificate).";
        case DioExceptionType.badResponse:
          return _handleError(error.response?.statusCode, error.response?.data);
        case DioExceptionType.cancel:
          return "تم إلغاء الطلب.";
        case DioExceptionType.connectionError:
          return "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.";
        case DioExceptionType.unknown:
          return "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.";
        case DioExceptionType.transformTimeout:
          return "انتهى وقت تحويل البيانات (Transform timeout).";
      }
    } else {
      return "حدث خطأ غير معروف.";
    }
  }

  static String _handleError(int? statusCode, dynamic data) {
    String backendMessage = '';

    if (data != null) {
      try {
        if (data is Map<String, dynamic>) {
          final errorModel = ApiErrorModel.fromJson(data);
          backendMessage = errorModel.getErrorMessage();
        } else if (data is String) {
          backendMessage = data;
        }
      } catch (e) {
        backendMessage = '';
      }
    }

    String defaultMessage;
    switch (statusCode) {
      case 400:
        defaultMessage = "طلب غير صالح (Bad Request).";
        break;
      case 401:
        defaultMessage = "غير مصرح لك (Unauthorized).";
        break;
      case 403:
        defaultMessage = "مرفوض (Forbidden).";
        break;
      case 404:
        defaultMessage = "الرابط المطلوب غير موجود (Not Found).";
        break;
      case 500:
        defaultMessage = "خطأ في الخادم الداخلي (Internal Server Error).";
        break;
      case 502:
        defaultMessage = "بوابة غير صالحة (Bad Gateway).";
        break;
      case 503:
        defaultMessage = "الخدمة غير متوفرة (Service Unavailable).";
        break;
      default:
        defaultMessage = "حدث خطأ ما (رمز الخطأ: $statusCode).";
    }

    if (backendMessage.isNotEmpty) {
      return backendMessage;
    }

    return defaultMessage;
  }
}

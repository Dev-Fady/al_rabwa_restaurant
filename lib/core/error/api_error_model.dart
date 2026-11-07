class ApiErrorModel {
  final int? code;
  final String? message;
  final String? error;
  final Map<String, dynamic>? errors;

  ApiErrorModel({this.code, this.message, this.error, this.errors});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] ?? json['status_code'] ?? json['statusCode'],
      message: json['message'],
      error: json['error'],
      errors: json['errors'] is Map ? Map<String, dynamic>.from(json['errors']) : null,
    );
  }

  String getErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      final List<String> fieldErrors = [];
      errors!.forEach((key, value) {
        if (value is List) {
          for (final item in value) {
            fieldErrors.add(item.toString());
          }
        }
      });
      if (fieldErrors.isNotEmpty) return fieldErrors.join('\n');
    }
    if (message != null && message!.isNotEmpty) return message!;
    if (error != null && error!.isNotEmpty) return error!;
    return '';
  }
}

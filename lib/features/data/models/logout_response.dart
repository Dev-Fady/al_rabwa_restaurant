import 'package:json_annotation/json_annotation.dart';

part 'logout_response.g.dart';

/// Logout envelope observed in Postman (`GET /api/logout`, Bearer token).
///
/// Success (HTTP 200):
/// ```json
/// {"success": true, "message": "تم تسجيل خروجك بنجاح.", "data": ""}
/// ```
///
/// Failure: 401 unauthenticated or (still HTTP 200):
/// ```json
/// {"success": false, "message": "..."}
/// ```
@JsonSerializable()
class LogoutResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;

  const LogoutResponse({required this.success, required this.message});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutResponseToJson(this);
}

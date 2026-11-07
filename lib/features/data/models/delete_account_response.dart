import 'package:json_annotation/json_annotation.dart';

part 'delete_account_response.g.dart';

/// Delete-account envelope observed in Postman (`GET /api/user/delete`,
/// Bearer token).
///
/// Success (HTTP 200):
/// ```json
/// {"success": true, "message": "تم حذف البيانات بنجاح.", "data": true}
/// ```
///
/// Failure: 401 unauthenticated or (still HTTP 200):
/// ```json
/// {"success": false, "message": "..."}
/// ```
@JsonSerializable()
class DeleteAccountResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;
  @JsonKey(defaultValue: false)
  final bool data;

  const DeleteAccountResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountResponseToJson(this);
}

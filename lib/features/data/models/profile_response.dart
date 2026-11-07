import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_response.g.dart';

int _parseId(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _parseString(dynamic value) => value?.toString() ?? '';

/// Profile envelope observed in the API screenshots.
///
/// Success (HTTP 200):
/// ```json
/// {"success": true, "message": "تم استيراد البيانات بنجاح.",
///  "data": {"id": 11, "name": "fady", "email": "...", "mobile": "...",
///   "lang": "ar", ...}}
/// ```
///
/// Failure (still HTTP 200):
/// ```json
/// {"success": false, "message": "..."}
/// ```
@JsonSerializable()
class ProfileResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;
  final ProfileUserModel? data;

  const ProfileResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);

  ProfileUser toEntity() {
    return data?.toEntity() ??
        const ProfileUser(id: 0, name: '', email: '', mobile: '', lang: 'ar');
  }
}

@JsonSerializable()
class ProfileUserModel {
  @JsonKey(fromJson: _parseId)
  final int id;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String name;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String email;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String mobile;
  @JsonKey(fromJson: _parseString, defaultValue: 'ar')
  final String lang;

  const ProfileUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.lang,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUserModelToJson(this);

  ProfileUser toEntity() {
    return ProfileUser(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      lang: lang.isEmpty ? 'ar' : lang,
    );
  }
}

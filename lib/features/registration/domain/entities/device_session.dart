/// A registered device and the bearer token issued by `POST /api/device`.
///
/// ```json
/// {"data": {"id": 17, "name": "جودة", "phone": "+974 555 1234",
///   "email": null, "locale": "ar", "has_push_token": false},
///  "token": "IoKjpoomXZwOGK2xrJlJnr37hXDilq2FKws9XZSwsGS2bINWtJfrgJlm8dZxvTtOML"}
/// ```
class DeviceSession {
  const DeviceSession({
    required this.token,
    this.id,
    this.name = '',
    this.phone = '',
    this.email,
    this.locale = 'ar',
    this.hasPushToken = false,
  });

  final String token;
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String locale;
  final bool hasPushToken;

  bool get hasToken => token.trim().isNotEmpty;
}

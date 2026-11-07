/// Store contact details returned by `GET /api/settings`.
///
/// Used by the "My Addresses" page to show the boutique address, phone
/// numbers, email and social channels.
class StoreInfo {
  final String name;
  final String logo;
  final String email;
  final String mobile;
  final String mobile2;
  final String address;
  final String facebook;
  final String twitter;
  final String instagram;
  final String youtube;

  const StoreInfo({
    this.name = '',
    this.logo = '',
    this.email = '',
    this.mobile = '',
    this.mobile2 = '',
    this.address = '',
    this.facebook = '',
    this.twitter = '',
    this.instagram = '',
    this.youtube = '',
  });

  bool get hasAddress => address.trim().isNotEmpty;

  bool get hasEmail => email.trim().isNotEmpty;

  bool get hasMobile => mobile.trim().isNotEmpty;

  bool get hasSocialLinks =>
      facebook.trim().isNotEmpty ||
      twitter.trim().isNotEmpty ||
      instagram.trim().isNotEmpty ||
      youtube.trim().isNotEmpty;
}

/// Public web pages linked from the app.
///
/// Hosted on Firebase Hosting (project `wady-elmalekat`, site
/// `wady-elmalekat-legal`) from the `legal/` directory.
/// Deploy with:
///   firebase deploy --only hosting --config firebase.legal.json
abstract final class AppLinks {
  AppLinks._();

  static const String privacyPolicy = '';

  /// Arabic version of [privacyPolicy] (the page switches language via `lang`).
  static const String privacyPolicyArabic =
      '';

  /// Returns the policy in the given app language.
  static String privacyPolicyFor(String languageCode) =>
      languageCode == 'ar' ? privacyPolicyArabic : privacyPolicy;
}

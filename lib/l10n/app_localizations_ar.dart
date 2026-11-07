// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مطعم الربوة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMenu => 'المنيو';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navStore => 'المتجر';

  @override
  String get homeWelcomeTitle => 'أهلاً بك في مطعم الربوة';

  @override
  String get homeWelcomeSubtitle =>
      'اختر أطباقك المفضلة من المنيو واستمتع بتجربة طعام مميزة.';

  @override
  String get sectionComingSoon => 'قريباً';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';
}

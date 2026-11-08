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
  String get storeOpenNow => 'مفتوح الآن — نستقبل طلباتك';

  @override
  String get storeOpenShort => 'مفتوح';

  @override
  String get storeClosed => 'مغلق حالياً';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get storeInfoTitle => 'معلومات المطعم';

  @override
  String get orderOptionsTitle => 'طرق الطلب';

  @override
  String get browseMenu => 'تصفح المنيو';

  @override
  String get orderNow => 'اطلب الآن';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get storeSettingsError =>
      'تعذر تحميل بيانات المطعم، تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get loadingStore => 'جارٍ تحميل المطعم...';

  @override
  String get currencyLabel => 'العملة';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get deliveryFeeLabel => 'رسوم التوصيل';

  @override
  String get taxLabel => 'الضريبة';

  @override
  String get serviceLabel => 'رسوم الخدمة';

  @override
  String get deliveryZonesLabel => 'مناطق التوصيل';

  @override
  String get reservationsLabel => 'الحجوزات';

  @override
  String get availableLabel => 'متاح';

  @override
  String get workingHoursLabel => 'ساعات العمل';

  @override
  String get locationRequiredLabel => 'تحديد الموقع';

  @override
  String get requiredLabel => 'مطلوب';

  @override
  String get onlinePaymentLabel => 'الدفع الإلكتروني';

  @override
  String get contactTitle => 'تواصل معنا';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get whatsappLabel => 'واتساب';

  @override
  String get instagramLabel => 'إنستغرام';

  @override
  String get facebookLabel => 'فيسبوك';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get sectionComingSoon => 'قريباً';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get deliverTo => 'التوصيل إلى';

  @override
  String get selectLocation => 'حدّد موقعك';

  @override
  String get searchFoodHint => 'ماذا تشتهي اليوم؟';

  @override
  String get homeCategoriesTitle => 'اكتشف المنيو';

  @override
  String get homeCategoriesViewAll => 'عرض الكل';

  @override
  String get homeCategoriesHint =>
      'اسحب الأقسام يمينًا ويسارًا أو اضغط على قسم لفتحه';

  @override
  String get homeCategoriesError => 'تعذر تحميل أقسام المنيو.';

  @override
  String get menuTitle => 'المنيو';

  @override
  String get menuCategoriesTitle => 'أقسام المنيو';

  @override
  String get menuCategoriesSubtitle => 'اختر ما تشتهيه';

  @override
  String get menuCategoriesBackHome => 'العودة إلى الرئيسية';

  @override
  String get menuCategoriesHeroTitle => 'جميع النكهات في مكان واحد';

  @override
  String menuCategoriesHeroSubtitle(String restaurant, int count) {
    return 'تصفّح قائمة مطعم $restaurant ($count)';
  }

  @override
  String get menuCategoriesEmpty => 'لا توجد أقسام لعرضها حالياً.';

  @override
  String get menuSearchHint => 'ابحث عن طبقك المفضل';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String menuItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف',
      many: '$count صنفًا',
      few: '$count أصناف',
      two: 'صنفان',
      one: 'صنف واحد',
      zero: 'لا أصناف',
    );
    return '$_temp0';
  }

  @override
  String get menuBrowseAllCategories => 'تصفح جميع الأقسام';

  @override
  String get menuChooseDishHint => 'اختر طبقك وأضف لسلة';

  @override
  String get menuAllCategoriesTitle => 'جميع الأقسام';

  @override
  String get menuItemsError => 'تعذر تحميل الأطباق.';

  @override
  String get menuEmptyCategory => 'لا توجد أطباق في هذا القسم حالياً.';

  @override
  String get menuSearchNoResults => 'لا توجد أطباق مطابقة لبحثك.';

  @override
  String get backLabel => 'رجوع';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get addToCartLabel => 'أضف إلى السلة';

  @override
  String get addedToCart => 'أُضيف إلى السلة';

  @override
  String get itemDetailsError => 'تعذر تحميل تفاصيل الطبق.';

  @override
  String get itemDetailsFreshlyPrepared => 'يُحضّر طازجًا عند الطلب';

  @override
  String get itemDetailsQuantity => 'الكمية';

  @override
  String get itemDetailsSpecialInstructions => 'تعليمات خاصة';

  @override
  String get itemDetailsSpecialInstructionsHint =>
      'مثل: بدون بصل، مستوى الطهي...';

  @override
  String get itemDetailsIncreaseQuantity => 'زيادة الكمية';

  @override
  String get itemDetailsDecreaseQuantity => 'تقليل الكمية';

  @override
  String itemDetailsAddToCartPrice(String price) {
    return 'أضف إلى السلة - $price';
  }

  @override
  String get itemDetailsChooseOne => 'اختر واحدًا';

  @override
  String get itemDetailsAddons => 'إضافات اختيارية';

  @override
  String get itemDetailsWeight => 'الوزن';

  @override
  String itemDetailsWeightHint(String min, String max) {
    return 'من $min إلى $max كجم';
  }

  @override
  String itemDetailsWeightValue(String value) {
    return '$value كجم';
  }

  @override
  String get itemDetailsPerKg => '/كجم';

  @override
  String get itemDetailsVideo => 'فيديو';

  @override
  String get itemDetailsPhoto => 'صورة';

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'EN';
}

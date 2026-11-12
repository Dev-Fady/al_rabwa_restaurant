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
  String get splashTagline => 'نكهات طازجة وكرم ضيافة';

  @override
  String get splashLoading => 'نجهّز طاولتك…';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMenu => 'المنيو';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navStore => 'المطعم';

  @override
  String get homeWelcomeTitle => 'أهلاً بك في مطعم الربوة';

  @override
  String get homeWelcomeSubtitle =>
      'اختر أطباقك المفضلة من المنيو واستمتع بتجربة طعام مميزة.';

  @override
  String get storeOpenNow => 'مفتوح الآن — نستقبل طلباتك';

  @override
  String get storeOpenShort => 'مفتوح الآن';

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
  String get workingHoursLabel => 'أوقات العمل';

  @override
  String get storeLanguageTitle => 'لغة المنيو';

  @override
  String get storeLanguageArabic => 'العربية';

  @override
  String get storeLanguageEnglish => 'English';

  @override
  String get storePoweredBy => 'بدعم من SmartMenues';

  @override
  String get deleteMyDataTitle => 'حذف بياناتي';

  @override
  String get deleteMyDataConfirmTitle => 'حذف بياناتي؟';

  @override
  String get deleteMyDataConfirmMessage =>
      'سيتم حذف بيانات هذا الجهاز، بما في ذلك ملفك الشخصي وعناوينك وطلباتك، نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteMyDataConfirmAction => 'حذف البيانات';

  @override
  String get deleteMyDataCancelAction => 'إلغاء';

  @override
  String get deleteMyDataSuccess => 'تم حذف بياناتك بنجاح.';

  @override
  String get deleteMyDataError => 'تعذّر حذف بياناتك، يرجى المحاولة مرة أخرى.';

  @override
  String get locationRequiredLabel => 'تحديد الموقع';

  @override
  String get requiredLabel => 'مطلوب';

  @override
  String get onlinePaymentLabel => 'الدفع الإلكتروني';

  @override
  String get contactTitle => 'تواصل معنا';

  @override
  String get contactEmpty => 'لا توجد بيانات تواصل متاحة حالياً.';

  @override
  String get contactEmptyHint =>
      'ستظهر أرقام الهاتف وحسابات التواصل هنا عند إضافتها.';

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

  @override
  String get registerWelcomeTitle => 'أهلاً بك في مطعم الربوة';

  @override
  String get registerWelcomeSubtitle =>
      'أخبرنا قليلاً عنك وابدأ الطلب في ثوانٍ.';

  @override
  String get registerHeroBadge => 'مطعم الربوة';

  @override
  String get registerFormTitle => 'أنشئ ملفك الشخصي';

  @override
  String get registerFormSubtitle => 'سنستخدم بياناتك لتخصيص طلباتك.';

  @override
  String get registerNameHint => 'مثال: أحمد محمد';

  @override
  String get registerPhoneHint => '+974 555 1234';

  @override
  String get registerLanguageLabel => 'اللغة المفضلة';

  @override
  String get registerSubmit => 'ابدأ الطلب';

  @override
  String get registerError => 'حدث خطأ ما، يرجى المحاولة مرة أخرى.';

  @override
  String get registerNameRequired => 'يرجى إدخال اسمك.';

  @override
  String get registerNameTooShort => 'الاسم قصير جداً.';

  @override
  String get registerPhoneRequired => 'يرجى إدخال رقم هاتفك.';

  @override
  String get registerPhoneInvalid => 'يرجى إدخال رقم هاتف صالح.';

  @override
  String get registerPrivacyNote =>
      'يتم حفظ جلستك بأمان على هذا الجهاز. بالمتابعة، أنت توافق على الشروط وسياسة الخصوصية.';

  @override
  String get registerFeatureFresh => 'يُحضّر طازجاً';

  @override
  String get registerFeatureFast => 'توصيل سريع';

  @override
  String get registerFeatureSecure => 'آمن وخاص';

  @override
  String get addressAddTitle => 'أضف عنوانًا جديدًا';

  @override
  String get addressEditTitle => 'تعديل العنوان';

  @override
  String get addressSaveChanges => 'حفظ التعديلات';

  @override
  String get addressDetailsTitle => 'تفاصيل العنوان';

  @override
  String get addressDetailsInfo => 'بيانات العنوان';

  @override
  String get addressDetailsError =>
      'تعذّر تحميل تفاصيل العنوان، يرجى المحاولة مرة أخرى.';

  @override
  String get addressOptions => 'خيارات العنوان';

  @override
  String get addressViewDetails => 'عرض التفاصيل';

  @override
  String get addressSetDefault => 'تعيين كافتراضي';

  @override
  String get addressDefault => 'افتراضي';

  @override
  String get addressSetDefaultError =>
      'تعذّر تعيين هذا العنوان كافتراضي، يرجى المحاولة مرة أخرى.';

  @override
  String get addressDelete => 'حذف العنوان';

  @override
  String get addressDeleteConfirmTitle => 'حذف العنوان؟';

  @override
  String addressDeleteConfirmMessage(String name) {
    return 'هل تريد حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get addressDeleteConfirm => 'حذف';

  @override
  String get addressDeleteCancel => 'إلغاء';

  @override
  String get addressDeleteError => 'تعذّر حذف العنوان، يرجى المحاولة مرة أخرى.';

  @override
  String get addressCoordinates => 'الإحداثيات';

  @override
  String get addressSelectTitle => 'اختر عنوان التوصيل';

  @override
  String get addressSelectSubtitle =>
      'اختر عنوانًا محفوظًا أو أضف عنوانًا جديدًا.';

  @override
  String get addressSavedTitle => 'العناوين المحفوظة';

  @override
  String get addressListEmpty => 'لم تحفظ أي عنوان بعد.';

  @override
  String get addressListError =>
      'تعذّر تحميل عناوينك المحفوظة، يرجى المحاولة مرة أخرى.';

  @override
  String get addressOutsideArea => 'خارج نطاق التوصيل';

  @override
  String get addressUseCurrentLocation => 'استخدام موقعي الحالي';

  @override
  String get addressMapHint => 'حرّك الخريطة لتأكيد موقعك';

  @override
  String get addressKindHome => 'المنزل';

  @override
  String get addressKindWork => 'العمل';

  @override
  String get addressKindOther => 'آخر';

  @override
  String get addressLabelField => 'اسم العنوان (اختياري)';

  @override
  String get addressLabelHint => 'مثال: بيت العائلة';

  @override
  String get addressAreaField => 'المنطقة / الحي';

  @override
  String get addressAreaHint => 'السد، الريان';

  @override
  String get addressStreetField => 'الشارع';

  @override
  String get addressStreetHint => 'شارع 901';

  @override
  String get addressBuildingField => 'المبنى / الطابق / الشقة';

  @override
  String get addressBuildingHint => 'مبنى 35، الطابق 2';

  @override
  String get addressNotesField => 'إرشادات للسائق';

  @override
  String get addressNotesHint => 'مثال: الباب الأخضر';

  @override
  String get addressSave => 'حفظ العنوان';

  @override
  String get addressAreaRequired => 'يرجى إدخال المنطقة أو الحي.';

  @override
  String get addressStreetRequired => 'يرجى إدخال الشارع.';

  @override
  String get addressBuildingRequired => 'يرجى إدخال رقم المبنى.';

  @override
  String get addressOutsideQatar =>
      'الموقع المحدد خارج قطر. حرّك الخريطة لاختيار موقع داخل الدولة.';

  @override
  String get addressSaveError => 'تعذّر حفظ العنوان، يرجى المحاولة مرة أخرى.';

  @override
  String get addressNotDeliverable =>
      'تم حفظ العنوان، لكنه خارج نطاق التوصيل الحالي.';

  @override
  String get addressLocationServiceDisabled =>
      'خدمة الموقع غير مفعّلة. فعّلها من إعدادات الجهاز ثم حاول مجددًا.';

  @override
  String get addressLocationPermissionDenied =>
      'يجب السماح بالوصول إلى الموقع لاستخدام موقعك الحالي.';

  @override
  String get addressLocationPermissionDeniedForever =>
      'إذن الموقع مرفوض. يمكنك تفعيله من إعدادات التطبيق.';

  @override
  String get addressLocationUnavailable =>
      'تعذّر تحديد موقعك الحالي. حرّك الخريطة يدويًا.';

  @override
  String get cartEmptyTitle => 'سلتك فارغة';

  @override
  String get cartEmptyMessage => 'أضف أطباقك المفضلة من المنيو لتظهر هنا.';

  @override
  String get cartSummaryTitle => 'ملخص الطلب';

  @override
  String get cartSubtotal => 'المجموع الفرعي';

  @override
  String get cartDiscount => 'الخصم';

  @override
  String get cartTotal => 'الإجمالي';

  @override
  String get cartQuoteLoading => 'جارٍ حساب الإجمالي...';

  @override
  String get cartQuoteError =>
      'تعذّر حساب إجمالي السلة، يرجى المحاولة مرة أخرى.';

  @override
  String get cartQuoteCached => 'يتم عرض آخر إجمالي محفوظ. اسحب للتحديث.';

  @override
  String get cartAddressRequired => 'مطلوب عنوان توصيل للمتابعة.';

  @override
  String get cartRemoveItem => 'إزالة الصنف';
}

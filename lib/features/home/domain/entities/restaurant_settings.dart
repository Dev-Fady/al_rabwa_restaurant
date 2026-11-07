/// Storefront configuration returned by `GET /api/settings`.
///
/// The payload drives the whole storefront: restaurant branding, brand
/// colors, home banners, currency and the available order options. Never
/// throws while parsing — every field falls back to a sensible default so a
/// partial backend response still renders.
class RestaurantSettings {
  const RestaurantSettings({
    this.restaurant = const RestaurantBrand(),
    this.theme = const BrandTheme(),
    this.home = const HomeContent(),
    this.localization = const StoreLocalization(),
    this.currency = const StoreCurrency(),
    this.ordering = const OrderingSettings(),
    this.contact = const StoreContact(),
    this.reservationsEnabled = false,
    this.onlinePaymentEnabled = false,
    this.onlinePaymentGateway = '',
  });

  final RestaurantBrand restaurant;
  final BrandTheme theme;
  final HomeContent home;
  final StoreLocalization localization;
  final StoreCurrency currency;
  final OrderingSettings ordering;
  final StoreContact contact;
  final bool reservationsEnabled;
  final bool onlinePaymentEnabled;
  final String onlinePaymentGateway;

  /// True only when ordering is enabled and the restaurant is accepting
  /// orders right now.
  bool get isOpenNow => ordering.enabled && ordering.acceptingOrdersNow;

  /// First banner that actually has an image to show.
  HomeBanner? get primaryBanner {
    for (final banner in home.banners) {
      if (banner.image.trim().isNotEmpty) return banner;
    }
    return home.banners.isEmpty ? null : home.banners.first;
  }

  RestaurantSettings copyWith({
    RestaurantBrand? restaurant,
    BrandTheme? theme,
    HomeContent? home,
    StoreLocalization? localization,
    StoreCurrency? currency,
    OrderingSettings? ordering,
    StoreContact? contact,
    bool? reservationsEnabled,
    bool? onlinePaymentEnabled,
    String? onlinePaymentGateway,
  }) {
    return RestaurantSettings(
      restaurant: restaurant ?? this.restaurant,
      theme: theme ?? this.theme,
      home: home ?? this.home,
      localization: localization ?? this.localization,
      currency: currency ?? this.currency,
      ordering: ordering ?? this.ordering,
      contact: contact ?? this.contact,
      reservationsEnabled: reservationsEnabled ?? this.reservationsEnabled,
      onlinePaymentEnabled: onlinePaymentEnabled ?? this.onlinePaymentEnabled,
      onlinePaymentGateway: onlinePaymentGateway ?? this.onlinePaymentGateway,
    );
  }
}

class RestaurantBrand {
  const RestaurantBrand({
    this.id,
    this.name = '',
    this.subdomain = '',
    this.url = '',
    this.logo = '',
    this.description = '',
    this.tagline = '',
  });

  final int? id;
  final String name;
  final String subdomain;
  final String url;
  final String logo;
  final String description;
  final String tagline;

  bool get hasLogo => logo.trim().isNotEmpty;

  /// Best short line to show under the restaurant name.
  String get about => tagline.trim().isNotEmpty ? tagline : description;

  RestaurantBrand copyWith({
    int? id,
    String? name,
    String? subdomain,
    String? url,
    String? logo,
    String? description,
    String? tagline,
  }) {
    return RestaurantBrand(
      id: id ?? this.id,
      name: name ?? this.name,
      subdomain: subdomain ?? this.subdomain,
      url: url ?? this.url,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      tagline: tagline ?? this.tagline,
    );
  }
}

/// Raw brand colors from the API. Kept as hex strings so the domain layer
/// stays Flutter-free; `AppTheme` parses them.
class BrandTheme {
  const BrandTheme({
    this.primaryColor = '#174722',
    this.accentColor = '#C7DF39',
    this.backgroundColor = '#FAF9F5',
    this.textColor = '#161A17',
    this.titleColor = '#174722',
    this.fontFamily = 'Cairo',
    this.fontUrl = '',
    this.template = 'classic',
    this.categoryLayout = 'grid',
    this.backgroundImage = '',
    this.menuBackground = '',
  });

  final String primaryColor;
  final String accentColor;
  final String backgroundColor;
  final String textColor;
  final String titleColor;
  final String fontFamily;
  final String fontUrl;
  final String template;
  final String categoryLayout;
  final String backgroundImage;
  final String menuBackground;

  BrandTheme copyWith({
    String? primaryColor,
    String? accentColor,
    String? backgroundColor,
    String? textColor,
    String? titleColor,
    String? fontFamily,
    String? fontUrl,
    String? template,
    String? categoryLayout,
    String? backgroundImage,
    String? menuBackground,
  }) {
    return BrandTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      titleColor: titleColor ?? this.titleColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontUrl: fontUrl ?? this.fontUrl,
      template: template ?? this.template,
      categoryLayout: categoryLayout ?? this.categoryLayout,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      menuBackground: menuBackground ?? this.menuBackground,
    );
  }
}

class HomeContent {
  const HomeContent({
    this.heroTitle = '',
    this.heroSubtitle = '',
    this.showWelcomeMessage = true,
    this.showBanner = true,
    this.banners = const [],
  });

  final String heroTitle;
  final String heroSubtitle;
  final bool showWelcomeMessage;
  final bool showBanner;
  final List<HomeBanner> banners;

  HomeContent copyWith({
    String? heroTitle,
    String? heroSubtitle,
    bool? showWelcomeMessage,
    bool? showBanner,
    List<HomeBanner>? banners,
  }) {
    return HomeContent(
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      showWelcomeMessage: showWelcomeMessage ?? this.showWelcomeMessage,
      showBanner: showBanner ?? this.showBanner,
      banners: banners ?? this.banners,
    );
  }
}

class HomeBanner {
  const HomeBanner({
    this.id,
    this.image = '',
    this.title = '',
    this.subtitle = '',
    this.buttonText = '',
    this.linkType = '',
    this.categoryId,
    this.itemId,
    this.url = '',
  });

  final int? id;
  final String image;
  final String title;
  final String subtitle;
  final String buttonText;
  final String linkType;
  final int? categoryId;
  final int? itemId;
  final String url;

  bool get hasImage => image.trim().isNotEmpty;

  /// The banner opens the menu until the categories feature lands.
  bool get opensMenu => linkType == 'category' || linkType == 'item';

  bool get opensExternalUrl =>
      (linkType == 'url' || linkType == 'external') && url.trim().isNotEmpty;

  HomeBanner copyWith({
    int? id,
    String? image,
    String? title,
    String? subtitle,
    String? buttonText,
    String? linkType,
    int? categoryId,
    int? itemId,
    String? url,
  }) {
    return HomeBanner(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      buttonText: buttonText ?? this.buttonText,
      linkType: linkType ?? this.linkType,
      categoryId: categoryId ?? this.categoryId,
      itemId: itemId ?? this.itemId,
      url: url ?? this.url,
    );
  }
}

class StoreLocalization {
  const StoreLocalization({
    this.locale = 'ar',
    this.direction = 'rtl',
    this.defaultLocale = 'ar',
    this.locales = const ['ar', 'en'],
    this.timezone = 'Asia/Qatar',
  });

  final String locale;
  final String direction;
  final String defaultLocale;
  final List<String> locales;
  final String timezone;

  bool get isRtl => direction == 'rtl';
}

class StoreCurrency {
  const StoreCurrency({
    this.code = 'QAR',
    this.symbol = 'ر.ق',
    this.decimals = 3,
  });

  final String code;
  final String symbol;
  final int decimals;

  /// E.g. `12.500 ر.ق`.
  String format(num amount) {
    final safeDecimals = decimals < 0 ? 0 : decimals;
    return '${amount.toStringAsFixed(safeDecimals)} $symbol';
  }
}

class OrderingSettings {
  const OrderingSettings({
    this.enabled = false,
    this.acceptingOrdersNow = false,
    this.closedMessage = '',
    this.orderTypes = const [],
    this.paymentMethods = const [],
    this.requireCustomerLocation = false,
    this.showCartTotal = true,
    this.taxPercent = 0,
    this.servicePercent = 0,
    this.deliveryFee = 0,
    this.workingHours = const {},
    this.deliveryZones = const [],
  });

  final bool enabled;
  final bool acceptingOrdersNow;
  final String closedMessage;
  final List<OrderOption> orderTypes;
  final List<PaymentOption> paymentMethods;
  final bool requireCustomerLocation;
  final bool showCartTotal;
  final double taxPercent;
  final double servicePercent;
  final double deliveryFee;

  /// Raw `working_hours` object from the API; the shape depends on the
  /// storefront configuration, so it is kept as-is.
  final Map<String, dynamic> workingHours;

  /// Raw `delivery_zones` list from the API; empty means the restaurant
  /// delivers everywhere it accepts orders.
  final List<Map<String, dynamic>> deliveryZones;

  bool get hasWorkingHours => workingHours.isNotEmpty;

  bool get hasDeliveryZones => deliveryZones.isNotEmpty;

  bool get hasExtraFees =>
      taxPercent > 0 || servicePercent > 0 || deliveryFee > 0;
}

class OrderOption {
  const OrderOption({required this.value, required this.label});

  final String value;
  final String label;
}

class PaymentOption {
  const PaymentOption({required this.value, required this.label});

  final String value;
  final String label;
}

class StoreContact {
  const StoreContact({
    this.phone = '',
    this.whatsapp = '',
    this.instagram = '',
    this.facebook = '',
    this.location = '',
  });

  final String phone;
  final String whatsapp;
  final String instagram;
  final String facebook;
  final String location;

  bool get hasAny =>
      phone.trim().isNotEmpty ||
      whatsapp.trim().isNotEmpty ||
      instagram.trim().isNotEmpty ||
      facebook.trim().isNotEmpty ||
      location.trim().isNotEmpty;

  bool get hasSocialLinks =>
      instagram.trim().isNotEmpty || facebook.trim().isNotEmpty;
}

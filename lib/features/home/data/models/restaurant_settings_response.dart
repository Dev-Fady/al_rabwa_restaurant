import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/restaurant_settings.dart';

part 'restaurant_settings_response.g.dart';

/// Envelope of `GET /api/settings?lang=ar`.
///
/// ```json
/// {"data": {"restaurant": {...}, "theme": {...}, "home": {...},
///   "localization": {...}, "currency": {...}, "ordering": {...},
///   "reservations": {...}, "online_payment": {...}, "contact": {...}}}
/// ```
@JsonSerializable(explicitToJson: true)
class RestaurantSettingsResponse {
  @JsonKey(defaultValue: false)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final RestaurantSettingsData? data;

  const RestaurantSettingsResponse({
    this.success = false,
    this.message = '',
    this.data,
  });

  factory RestaurantSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$RestaurantSettingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantSettingsResponseToJson(this);

  RestaurantSettings? toEntity() => data?.toEntity();
}

@JsonSerializable(explicitToJson: true)
class RestaurantSettingsData {
  final RestaurantModel? restaurant;
  final RestaurantThemeModel? theme;
  final RestaurantHomeModel? home;
  final RestaurantLocalizationModel? localization;
  final RestaurantCurrencyModel? currency;
  final RestaurantOrderingModel? ordering;
  final RestaurantReservationsModel? reservations;

  @JsonKey(name: 'online_payment')
  final RestaurantOnlinePaymentModel? onlinePayment;

  final RestaurantContactModel? contact;

  const RestaurantSettingsData({
    this.restaurant,
    this.theme,
    this.home,
    this.localization,
    this.currency,
    this.ordering,
    this.reservations,
    this.onlinePayment,
    this.contact,
  });

  factory RestaurantSettingsData.fromJson(Map<String, dynamic> json) =>
      _$RestaurantSettingsDataFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantSettingsDataToJson(this);

  RestaurantSettings toEntity() {
    return RestaurantSettings(
      restaurant: restaurant?.toEntity() ?? const RestaurantBrand(),
      theme: theme?.toEntity() ?? const BrandTheme(),
      home: home?.toEntity() ?? const HomeContent(),
      localization: localization?.toEntity() ?? const StoreLocalization(),
      currency: currency?.toEntity() ?? const StoreCurrency(),
      ordering: ordering?.toEntity() ?? const OrderingSettings(),
      contact: contact?.toEntity() ?? const StoreContact(),
      reservationsEnabled: reservations?.enabled ?? false,
      onlinePaymentEnabled: onlinePayment?.enabled ?? false,
    );
  }
}

@JsonSerializable()
class RestaurantModel {
  final int? id;
  final String? name;
  final String? subdomain;
  final String? url;
  final String? logo;
  final String? description;
  final String? tagline;

  const RestaurantModel({
    this.id,
    this.name,
    this.subdomain,
    this.url,
    this.logo,
    this.description,
    this.tagline,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);

  RestaurantBrand toEntity() => RestaurantBrand(
    id: id,
    name: name ?? '',
    subdomain: subdomain ?? '',
    url: url ?? '',
    logo: logo ?? '',
    description: description ?? '',
    tagline: tagline ?? '',
  );
}

@JsonSerializable()
class RestaurantThemeModel {
  @JsonKey(name: 'primary_color')
  final String? primaryColor;

  @JsonKey(name: 'accent_color')
  final String? accentColor;

  @JsonKey(name: 'background_color')
  final String? backgroundColor;

  @JsonKey(name: 'text_color')
  final String? textColor;

  @JsonKey(name: 'title_color')
  final String? titleColor;

  @JsonKey(name: 'font_family')
  final String? fontFamily;

  const RestaurantThemeModel({
    this.primaryColor,
    this.accentColor,
    this.backgroundColor,
    this.textColor,
    this.titleColor,
    this.fontFamily,
  });

  factory RestaurantThemeModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantThemeModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantThemeModelToJson(this);

  BrandTheme toEntity() {
    const fallback = BrandTheme();
    return BrandTheme(
      primaryColor: _nonEmpty(primaryColor, fallback.primaryColor),
      accentColor: _nonEmpty(accentColor, fallback.accentColor),
      backgroundColor: _nonEmpty(backgroundColor, fallback.backgroundColor),
      textColor: _nonEmpty(textColor, fallback.textColor),
      titleColor: _nonEmpty(titleColor, fallback.titleColor),
      fontFamily: _nonEmpty(fontFamily, fallback.fontFamily),
    );
  }
}

@JsonSerializable()
class RestaurantHomeModel {
  @JsonKey(name: 'hero_title')
  final String? heroTitle;

  @JsonKey(name: 'hero_subtitle')
  final String? heroSubtitle;

  @JsonKey(name: 'show_welcome_message')
  final bool? showWelcomeMessage;

  @JsonKey(name: 'show_banner')
  final bool? showBanner;

  final List<BannerModel>? banners;

  const RestaurantHomeModel({
    this.heroTitle,
    this.heroSubtitle,
    this.showWelcomeMessage,
    this.showBanner,
    this.banners,
  });

  factory RestaurantHomeModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantHomeModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantHomeModelToJson(this);

  HomeContent toEntity() => HomeContent(
    heroTitle: heroTitle ?? '',
    heroSubtitle: heroSubtitle ?? '',
    showWelcomeMessage: showWelcomeMessage ?? true,
    showBanner: showBanner ?? true,
    banners: [for (final banner in banners ?? const []) banner.toEntity()],
  );
}

@JsonSerializable()
class BannerModel {
  final int? id;
  final String? image;
  final String? title;
  final String? subtitle;

  @JsonKey(name: 'button_text')
  final String? buttonText;

  @JsonKey(name: 'link_type')
  final String? linkType;

  @JsonKey(name: 'category_id')
  final int? categoryId;

  @JsonKey(name: 'item_id')
  final int? itemId;

  final String? url;

  const BannerModel({
    this.id,
    this.image,
    this.title,
    this.subtitle,
    this.buttonText,
    this.linkType,
    this.categoryId,
    this.itemId,
    this.url,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

  HomeBanner toEntity() => HomeBanner(
    id: id,
    image: image ?? '',
    title: title ?? '',
    subtitle: subtitle ?? '',
    buttonText: buttonText ?? '',
    linkType: linkType ?? '',
    categoryId: categoryId,
    itemId: itemId,
    url: url ?? '',
  );
}

@JsonSerializable()
class RestaurantLocalizationModel {
  final String? locale;
  final String? direction;

  @JsonKey(name: 'default_locale')
  final String? defaultLocale;

  final List<String>? locales;
  final String? timezone;

  const RestaurantLocalizationModel({
    this.locale,
    this.direction,
    this.defaultLocale,
    this.locales,
    this.timezone,
  });

  factory RestaurantLocalizationModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantLocalizationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantLocalizationModelToJson(this);

  StoreLocalization toEntity() => StoreLocalization(
    locale: _nonEmpty(locale, 'ar'),
    direction: _nonEmpty(direction, 'rtl'),
    defaultLocale: _nonEmpty(defaultLocale, 'ar'),
    locales: locales ?? const ['ar', 'en'],
    timezone: _nonEmpty(timezone, 'Asia/Qatar'),
  );
}

@JsonSerializable()
class RestaurantCurrencyModel {
  final String? code;
  final String? symbol;
  final int? decimals;

  const RestaurantCurrencyModel({this.code, this.symbol, this.decimals});

  factory RestaurantCurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantCurrencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantCurrencyModelToJson(this);

  StoreCurrency toEntity() => StoreCurrency(
    code: _nonEmpty(code, 'QAR'),
    symbol: _nonEmpty(symbol, 'ر.ق'),
    decimals: decimals ?? 3,
  );
}

@JsonSerializable()
class RestaurantOrderingModel {
  final bool? enabled;

  @JsonKey(name: 'accepting_orders_now')
  final bool? acceptingOrdersNow;

  @JsonKey(name: 'closed_message')
  final String? closedMessage;

  @JsonKey(name: 'order_types')
  final List<OrderTypeModel>? orderTypes;

  @JsonKey(name: 'payment_methods')
  final List<PaymentMethodModel>? paymentMethods;

  @JsonKey(name: 'require_customer_location')
  final bool? requireCustomerLocation;

  @JsonKey(name: 'show_cart_total')
  final bool? showCartTotal;

  @JsonKey(name: 'tax_percent')
  final num? taxPercent;

  @JsonKey(name: 'service_percent')
  final num? servicePercent;

  @JsonKey(name: 'delivery_fee')
  final num? deliveryFee;

  const RestaurantOrderingModel({
    this.enabled,
    this.acceptingOrdersNow,
    this.closedMessage,
    this.orderTypes,
    this.paymentMethods,
    this.requireCustomerLocation,
    this.showCartTotal,
    this.taxPercent,
    this.servicePercent,
    this.deliveryFee,
  });

  factory RestaurantOrderingModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantOrderingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantOrderingModelToJson(this);

  OrderingSettings toEntity() => OrderingSettings(
    enabled: enabled ?? false,
    acceptingOrdersNow: acceptingOrdersNow ?? false,
    closedMessage: closedMessage ?? '',
    orderTypes: [
      for (final option in orderTypes ?? const []) option.toEntity(),
    ],
    paymentMethods: [
      for (final method in paymentMethods ?? const []) method.toEntity(),
    ],
    requireCustomerLocation: requireCustomerLocation ?? false,
    showCartTotal: showCartTotal ?? true,
    taxPercent: (taxPercent ?? 0).toDouble(),
    servicePercent: (servicePercent ?? 0).toDouble(),
    deliveryFee: (deliveryFee ?? 0).toDouble(),
  );
}

@JsonSerializable()
class OrderTypeModel {
  final String? value;
  final String? label;

  const OrderTypeModel({this.value, this.label});

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) =>
      _$OrderTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTypeModelToJson(this);

  OrderOption toEntity() => OrderOption(
    value: _nonEmpty(value, ''),
    label: _nonEmpty(label, _nonEmpty(value, '')),
  );
}

@JsonSerializable()
class PaymentMethodModel {
  final String? value;
  final String? label;

  const PaymentMethodModel({this.value, this.label});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  PaymentOption toEntity() => PaymentOption(
    value: _nonEmpty(value, ''),
    label: _nonEmpty(label, _nonEmpty(value, '')),
  );
}

@JsonSerializable()
class RestaurantReservationsModel {
  final bool? enabled;

  const RestaurantReservationsModel({this.enabled});

  factory RestaurantReservationsModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantReservationsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantReservationsModelToJson(this);
}

@JsonSerializable()
class RestaurantOnlinePaymentModel {
  final bool? enabled;
  final String? gateway;

  const RestaurantOnlinePaymentModel({this.enabled, this.gateway});

  factory RestaurantOnlinePaymentModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantOnlinePaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantOnlinePaymentModelToJson(this);
}

@JsonSerializable()
class RestaurantContactModel {
  final String? phone;
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? location;

  const RestaurantContactModel({
    this.phone,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.location,
  });

  factory RestaurantContactModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantContactModelToJson(this);

  StoreContact toEntity() => StoreContact(
    phone: phone ?? '',
    whatsapp: whatsapp ?? '',
    instagram: instagram ?? '',
    facebook: facebook ?? '',
    location: location ?? '',
  );
}

String _nonEmpty(String? value, String fallback) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? fallback : trimmed;
}

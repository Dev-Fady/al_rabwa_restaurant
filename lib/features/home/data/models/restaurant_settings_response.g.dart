// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantSettingsResponse _$RestaurantSettingsResponseFromJson(
  Map<String, dynamic> json,
) => RestaurantSettingsResponse(
  success: json['success'] as bool? ?? false,
  message: json['message'] as String? ?? '',
  data: json['data'] == null
      ? null
      : RestaurantSettingsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RestaurantSettingsResponseToJson(
  RestaurantSettingsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

RestaurantSettingsData _$RestaurantSettingsDataFromJson(
  Map<String, dynamic> json,
) => RestaurantSettingsData(
  restaurant: json['restaurant'] == null
      ? null
      : RestaurantModel.fromJson(json['restaurant'] as Map<String, dynamic>),
  theme: json['theme'] == null
      ? null
      : RestaurantThemeModel.fromJson(json['theme'] as Map<String, dynamic>),
  home: json['home'] == null
      ? null
      : RestaurantHomeModel.fromJson(json['home'] as Map<String, dynamic>),
  localization: json['localization'] == null
      ? null
      : RestaurantLocalizationModel.fromJson(
          json['localization'] as Map<String, dynamic>,
        ),
  currency: json['currency'] == null
      ? null
      : RestaurantCurrencyModel.fromJson(
          json['currency'] as Map<String, dynamic>,
        ),
  ordering: json['ordering'] == null
      ? null
      : RestaurantOrderingModel.fromJson(
          json['ordering'] as Map<String, dynamic>,
        ),
  reservations: json['reservations'] == null
      ? null
      : RestaurantReservationsModel.fromJson(
          json['reservations'] as Map<String, dynamic>,
        ),
  onlinePayment: json['online_payment'] == null
      ? null
      : RestaurantOnlinePaymentModel.fromJson(
          json['online_payment'] as Map<String, dynamic>,
        ),
  contact: json['contact'] == null
      ? null
      : RestaurantContactModel.fromJson(
          json['contact'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$RestaurantSettingsDataToJson(
  RestaurantSettingsData instance,
) => <String, dynamic>{
  'restaurant': instance.restaurant?.toJson(),
  'theme': instance.theme?.toJson(),
  'home': instance.home?.toJson(),
  'localization': instance.localization?.toJson(),
  'currency': instance.currency?.toJson(),
  'ordering': instance.ordering?.toJson(),
  'reservations': instance.reservations?.toJson(),
  'online_payment': instance.onlinePayment?.toJson(),
  'contact': instance.contact?.toJson(),
};

RestaurantModel _$RestaurantModelFromJson(Map<String, dynamic> json) =>
    RestaurantModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      subdomain: json['subdomain'] as String?,
      url: json['url'] as String?,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      tagline: json['tagline'] as String?,
    );

Map<String, dynamic> _$RestaurantModelToJson(RestaurantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subdomain': instance.subdomain,
      'url': instance.url,
      'logo': instance.logo,
      'description': instance.description,
      'tagline': instance.tagline,
    };

RestaurantThemeModel _$RestaurantThemeModelFromJson(
  Map<String, dynamic> json,
) => RestaurantThemeModel(
  primaryColor: json['primary_color'] as String?,
  accentColor: json['accent_color'] as String?,
  backgroundColor: json['background_color'] as String?,
  textColor: json['text_color'] as String?,
  titleColor: json['title_color'] as String?,
  fontFamily: json['font_family'] as String?,
  fontUrl: json['font_url'] as String?,
  template: json['template'] as String?,
  categoryLayout: json['category_layout'] as String?,
  backgroundImage: json['background_image'] as String?,
  menuBackground: json['menu_background'] as String?,
);

Map<String, dynamic> _$RestaurantThemeModelToJson(
  RestaurantThemeModel instance,
) => <String, dynamic>{
  'primary_color': instance.primaryColor,
  'accent_color': instance.accentColor,
  'background_color': instance.backgroundColor,
  'text_color': instance.textColor,
  'title_color': instance.titleColor,
  'font_family': instance.fontFamily,
  'font_url': instance.fontUrl,
  'template': instance.template,
  'category_layout': instance.categoryLayout,
  'background_image': instance.backgroundImage,
  'menu_background': instance.menuBackground,
};

RestaurantHomeModel _$RestaurantHomeModelFromJson(Map<String, dynamic> json) =>
    RestaurantHomeModel(
      heroTitle: json['hero_title'] as String?,
      heroSubtitle: json['hero_subtitle'] as String?,
      showWelcomeMessage: json['show_welcome_message'] as bool?,
      showBanner: json['show_banner'] as bool?,
      banners: (json['banners'] as List<dynamic>?)
          ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RestaurantHomeModelToJson(
  RestaurantHomeModel instance,
) => <String, dynamic>{
  'hero_title': instance.heroTitle,
  'hero_subtitle': instance.heroSubtitle,
  'show_welcome_message': instance.showWelcomeMessage,
  'show_banner': instance.showBanner,
  'banners': instance.banners,
};

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: (json['id'] as num?)?.toInt(),
  image: json['image'] as String?,
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  buttonText: json['button_text'] as String?,
  linkType: json['link_type'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  itemId: (json['item_id'] as num?)?.toInt(),
  url: json['url'] as String?,
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'button_text': instance.buttonText,
      'link_type': instance.linkType,
      'category_id': instance.categoryId,
      'item_id': instance.itemId,
      'url': instance.url,
    };

RestaurantLocalizationModel _$RestaurantLocalizationModelFromJson(
  Map<String, dynamic> json,
) => RestaurantLocalizationModel(
  locale: json['locale'] as String?,
  direction: json['direction'] as String?,
  defaultLocale: json['default_locale'] as String?,
  locales: (json['locales'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  timezone: json['timezone'] as String?,
);

Map<String, dynamic> _$RestaurantLocalizationModelToJson(
  RestaurantLocalizationModel instance,
) => <String, dynamic>{
  'locale': instance.locale,
  'direction': instance.direction,
  'default_locale': instance.defaultLocale,
  'locales': instance.locales,
  'timezone': instance.timezone,
};

RestaurantCurrencyModel _$RestaurantCurrencyModelFromJson(
  Map<String, dynamic> json,
) => RestaurantCurrencyModel(
  code: json['code'] as String?,
  symbol: json['symbol'] as String?,
  decimals: (json['decimals'] as num?)?.toInt(),
);

Map<String, dynamic> _$RestaurantCurrencyModelToJson(
  RestaurantCurrencyModel instance,
) => <String, dynamic>{
  'code': instance.code,
  'symbol': instance.symbol,
  'decimals': instance.decimals,
};

RestaurantOrderingModel _$RestaurantOrderingModelFromJson(
  Map<String, dynamic> json,
) => RestaurantOrderingModel(
  enabled: json['enabled'] as bool?,
  acceptingOrdersNow: json['accepting_orders_now'] as bool?,
  closedMessage: json['closed_message'] as String?,
  workingHours: json['working_hours'] as Map<String, dynamic>?,
  orderTypes: (json['order_types'] as List<dynamic>?)
      ?.map((e) => OrderTypeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentMethods: (json['payment_methods'] as List<dynamic>?)
      ?.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  requireCustomerLocation: json['require_customer_location'] as bool?,
  showCartTotal: json['show_cart_total'] as bool?,
  taxPercent: json['tax_percent'] as num?,
  servicePercent: json['service_percent'] as num?,
  deliveryFee: json['delivery_fee'] as num?,
  deliveryZones: (json['delivery_zones'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$RestaurantOrderingModelToJson(
  RestaurantOrderingModel instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'accepting_orders_now': instance.acceptingOrdersNow,
  'closed_message': instance.closedMessage,
  'working_hours': instance.workingHours,
  'order_types': instance.orderTypes,
  'payment_methods': instance.paymentMethods,
  'require_customer_location': instance.requireCustomerLocation,
  'show_cart_total': instance.showCartTotal,
  'tax_percent': instance.taxPercent,
  'service_percent': instance.servicePercent,
  'delivery_fee': instance.deliveryFee,
  'delivery_zones': instance.deliveryZones,
};

OrderTypeModel _$OrderTypeModelFromJson(Map<String, dynamic> json) =>
    OrderTypeModel(
      value: json['value'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$OrderTypeModelToJson(OrderTypeModel instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      value: json['value'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};

RestaurantReservationsModel _$RestaurantReservationsModelFromJson(
  Map<String, dynamic> json,
) => RestaurantReservationsModel(enabled: json['enabled'] as bool?);

Map<String, dynamic> _$RestaurantReservationsModelToJson(
  RestaurantReservationsModel instance,
) => <String, dynamic>{'enabled': instance.enabled};

RestaurantOnlinePaymentModel _$RestaurantOnlinePaymentModelFromJson(
  Map<String, dynamic> json,
) => RestaurantOnlinePaymentModel(
  enabled: json['enabled'] as bool?,
  gateway: json['gateway'] as String?,
);

Map<String, dynamic> _$RestaurantOnlinePaymentModelToJson(
  RestaurantOnlinePaymentModel instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'gateway': instance.gateway,
};

RestaurantContactModel _$RestaurantContactModelFromJson(
  Map<String, dynamic> json,
) => RestaurantContactModel(
  phone: json['phone'] as String?,
  whatsapp: json['whatsapp'] as String?,
  instagram: json['instagram'] as String?,
  facebook: json['facebook'] as String?,
  location: json['location'] as String?,
);

Map<String, dynamic> _$RestaurantContactModelToJson(
  RestaurantContactModel instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'whatsapp': instance.whatsapp,
  'instagram': instance.instagram,
  'facebook': instance.facebook,
  'location': instance.location,
};

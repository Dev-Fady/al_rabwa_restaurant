import 'package:al_rabwa_restaurant/features/home/data/models/restaurant_settings_response.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';

/// Payload copied from `GET /api/settings?lang=ar` for the Al Rabwa
/// restaurant. Shared by the settings mapping, repository and widget tests.
Map<String, dynamic> settingsPayload({String name = 'مطعم الربوة'}) {
  return {
    'data': {
      'restaurant': {
        'id': 2,
        'name': name,
        'subdomain': 'al-rabwah',
        'url': 'https://al-rabwah.smartmenues.com',
        'logo':
            'https://al-rabwah.smartmenues.com/storage/restaurants/2/branding/logo.jpg',
        'description': null,
        'tagline': null,
      },
      'theme': {
        'primary_color': '#174722',
        'accent_color': '#c7df39',
        'background_color': '#faf9f5',
        'text_color': '#161a17',
        'title_color': '#174722',
        'font_family': 'Cairo',
        'font_url': 'https://fonts.bunny.net/css?family=cairo',
        'template': 'classic',
        'category_layout': 'grid',
        'background_image': null,
        'menu_background': null,
      },
      'home': {
        'hero_title': null,
        'hero_subtitle': null,
        'show_welcome_message': true,
        'show_banner': true,
        'banners': [
          {
            'id': 3,
            'image':
                'https://al-rabwah.smartmenues.com/storage/restaurants/2/banners/banner.jpg',
            'title': 'مشاوي على الفحم',
            'subtitle': 'نكهة تستاهل التجربة',
            'button_text': null,
            'link_type': 'category',
            'category_id': 11,
            'item_id': null,
            'url': null,
          },
        ],
      },
      'localization': {
        'locale': 'ar',
        'direction': 'rtl',
        'default_locale': 'ar',
        'locales': ['ar', 'en'],
        'timezone': 'Asia/Qatar',
      },
      'currency': {'code': 'QAR', 'symbol': 'ر.ق', 'decimals': 3},
      'ordering': {
        'enabled': true,
        'accepting_orders_now': true,
        'closed_message': null,
        'working_hours': null,
        'order_types': [
          {'value': 'delivery', 'label': 'توصيل'},
          {'value': 'takeaway', 'label': 'استلام من المطعم'},
          {'value': 'dine_in', 'label': 'داخل المطعم'},
        ],
        'payment_methods': [
          {'value': 'cash', 'label': 'نقدًا'},
        ],
        'require_customer_location': false,
        'show_cart_total': true,
        'tax_percent': 0,
        'service_percent': 0,
        'delivery_fee': 0,
        'delivery_zones': [],
      },
      'reservations': {'enabled': false},
      'online_payment': {'enabled': false, 'gateway': null},
      'contact': {
        'phone': null,
        'whatsapp': null,
        'instagram': null,
        'facebook': null,
        'location': null,
      },
    },
  };
}

RestaurantSettings sampleSettings({String name = 'مطعم الربوة'}) {
  return RestaurantSettingsResponse.fromJson(
    settingsPayload(name: name),
  ).toEntity()!;
}

/// Banner-free settings, used by widget tests that should not hit the network.
RestaurantSettings sampleSettingsWithoutImages() {
  final settings = sampleSettings();
  return settings.copyWith(
    home: settings.home.copyWith(
      banners: [
        for (final banner in settings.home.banners) banner.copyWith(image: ''),
      ],
    ),
  );
}

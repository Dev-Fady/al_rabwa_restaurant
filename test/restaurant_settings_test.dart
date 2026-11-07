import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/data/models/restaurant_settings_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/settings_fixtures.dart';

void main() {
  group('RestaurantSettingsResponse', () {
    test('maps the restaurant payload to the domain entity', () {
      final settings = RestaurantSettingsResponse.fromJson(
        settingsPayload(),
      ).toEntity()!;

      expect(settings.restaurant.name, 'مطعم الربوة');
      expect(settings.restaurant.id, 2);
      expect(settings.restaurant.hasLogo, isTrue);

      expect(settings.theme.primaryColor, '#174722');
      expect(settings.theme.accentColor, '#c7df39');
      expect(settings.theme.backgroundColor, '#faf9f5');
      expect(settings.theme.fontFamily, 'Cairo');
      expect(settings.theme.fontUrl, contains('fonts.bunny.net'));
      expect(settings.theme.template, 'classic');
      expect(settings.theme.categoryLayout, 'grid');
      expect(settings.theme.backgroundImage, '');
      expect(settings.theme.menuBackground, '');

      expect(settings.home.showWelcomeMessage, isTrue);
      expect(settings.home.showBanner, isTrue);
      expect(settings.home.banners, hasLength(1));
      expect(settings.primaryBanner?.title, 'مشاوي على الفحم');
      expect(settings.primaryBanner?.subtitle, 'نكهة تستاهل التجربة');
      expect(settings.primaryBanner?.opensMenu, isTrue);

      expect(settings.localization.isRtl, isTrue);
      expect(settings.localization.locales, containsAll(['ar', 'en']));

      expect(settings.currency.code, 'QAR');
      expect(settings.currency.symbol, 'ر.ق');
      expect(settings.currency.decimals, 3);
      expect(settings.currency.format(12), '12.000 ر.ق');

      expect(settings.ordering.enabled, isTrue);
      expect(settings.ordering.acceptingOrdersNow, isTrue);
      expect(settings.isOpenNow, isTrue);
      expect(settings.ordering.orderTypes.map((option) => option.label), [
        'توصيل',
        'استلام من المطعم',
        'داخل المطعم',
      ]);
      expect(settings.ordering.paymentMethods.single.label, 'نقدًا');
      expect(settings.ordering.deliveryFee, 0);

      expect(settings.reservationsEnabled, isFalse);
      expect(settings.onlinePaymentEnabled, isFalse);
      expect(settings.onlinePaymentGateway, '');
      expect(settings.contact.hasAny, isFalse);
      expect(settings.ordering.workingHours, isEmpty);
      expect(settings.ordering.deliveryZones, isEmpty);
    });

    test('maps optional configuration sections when present', () {
      final payload = settingsPayload();
      final data = payload['data'] as Map<String, dynamic>;
      (data['theme'] as Map<String, dynamic>)['background_image'] =
          'https://example.com/bg.jpg';
      (data['theme'] as Map<String, dynamic>)['menu_background'] =
          'https://example.com/menu.jpg';
      (data['ordering'] as Map<String, dynamic>)['working_hours'] = {
        'friday': {'open': '13:00', 'close': '23:00'},
      };
      (data['ordering'] as Map<String, dynamic>)['delivery_zones'] = [
        {'id': 1, 'name': 'الدوحة', 'fee': 5},
      ];
      (data['ordering'] as Map<String, dynamic>)['delivery_fee'] = 5;
      (data['ordering'] as Map<String, dynamic>)['tax_percent'] = 2.5;
      (data['ordering'] as Map<String, dynamic>)['service_percent'] = 10;
      (data['ordering'] as Map<String, dynamic>)['require_customer_location'] =
          true;
      (data['reservations'] as Map<String, dynamic>)['enabled'] = true;
      (data['online_payment'] as Map<String, dynamic>)['enabled'] = true;
      (data['online_payment'] as Map<String, dynamic>)['gateway'] = 'visa';
      data['contact'] = {
        'phone': '+97433363803',
        'whatsapp': '97433363803',
        'instagram': 'alrabwah',
        'facebook': 'https://facebook.com/alrabwah',
        'location': 'الدوحة، قطر',
      };

      final settings = RestaurantSettingsResponse.fromJson(payload).toEntity()!;

      expect(settings.theme.backgroundImage, 'https://example.com/bg.jpg');
      expect(settings.theme.menuBackground, 'https://example.com/menu.jpg');
      expect(settings.ordering.hasWorkingHours, isTrue);
      expect(settings.ordering.hasDeliveryZones, isTrue);
      expect(settings.ordering.deliveryZones.single['name'], 'الدوحة');
      expect(settings.ordering.requireCustomerLocation, isTrue);
      expect(settings.ordering.hasExtraFees, isTrue);
      expect(settings.reservationsEnabled, isTrue);
      expect(settings.onlinePaymentEnabled, isTrue);
      expect(settings.onlinePaymentGateway, 'visa');
      expect(settings.contact.hasAny, isTrue);
      expect(settings.contact.phone, '+97433363803');
      expect(settings.contact.hasSocialLinks, isFalse);
    });

    test('falls back to safe defaults for empty and malformed payloads', () {
      final settings = RestaurantSettingsResponse.fromJson({
        'data': {
          'restaurant': null,
          'theme': {'primary_color': '', 'accent_color': 'not-a-color'},
          'ordering': {'order_types': []},
        },
      }).toEntity()!;

      expect(settings.restaurant.name, '');
      expect(settings.theme.primaryColor, '#174722');
      // Non-empty values are passed through unchanged; invalid hex strings are
      // handled when the theme is built.
      expect(settings.theme.accentColor, 'not-a-color');
      expect(settings.ordering.enabled, isFalse);
      expect(settings.ordering.orderTypes, isEmpty);
      expect(settings.isOpenNow, isFalse);
      expect(settings.primaryBanner, isNull);
      expect(settings.currency.decimals, 3);
    });

    test('returns null when the payload has no data', () {
      expect(RestaurantSettingsResponse.fromJson(const {}).toEntity(), isNull);
    });
  });

  group('AppTheme.parseHexColor', () {
    test('uses the restaurant theme values to build the app color scheme', () {
      final theme = AppTheme.light(
        primaryHex: '#123456',
        accentHex: '#ABCDEF',
        backgroundHex: '#F1F2F3',
        textHex: '#101112',
        titleHex: '#654321',
        fontFamily: 'Cairo',
      );

      expect(theme.colorScheme.primary, const Color(0xFF123456));
      expect(theme.colorScheme.secondary, const Color(0xFFABCDEF));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF1F2F3));
      expect(theme.colorScheme.onSurface, const Color(0xFF101112));
      expect(
        theme.extension<AppColors>()!.titleColor,
        const Color(0xFF654321),
      );
    });

    test('parses short and long hex values', () {
      expect(AppTheme.parseHexColor('#174722'), const Color(0xFF174722));
      expect(AppTheme.parseHexColor('c7df39'), const Color(0xFFC7DF39));
      expect(AppTheme.parseHexColor('#f53'), const Color(0xFFFF5533));
      expect(AppTheme.parseHexColor('#FF174722'), const Color(0xFF174722));
    });

    test('returns null for blank or invalid values', () {
      expect(AppTheme.parseHexColor(null), isNull);
      expect(AppTheme.parseHexColor('  '), isNull);
      expect(AppTheme.parseHexColor('#12'), isNull);
      expect(AppTheme.parseHexColor('green'), isNull);
    });
  });
}

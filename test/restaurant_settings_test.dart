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
      expect(settings.contact.hasAny, isFalse);
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

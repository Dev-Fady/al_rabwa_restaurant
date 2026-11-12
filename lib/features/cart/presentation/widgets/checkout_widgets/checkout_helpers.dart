import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:flutter/material.dart';

/// Icon that represents an address kind in the checkout address selector.
IconData checkoutAddressIcon(AddressKind kind) {
  switch (kind) {
    case AddressKind.home:
      return Icons.home_outlined;
    case AddressKind.work:
      return Icons.work_outline;
    case AddressKind.other:
      return Icons.location_on_outlined;
  }
}

/// Emoji shown next to an order type option, when one is available.
String? checkoutOrderTypeEmoji(String value) {
  switch (value) {
    case 'delivery':
      return '🛵';
    case 'takeaway':
      return '🏪';
    case 'dine_in':
      return '🍽️';
    default:
      return null;
  }
}

/// Localized payment method label used by the selector and the bottom bar.
String checkoutPaymentLabel(PaymentOption method, BuildContext context) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final rawLabel = method.label.trim();
  if (isArabic) {
    if (method.value == 'cash' && (rawLabel == 'نقدًا' || rawLabel == 'نقدا')) {
      return 'نقدًا عند الاستلام';
    }
    if (method.value == 'card' && rawLabel == 'بطاقة') {
      return 'بطاقة عند الاستلام';
    }
  } else {
    if (method.value == 'cash' && rawLabel.toLowerCase() == 'cash') {
      return 'Cash on delivery';
    }
    if (method.value == 'card' && rawLabel.toLowerCase() == 'card') {
      return 'Card on delivery';
    }
  }
  return rawLabel;
}

/// Icon shown next to an order type option, when one is available.
IconData? checkoutOrderTypeIcon(String value) {
  switch (value) {
    case 'delivery':
      return Icons.delivery_dining_outlined;
    case 'takeaway':
      return Icons.shopping_bag_outlined;
    case 'dine_in':
      return Icons.table_restaurant_outlined;
    default:
      return null;
  }
}

/// Icon shown next to a payment method option.
IconData checkoutPaymentIcon(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('cash')) return Icons.payments_outlined;
  if (normalized.contains('card')) return Icons.credit_card_outlined;
  if (normalized.contains('online') ||
      normalized.contains('wallet') ||
      normalized.contains('gateway')) {
    return Icons.account_balance_wallet_outlined;
  }
  return Icons.payments_outlined;
}

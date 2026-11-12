import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/orders/data/models/order_response.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';

/// Sends the checkout to `POST /api/orders`.
abstract class OrdersRemoteDataSource {
  Future<Order> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<Order> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  }) async {
    final response = await apiService.createOrder(
      body: _body(cart, draft),
      idempotencyKey: idempotencyKey,
      lang: lang,
      xLocale: lang,
    );

    final raw = _decodeBody(response.data);
    final parsed = OrderResponse.fromJson(raw);

    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Failed to place the order.' : parsed.message,
      );
    }

    final order = parsed.toEntity();
    if (order == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return order;
  }

  Map<String, dynamic> _body(Cart cart, OrderDraft draft) {
    final notes = draft.trimmedNotes;

    return {
      'type': draft.orderType,
      'payment_method': draft.paymentMethod,
      if (draft.requiresAddress && draft.addressId != null)
        'address_id': draft.addressId,
      if (draft.diningTableId != null) 'dining_table_id': draft.diningTableId,
      if (notes.isNotEmpty) 'notes': notes,
      'lines': [
        for (final line in cart.lines)
          if (line.item.id != null)
            {
              'item_id': line.item.id,
              'option_id': line.option?.id,
              'addons': [
                for (final addon in line.addons)
                  if (addon.id != null) addon.id,
              ],
              // The API treats the quantity of a weight-priced dish as kilos,
              // so `0.25 kg x 2` is sent as `0.5`.
              'quantity': line.item.soldByWeight
                  ? line.weight * line.quantity
                  : line.quantity,
              'note': line.hasNotes ? line.notes.trim() : null,
            },
      ],
    };
  }

  Map<String, dynamic> _decodeBody(dynamic body) {
    final Map<String, dynamic>? raw;
    if (body is Map<String, dynamic>) {
      raw = body;
    } else if (body is Map) {
      raw = Map<String, dynamic>.from(body);
    } else if (body is String && body.trim().isNotEmpty) {
      raw = _asMap(jsonDecode(body));
    } else {
      raw = null;
    }

    if (raw == null) {
      throw ServerFailure('Empty response from server.');
    }

    return raw;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}

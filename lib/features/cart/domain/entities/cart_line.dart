import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

/// One dish in the cart with its chosen quantity and kitchen notes.
class CartLine {
  const CartLine({required this.item, this.quantity = 1, this.notes = ''});

  final MenuItem item;
  final int quantity;
  final String notes;

  double get lineTotal => item.price * quantity;

  bool get hasNotes => notes.trim().isNotEmpty;

  CartLine copyWith({MenuItem? item, int? quantity, String? notes}) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

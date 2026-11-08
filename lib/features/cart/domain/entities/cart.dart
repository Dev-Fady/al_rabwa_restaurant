import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

import 'cart_line.dart';

/// In-memory cart. Dishes are keyed by their id and keep the chosen quantity.
class Cart {
  const Cart({this.lines = const []});

  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  bool get isNotEmpty => lines.isNotEmpty;

  /// Number of distinct dishes, shown as "أصناف" in the menu summary.
  int get itemsCount => lines.length;

  int get totalQuantity =>
      lines.fold(0, (total, line) => total + line.quantity);

  double get subtotal => lines.fold(0, (total, line) => total + line.lineTotal);

  CartLine? lineFor(int? itemId) {
    if (itemId == null) return null;
    for (final line in lines) {
      if (line.item.id == itemId) return line;
    }
    return null;
  }

  /// Total quantity of a dish across all of its selections.
  int quantityOf(int? itemId) {
    if (itemId == null) return 0;
    return lines.fold(
      0,
      (total, line) => line.item.id == itemId ? total + line.quantity : total,
    );
  }

  Cart add(
    MenuItem item, {
    int quantity = 1,
    String notes = '',
    MenuItemOption? option,
    List<MenuItemAddon> addons = const [],
    double weight = 1,
  }) {
    final id = item.id;
    if (id == null || quantity <= 0) return this;

    final index = lines.indexWhere(
      (line) =>
          line.matches(item, option: option, addons: addons, weight: weight),
    );
    if (index == -1) {
      return Cart(
        lines: [
          ...lines,
          CartLine(
            item: item,
            quantity: quantity,
            notes: notes.trim(),
            option: option,
            addons: addons,
            weight: weight,
          ),
        ],
      );
    }

    final existing = lines[index];
    final updated = existing.copyWith(
      item: item,
      quantity: existing.quantity + quantity,
      notes: notes.trim().isEmpty ? existing.notes : notes.trim(),
    );

    return _replaceAt(index, updated);
  }

  /// Adds one more of a dish, reusing its latest line whatever its selections.
  Cart increment(MenuItem item) {
    final id = item.id;
    if (id == null) return this;

    final index = lines.lastIndexWhere((line) => line.item.id == id);
    if (index == -1) return add(item);

    final existing = lines[index];
    return _replaceAt(
      index,
      existing.copyWith(quantity: existing.quantity + 1),
    );
  }

  Cart decrement(MenuItem item) {
    final id = item.id;
    if (id == null) return this;

    final index = lines.lastIndexWhere((line) => line.item.id == id);
    if (index == -1) return this;

    final existing = lines[index];
    if (existing.quantity <= 1) {
      return Cart(
        lines: [
          for (var i = 0; i < lines.length; i++)
            if (i != index) lines[i],
        ],
      );
    }

    return _replaceAt(
      index,
      existing.copyWith(quantity: existing.quantity - 1),
    );
  }

  Cart remove(MenuItem item) {
    final id = item.id;
    if (id == null) return this;

    final remaining = [
      for (final line in lines)
        if (line.item.id != id) line,
    ];
    return remaining.length == lines.length ? this : Cart(lines: remaining);
  }

  Cart clear() => const Cart();

  Cart _replaceAt(int index, CartLine line) {
    return Cart(
      lines: [
        for (var i = 0; i < lines.length; i++)
          if (i == index) line else lines[i],
      ],
    );
  }
}

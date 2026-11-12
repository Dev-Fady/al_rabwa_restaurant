import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

import 'cart_line.dart';

/// In-memory cart. Dishes are keyed by their id and keep the chosen quantity.
class Cart {
  const Cart({this.lines = const [], this.orderType = defaultOrderType});

  /// Delivery is the storefront default until the settings load.
  static const String defaultOrderType = 'delivery';

  final List<CartLine> lines;

  /// Order type the cart is quoted and checked out with (`delivery`,
  /// `takeaway`, `dine_in`, ...). Chosen on the home screen.
  final String orderType;

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
      return _copyWithLines([
        ...lines,
        CartLine(
          item: item,
          quantity: quantity,
          notes: notes.trim(),
          option: option,
          addons: addons,
          weight: weight,
        ),
      ]);
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
      return _copyWithLines([
        for (var i = 0; i < lines.length; i++)
          if (i != index) lines[i],
      ]);
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
    return remaining.length == lines.length ? this : _copyWithLines(remaining);
  }

  /// Edits one specific line, so dishes with different selections stay apart.
  Cart incrementLine(CartLine line) {
    final index = _indexOfLine(line);
    if (index == -1) return this;
    return _replaceAt(index, line.copyWith(quantity: line.quantity + 1));
  }

  Cart decrementLine(CartLine line) {
    final index = _indexOfLine(line);
    if (index == -1) return this;
    if (line.quantity <= 1) {
      return _copyWithLines([
        for (var i = 0; i < lines.length; i++)
          if (i != index) lines[i],
      ]);
    }
    return _replaceAt(index, line.copyWith(quantity: line.quantity - 1));
  }

  Cart removeLine(CartLine line) {
    final index = _indexOfLine(line);
    if (index == -1) return this;
    return _copyWithLines([
      for (var i = 0; i < lines.length; i++)
        if (i != index) lines[i],
    ]);
  }

  int _indexOfLine(CartLine line) {
    return lines.indexWhere(
      (candidate) =>
          candidate.notes == line.notes &&
          candidate.matches(
            line.item,
            option: line.option,
            addons: line.addons,
            weight: line.weight,
          ),
    );
  }

  Cart clear() => Cart(orderType: orderType);

  /// Keeps the chosen order type when the cart is re-quoted or edited.
  Cart withOrderType(String type) {
    final normalized = type.trim();
    if (normalized.isEmpty || normalized == orderType) return this;
    return Cart(lines: lines, orderType: normalized);
  }

  Cart _replaceAt(int index, CartLine line) {
    return _copyWithLines([
      for (var i = 0; i < lines.length; i++)
        if (i == index) line else lines[i],
    ]);
  }

  Cart _copyWithLines(List<CartLine> newLines) {
    return Cart(lines: newLines, orderType: orderType);
  }
}

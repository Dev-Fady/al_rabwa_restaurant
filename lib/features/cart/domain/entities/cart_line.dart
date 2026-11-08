import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

/// One dish in the cart with its chosen quantity, extras, weight and notes.
class CartLine {
  const CartLine({
    required this.item,
    this.quantity = 1,
    this.notes = '',
    this.option,
    this.addons = const [],
    this.weight = 1,
  });

  final MenuItem item;
  final int quantity;
  final String notes;

  /// The chosen portion, when the dish has options.
  final MenuItemOption? option;

  /// The chosen extras, if any.
  final List<MenuItemAddon> addons;

  /// Chosen weight in kilos; `1` for dishes that are not sold by weight.
  final double weight;

  /// Portion and extras, which are charged once per dish rather than per kilo.
  double get extrasTotal =>
      (option?.price ?? 0) +
      addons.fold<double>(0, (total, addon) => total + addon.price);

  /// Price of one unit, including the chosen weight.
  double get unitPrice => item.price * weight + extrasTotal;

  double get lineTotal => unitPrice * quantity;

  bool get hasNotes => notes.trim().isNotEmpty;

  bool get hasExtras => option != null || addons.isNotEmpty;

  bool get isSoldByWeight => weight > 0 && weight != 1;

  /// Whether this line was added with the same dish selections.
  bool matches(
    MenuItem item, {
    MenuItemOption? option,
    List<MenuItemAddon> addons = const [],
    double weight = 1,
  }) {
    if (this.item.id != item.id) return false;
    if (this.option?.id != option?.id) return false;
    if ((this.weight - weight).abs() > 0.0001) return false;

    final current = [for (final addon in this.addons) addon.id]..sort();
    final incoming = [for (final addon in addons) addon.id]..sort();
    if (current.length != incoming.length) return false;
    for (var index = 0; index < current.length; index++) {
      if (current[index] != incoming[index]) return false;
    }

    return true;
  }

  CartLine copyWith({
    MenuItem? item,
    int? quantity,
    String? notes,
    MenuItemOption? option,
    List<MenuItemAddon>? addons,
    double? weight,
  }) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      option: option ?? this.option,
      addons: addons ?? this.addons,
      weight: weight ?? this.weight,
    );
  }
}

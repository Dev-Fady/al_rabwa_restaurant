import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_line.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide cart shared by the menu, dish details and the cart badge.
class CartCubit extends Cubit<Cart> {
  CartCubit() : super(const Cart());

  void add(
    MenuItem item, {
    int quantity = 1,
    String notes = '',
    MenuItemOption? option,
    List<MenuItemAddon> addons = const [],
    double weight = 1,
  }) {
    emit(
      state.add(
        item,
        quantity: quantity,
        notes: notes,
        option: option,
        addons: addons,
        weight: weight,
      ),
    );
  }

  /// Quick-add from a menu card: uses the dish's default portion and weight so
  /// the quote request always carries the option the backend requires.
  void addDefault(MenuItem item) {
    add(item, option: item.defaultOption, weight: item.defaultWeight);
  }

  void increment(MenuItem item) => emit(state.increment(item));

  void decrement(MenuItem item) => emit(state.decrement(item));

  void remove(MenuItem item) => emit(state.remove(item));

  void incrementLine(CartLine line) => emit(state.incrementLine(line));

  void decrementLine(CartLine line) => emit(state.decrementLine(line));

  void removeLine(CartLine line) => emit(state.removeLine(line));

  void setOrderType(String type) {
    final updated = state.withOrderType(type);
    if (!identical(updated, state)) emit(updated);
  }

  void clear() => emit(state.clear());
}

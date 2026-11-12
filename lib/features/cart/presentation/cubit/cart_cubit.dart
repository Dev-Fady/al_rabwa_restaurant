import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_line.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide cart shared by the menu, dish details and the cart badge.
/// Automatically restores cached items on cold start and persists updates.
class CartCubit extends Cubit<Cart> {
  CartCubit([this._cartRepository])
      : super(_cartRepository?.loadCart() ?? const Cart());

  final CartRepository? _cartRepository;

  void _persist() {
    _cartRepository?.saveCart(state);
  }

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
    _persist();
  }

  /// Quick-add from a menu card: uses the dish's default portion and weight so
  /// the quote request always carries the option the backend requires.
  void addDefault(MenuItem item) {
    add(item, option: item.defaultOption, weight: item.defaultWeight);
  }

  void increment(MenuItem item) {
    emit(state.increment(item));
    _persist();
  }

  void decrement(MenuItem item) {
    emit(state.decrement(item));
    _persist();
  }

  void remove(MenuItem item) {
    emit(state.remove(item));
    _persist();
  }

  void incrementLine(CartLine line) {
    emit(state.incrementLine(line));
    _persist();
  }

  void decrementLine(CartLine line) {
    emit(state.decrementLine(line));
    _persist();
  }

  void removeLine(CartLine line) {
    emit(state.removeLine(line));
    _persist();
  }

  void setOrderType(String type) {
    final updated = state.withOrderType(type);
    if (!identical(updated, state)) {
      emit(updated);
      _persist();
    }
  }

  void clear() {
    emit(state.clear());
    _cartRepository?.clearCart();
  }
}

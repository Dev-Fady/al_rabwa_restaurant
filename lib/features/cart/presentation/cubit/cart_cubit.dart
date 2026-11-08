import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
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

  void increment(MenuItem item) => emit(state.increment(item));

  void decrement(MenuItem item) => emit(state.decrement(item));

  void remove(MenuItem item) => emit(state.remove(item));

  void clear() => emit(state.clear());
}

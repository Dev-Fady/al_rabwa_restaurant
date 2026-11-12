import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';

/// Contract for persisting and restoring the user's shopping cart across app launches.
abstract class CartRepository {
  Future<void> saveCart(Cart cart);

  Cart? loadCart();

  Future<void> clearCart();
}


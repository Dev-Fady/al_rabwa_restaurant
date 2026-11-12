import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/models/cart_model.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._localDataSource);

  final CartLocalDataSource _localDataSource;

  @override
  Future<void> saveCart(Cart cart) async {
    if (cart.isEmpty) {
      await _localDataSource.clearCart();
    } else {
      await _localDataSource.saveCart(CartModel.fromEntity(cart).toJson());
    }
  }

  @override
  Cart? loadCart() {
    final json = _localDataSource.readCart();
    if (json == null) return null;

    try {
      final model = CartModel.fromJson(json);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCart() async {
    await _localDataSource.clearCart();
  }
}


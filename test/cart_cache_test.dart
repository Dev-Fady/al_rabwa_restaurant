import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/models/cart_model.dart';
import 'package:al_rabwa_restaurant/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _sampleItem = MenuItem(
  id: 40,
  categoryId: 11,
  name: 'مشاوي مشكلة',
  description: 'مشاوي على الفحم طازجة',
  price: 35,
  compareAtPrice: 40,
  soldByWeight: true,
  weightRange: MenuItemWeight(min: 0.25, max: 5.0, step: 0.25),
  options: [
    MenuItemOption(id: 7, name: 'نفر واحد', price: 0),
    MenuItemOption(id: 8, name: 'نفرين', price: 25),
  ],
  addons: [
    MenuItemAddon(id: 34, name: 'إضافة أرز', price: 5),
  ],
);

class _FakeCartLocalDataSource implements CartLocalDataSource {
  Map<String, dynamic>? stored;

  @override
  Future<void> saveCart(Map<String, dynamic> json) async {
    stored = json;
  }

  @override
  Map<String, dynamic>? readCart() => stored;

  @override
  Future<void> clearCart() async {
    stored = null;
  }
}

class _FakeCartRepository implements CartRepository {
  Cart? cached;
  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<void> saveCart(Cart cart) async {
    saveCount++;
    cached = cart;
  }

  @override
  Cart? loadCart() => cached;

  @override
  Future<void> clearCart() async {
    clearCount++;
    cached = null;
  }
}

void main() {
  group('CartModel serialization', () {
    test('preserves all cart fields, lines, portions and addons', () {
      final cart = const Cart(orderType: 'takeaway').add(
        _sampleItem,
        quantity: 2,
        notes: 'بدون بصل',
        weight: 0.5,
        option: const MenuItemOption(id: 8, name: 'نفرين', price: 25),
        addons: const [MenuItemAddon(id: 34, name: 'إضافة أرز', price: 5)],
      );

      final model = CartModel.fromEntity(cart);
      final json = model.toJson();
      final restoredModel = CartModel.fromJson(json);
      final restored = restoredModel.toEntity();

      expect(restored.orderType, 'takeaway');
      expect(restored.lines.length, 1);

      final line = restored.lines.first;
      expect(line.item.id, 40);
      expect(line.item.name, 'مشاوي مشكلة');
      expect(line.item.price, 35);
      expect(line.quantity, 2);
      expect(line.notes, 'بدون بصل');
      expect(line.weight, 0.5);
      expect(line.option?.id, 8);
      expect(line.option?.name, 'نفرين');
      expect(line.option?.price, 25);
      expect(line.addons.length, 1);
      expect(line.addons.first.id, 34);
      expect(line.addons.first.name, 'إضافة أرز');
    });
  });

  group('CartRepositoryImpl', () {
    test('saves cart to local data source and restores it accurately', () async {
      final dataSource = _FakeCartLocalDataSource();
      final repository = CartRepositoryImpl(dataSource);

      final cart = const Cart().add(_sampleItem, quantity: 1);
      await repository.saveCart(cart);

      expect(dataSource.stored, isNotNull);

      final loaded = repository.loadCart();
      expect(loaded, isNotNull);
      expect(loaded!.lines.first.item.name, 'مشاوي مشكلة');

      await repository.clearCart();
      expect(dataSource.stored, isNull);
      expect(repository.loadCart(), isNull);
    });
  });

  group('CartCubit persistence', () {
    test('restores cached cart on startup', () {
      final repository = _FakeCartRepository();
      repository.cached = const Cart(orderType: 'takeaway').add(
        _sampleItem,
        quantity: 3,
      );

      final cubit = CartCubit(repository);
      expect(cubit.state.orderType, 'takeaway');
      expect(cubit.state.lines.length, 1);
      expect(cubit.state.totalQuantity, 3);
    });

    test('persists on add, increment, decrement, and orderType change', () {
      final repository = _FakeCartRepository();
      final cubit = CartCubit(repository);

      cubit.add(_sampleItem, quantity: 1);
      expect(repository.saveCount, 1);
      expect(repository.cached?.lines.length, 1);

      cubit.increment(_sampleItem);
      expect(repository.saveCount, 2);
      expect(repository.cached?.totalQuantity, 2);

      cubit.setOrderType('dine_in');
      expect(repository.saveCount, 3);
      expect(repository.cached?.orderType, 'dine_in');

      cubit.decrement(_sampleItem);
      expect(repository.saveCount, 4);
      expect(repository.cached?.totalQuantity, 1);

      cubit.remove(_sampleItem);
      expect(repository.saveCount, 5);
      expect(repository.cached?.isEmpty, isTrue);
    });

    test('clears cache from repository on clear()', () {
      final repository = _FakeCartRepository();
      final cubit = CartCubit(repository);

      cubit.add(_sampleItem);
      expect(cubit.state.isNotEmpty, isTrue);

      cubit.clear();
      expect(cubit.state.isEmpty, isTrue);
      expect(repository.clearCount, 1);
      expect(repository.cached, isNull);
    });
  });
}


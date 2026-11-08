import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _chicken = MenuItem(id: 40, name: 'دجاج مسحب', price: 35);
const _ribs = MenuItem(id: 44, name: 'ريش', price: 44);

void main() {
  group('Cart', () {
    test('adds a dish once and increments its quantity', () {
      final cart = const Cart().add(_chicken).add(_chicken, quantity: 2);

      expect(cart.itemsCount, 1);
      expect(cart.totalQuantity, 3);
      expect(cart.subtotal, 105);
      expect(cart.quantityOf(40), 3);
    });

    test('tracks distinct dishes and their total', () {
      final cart = const Cart().add(_chicken).add(_ribs);

      expect(cart.itemsCount, 2);
      expect(cart.subtotal, 79);
      expect(cart.quantityOf(40), 1);
      expect(cart.quantityOf(44), 1);
    });

    test('decrement removes the dish at quantity one', () {
      final cart = const Cart().add(_chicken).increment(_chicken);

      expect(cart.decrement(_chicken).quantityOf(40), 1);
      expect(cart.decrement(_chicken).decrement(_chicken).isEmpty, isTrue);
    });

    test('keeps the kitchen notes when adding more of the same dish', () {
      final cart = const Cart().add(_chicken, notes: 'بدون بصل').add(_chicken);

      expect(cart.lines.single.notes, 'بدون بصل');
      expect(cart.lines.single.hasNotes, isTrue);
    });

    test('ignores dishes without an id', () {
      final cart = const Cart().add(const MenuItem(name: 'بلا معرف'));

      expect(cart.isEmpty, isTrue);
    });

    test('prices the chosen weight, option and extras', () {
      const grill = MenuItem(
        id: 31,
        name: 'مشاوي مشكلة',
        price: 39,
        soldByWeight: true,
      );
      final cart = const Cart().add(
        grill,
        weight: 0.5,
        option: const MenuItemOption(id: 8, name: 'نفرين', price: 30),
        addons: [const MenuItemAddon(id: 34, name: 'إضافة أرز', price: 5)],
      );

      expect(cart.lines.single.unitPrice, 54.5);
      expect(cart.subtotal, 54.5);
    });

    test('keeps different selections of a dish as separate lines', () {
      const grill = MenuItem(id: 31, name: 'مشاوي مشكلة', price: 39);
      final cart = const Cart()
          .add(grill, option: const MenuItemOption(id: 7, name: 'نفر واحد'))
          .add(
            grill,
            option: const MenuItemOption(id: 8, name: 'نفرين', price: 30),
          );

      expect(cart.itemsCount, 2);
      expect(cart.quantityOf(31), 2);
      expect(cart.subtotal, 108);
    });
  });

  group('CartCubit', () {
    test('emits the updated cart', () {
      final cubit = CartCubit();
      addTearDown(cubit.close);

      cubit.add(_chicken, quantity: 2);
      expect(cubit.state.totalQuantity, 2);

      cubit.increment(_ribs);
      expect(cubit.state.itemsCount, 2);
      expect(cubit.state.subtotal, 114);

      cubit.decrement(_chicken);
      expect(cubit.state.totalQuantity, 2);

      cubit.decrement(_chicken);
      cubit.decrement(_ribs);
      expect(cubit.state.isEmpty, isTrue);
    });
  });
}

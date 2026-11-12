import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_state.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/repositories/tables_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Loads the delivery addresses and dine-in tables, then sends the order.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._ordersRepository,
    this._addressesRepository,
    this._tablesRepository,
  ) : super(const CheckoutState());

  final OrdersRepository _ordersRepository;
  final AddressesRepository _addressesRepository;
  final TablesRepository _tablesRepository;

  int _addressRequestId = 0;
  int _tableRequestId = 0;

  /// Reused while the customer retries the same order so the backend can
  /// deduplicate it; a fresh key is generated for the next order.
  String? _idempotencyKey;

  Future<void> loadAddresses({required String lang}) async {
    final requestId = ++_addressRequestId;
    emit(
      state.copyWith(
        addressStatus: CheckoutAddressStatus.loading,
        clearAddressError: true,
      ),
    );

    final result = await _addressesRepository.fetchAddresses(lang: lang);
    if (isClosed || requestId != _addressRequestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          addressStatus: CheckoutAddressStatus.failure,
          addressError: failure.message,
        ),
      ),
      (addresses) {
        final selected = _resolveSelected(addresses);
        emit(
          state.copyWith(
            addressStatus: CheckoutAddressStatus.success,
            addresses: List.unmodifiable(addresses),
            selectedAddress: selected,
            clearSelectedAddress: selected == null,
            clearAddressError: true,
          ),
        );
      },
    );
  }

  void selectAddress(Address address) {
    emit(state.copyWith(selectedAddress: address, clearAddressError: true));
  }

  Future<void> loadTables({required String lang}) async {
    final requestId = ++_tableRequestId;
    emit(
      state.copyWith(
        tableStatus: CheckoutTableStatus.loading,
        clearTableError: true,
      ),
    );

    final result = await _tablesRepository.fetchTables(lang: lang);
    if (isClosed || requestId != _tableRequestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          tableStatus: CheckoutTableStatus.failure,
          tableError: failure.message,
        ),
      ),
      (tables) {
        final selected = _resolveSelectedTable(tables);
        emit(
          state.copyWith(
            tableStatus: CheckoutTableStatus.success,
            tables: List.unmodifiable(tables),
            selectedTable: selected,
            clearSelectedTable: selected == null,
            clearTableError: true,
          ),
        );
      },
    );
  }

  void selectTable(DiningTable table) {
    emit(state.copyWith(selectedTable: table, clearTableError: true));
  }

  Future<void> submit({
    required Cart cart,
    required OrderDraft draft,
    String lang = 'ar',
  }) async {
    if (state.isSubmitting) return;

    final idempotencyKey = _idempotencyKey ??= const Uuid().v4();

    emit(
      state.copyWith(
        submitStatus: CheckoutSubmitStatus.submitting,
        clearSubmitError: true,
      ),
    );

    final result = await _ordersRepository.createOrder(
      cart: cart,
      draft: draft,
      idempotencyKey: idempotencyKey,
      lang: lang,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: CheckoutSubmitStatus.failure,
          submitError: failure.message,
        ),
      ),
      (order) {
        _idempotencyKey = null;
        emit(
          state.copyWith(
            submitStatus: CheckoutSubmitStatus.success,
            order: order,
            clearSubmitError: true,
          ),
        );
      },
    );
  }

  /// Keeps the customer's choice when it still exists; otherwise uses the
  /// saved default, then the first address.
  Address? _resolveSelected(List<Address> addresses) {
    if (addresses.isEmpty) return null;

    final previousId = state.selectedAddress?.id;
    if (previousId != null) {
      for (final address in addresses) {
        if (address.id == previousId) return address;
      }
    }

    for (final address in addresses) {
      if (address.isDefault) return address;
    }

    return addresses.first;
  }

  /// Keeps the customer's table when it still exists; never picks one
  /// automatically, because ordering to the wrong table is not recoverable.
  DiningTable? _resolveSelectedTable(List<DiningTable> tables) {
    final previousId = state.selectedTable?.id;
    if (previousId == null) return null;
    for (final table in tables) {
      if (table.id == previousId) return table;
    }
    return null;
  }
}

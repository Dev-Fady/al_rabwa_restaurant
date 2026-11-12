import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';

enum CheckoutAddressStatus { initial, loading, success, failure }

enum CheckoutTableStatus { initial, loading, success, failure }

enum CheckoutSubmitStatus { initial, submitting, success, failure }

/// Address book, dine-in tables and the order-submission state of checkout.
class CheckoutState {
  const CheckoutState({
    this.addressStatus = CheckoutAddressStatus.initial,
    this.addresses = const [],
    this.selectedAddress,
    this.addressError,
    this.tableStatus = CheckoutTableStatus.initial,
    this.tables = const [],
    this.selectedTable,
    this.tableError,
    this.submitStatus = CheckoutSubmitStatus.initial,
    this.order,
    this.submitError,
  });

  final CheckoutAddressStatus addressStatus;
  final List<Address> addresses;
  final Address? selectedAddress;
  final String? addressError;

  final CheckoutTableStatus tableStatus;
  final List<DiningTable> tables;
  final DiningTable? selectedTable;
  final String? tableError;

  final CheckoutSubmitStatus submitStatus;
  final Order? order;
  final String? submitError;

  bool get isLoadingAddresses => addressStatus == CheckoutAddressStatus.loading;

  bool get hasAddresses => addresses.isNotEmpty;

  bool get hasAddressError => addressStatus == CheckoutAddressStatus.failure;

  bool get isLoadingTables => tableStatus == CheckoutTableStatus.loading;

  bool get hasTables => tables.isNotEmpty;

  bool get hasTableError => tableStatus == CheckoutTableStatus.failure;

  bool get isSubmitting => submitStatus == CheckoutSubmitStatus.submitting;

  bool get hasSubmitError => submitStatus == CheckoutSubmitStatus.failure;

  bool get hasOrder => order != null;

  CheckoutState copyWith({
    CheckoutAddressStatus? addressStatus,
    List<Address>? addresses,
    Address? selectedAddress,
    bool clearSelectedAddress = false,
    String? addressError,
    bool clearAddressError = false,
    CheckoutTableStatus? tableStatus,
    List<DiningTable>? tables,
    DiningTable? selectedTable,
    bool clearSelectedTable = false,
    String? tableError,
    bool clearTableError = false,
    CheckoutSubmitStatus? submitStatus,
    Order? order,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return CheckoutState(
      addressStatus: addressStatus ?? this.addressStatus,
      addresses: addresses ?? this.addresses,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      addressError: clearAddressError
          ? null
          : (addressError ?? this.addressError),
      tableStatus: tableStatus ?? this.tableStatus,
      tables: tables ?? this.tables,
      selectedTable: clearSelectedTable
          ? null
          : (selectedTable ?? this.selectedTable),
      tableError: clearTableError ? null : (tableError ?? this.tableError),
      submitStatus: submitStatus ?? this.submitStatus,
      order: order ?? this.order,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}

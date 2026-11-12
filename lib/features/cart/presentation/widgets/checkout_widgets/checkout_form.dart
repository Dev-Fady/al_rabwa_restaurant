import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/cart_quote_summary.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_notice.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_option_selector.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_payment_selector.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_section.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_table_selector.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_address_section.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_helpers.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Editable checkout form: order type, address/table, payment, notes and totals.
class CheckoutForm extends StatelessWidget {
  const CheckoutForm({
    super.key,
    required this.cart,
    required this.settings,
    required this.checkoutState,
    required this.quoteState,
    required this.currency,
    required this.notesController,
    required this.paymentMethod,
    required this.availableTypes,
    required this.isOpen,
    required this.isSupportedType,
    required this.isTypeAvailable,
    required this.isDelivery,
    required this.isDineIn,
    required this.onPaymentChanged,
    required this.onPickAddress,
    required this.onSelectAddress,
    required this.onAddNewAddress,
    required this.onRetryAddresses,
    required this.onRetryTables,
  });

  final Cart cart;
  final RestaurantSettings? settings;
  final CheckoutState checkoutState;
  final CartQuoteState quoteState;
  final StoreCurrency currency;
  final TextEditingController notesController;
  final String? paymentMethod;
  final List<OrderOption> availableTypes;
  final bool isOpen;
  final bool isSupportedType;
  final bool isTypeAvailable;
  final bool isDelivery;
  final bool isDineIn;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onPickAddress;
  final ValueChanged<Address> onSelectAddress;
  final VoidCallback onAddNewAddress;
  final VoidCallback onRetryAddresses;
  final VoidCallback onRetryTables;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final ordering = settings?.ordering;
    final paymentMethods = ordering?.paymentMethods ?? const <PaymentOption>[];
    final closedMessage = (ordering?.closedMessage.trim().isNotEmpty ?? false)
        ? ordering!.closedMessage.trim()
        : l10n.storeClosed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isOpen) ...[
          CheckoutNotice(
            icon: Icons.lock_clock_outlined,
            message: closedMessage,
            color: colors.error,
          ),
          const SizedBox(height: 16),
        ],
        CheckoutSection(
          title: l10n.checkoutOrderType,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isSupportedType) ...[
                CheckoutNotice(
                  icon: Icons.info_outline_rounded,
                  message: l10n.checkoutOrderTypeUnavailable,
                  color: colors.error,
                ),
                const SizedBox(height: 10),
              ] else if (!isTypeAvailable && availableTypes.isNotEmpty) ...[
                CheckoutNotice(
                  icon: Icons.info_outline_rounded,
                  message: l10n.checkoutOrderTypeUnavailable,
                  color: colors.error,
                ),
                const SizedBox(height: 10),
              ],
              if (availableTypes.isEmpty)
                CheckoutNotice(
                  icon: Icons.info_outline_rounded,
                  message: l10n.checkoutOrderTypeUnavailable,
                  color: colors.error,
                )
              else
                CheckoutOptionSelector(
                  options: [
                    for (final type in availableTypes)
                      CheckoutChoice(
                        value: type.value,
                        label: type.label,
                        emoji: checkoutOrderTypeEmoji(type.value),
                        icon: checkoutOrderTypeIcon(type.value),
                      ),
                  ],
                  selectedValue: isTypeAvailable ? cart.orderType : null,
                  onChanged: (value) =>
                      context.read<CartCubit>().setOrderType(value),
                ),
            ],
          ),
        ),
        if (isDelivery) ...[
          const SizedBox(height: 16),
          CheckoutSection(
            title: l10n.checkoutDeliveryAddress,
            subtitle: l10n.checkoutDeliveryAddressSubtitle,
            icon: Icons.location_on_outlined,
            child: CheckoutAddressSection(
              checkoutState: checkoutState,
              onSelectAddress: onSelectAddress,
              onAddNewAddress: onAddNewAddress,
              onPickAddress: onPickAddress,
              onRetryAddresses: onRetryAddresses,
            ),
          ),
        ],
        if (isDineIn) ...[
          const SizedBox(height: 16),
          CheckoutSection(
            title: l10n.checkoutTable,
            subtitle: l10n.checkoutTableSubtitle,
            icon: Icons.table_restaurant_outlined,
            child: CheckoutTableSelector(
              tables: checkoutState.tables,
              selectedTable: checkoutState.selectedTable,
              loading: checkoutState.isLoadingTables,
              error: checkoutState.hasTableError
                  ? checkoutState.tableError
                  : null,
              onChanged: (table) =>
                  context.read<CheckoutCubit>().selectTable(table),
              onRetry: onRetryTables,
            ),
          ),
        ],
        const SizedBox(height: 16),
        CheckoutSection(
          title: l10n.checkoutPaymentMethod,
          child: paymentMethods.isEmpty
              ? CheckoutNotice(
                  icon: Icons.payments_outlined,
                  message: l10n.checkoutNoPaymentMethods,
                  color: colors.error,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckoutPaymentSelector(
                      options: [
                        for (final method in paymentMethods)
                          CheckoutChoice(
                            value: method.value,
                            label: checkoutPaymentLabel(method, context),
                            icon: checkoutPaymentIcon(method.value),
                          ),
                      ],
                      selectedValue: paymentMethod,
                      onChanged: onPaymentChanged,
                    ),
                    if (paymentMethod == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.checkoutPaymentRequired,
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 16),
        CheckoutSection(
          title: l10n.checkoutNotes,
          icon: Icons.edit_note_outlined,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: notesController,
            builder: (context, value, _) {
              return TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: l10n.checkoutNotesHint,
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: value.text.trim().isEmpty
                      ? null
                      : IconButton(
                          onPressed: notesController.clear,
                          tooltip: l10n.checkoutClearNotes,
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              );
            },
          ),
        ),
        if (checkoutState.hasSubmitError) ...[
          const SizedBox(height: 12),
          CheckoutNotice(
            icon: Icons.cloud_off_outlined,
            message: (checkoutState.submitError?.trim().isNotEmpty ?? false)
                ? checkoutState.submitError!.trim()
                : l10n.checkoutError,
            color: colors.error,
          ),
        ],
        const SizedBox(height: 16),
        CartQuoteSummary(
          cart: cart,
          state: quoteState,
          currency: currency,
          onRetry: () => context.read<CartQuoteCubit>().retry(),
        ),
      ],
    );
  }
}

import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_bottom_bar.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_form.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_helpers.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_items_card.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Responsive checkout layout with the cart items and the checkout form.
class CheckoutContent extends StatelessWidget {
  const CheckoutContent({
    super.key,
    required this.cart,
    required this.settings,
    required this.checkoutState,
    required this.quoteState,
    required this.currency,
    required this.total,
    required this.notesController,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.onPickAddress,
    required this.onSelectAddress,
    required this.onAddNewAddress,
    required this.onSubmit,
    required this.onRetryAddresses,
    required this.onRetryTables,
  });

  final Cart cart;
  final RestaurantSettings? settings;
  final CheckoutState checkoutState;
  final CartQuoteState quoteState;
  final StoreCurrency currency;
  final double total;
  final TextEditingController notesController;
  final String? paymentMethod;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onPickAddress;
  final ValueChanged<Address> onSelectAddress;
  final VoidCallback onAddNewAddress;
  final VoidCallback onSubmit;
  final VoidCallback onRetryAddresses;
  final VoidCallback onRetryTables;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ordering = settings?.ordering;
    final isOpen = settings?.isOpenNow ?? false;
    final availableTypes = [
      for (final type in ordering?.orderTypes ?? const <OrderOption>[])
        if (OrderDraft.supportedOrderTypes.contains(type.value)) type,
    ];
    final isSupportedType = OrderDraft.supportedOrderTypes.contains(
      cart.orderType,
    );
    final isTypeAvailable = availableTypes.any(
      (type) => type.value == cart.orderType,
    );
    final isDelivery = cart.orderType == 'delivery';
    final isDineIn = cart.orderType == 'dine_in';
    final address = checkoutState.selectedAddress;
    final addressReady =
        !isDelivery || (address?.id != null && address!.isDeliverable);
    final tableReady = !isDineIn || checkoutState.selectedTable?.id != null;
    final canSubmit =
        isOpen &&
        isSupportedType &&
        isTypeAvailable &&
        paymentMethod != null &&
        addressReady &&
        tableReady &&
        !checkoutState.isSubmitting;

    String? orderTypeLabel;
    for (final type in availableTypes) {
      if (type.value == cart.orderType) {
        orderTypeLabel = type.label.trim();
        break;
      }
    }
    String? paymentLabel;
    for (final method
        in settings?.ordering.paymentMethods ?? const <PaymentOption>[]) {
      if (method.value == paymentMethod) {
        paymentLabel = checkoutPaymentLabel(method, context);
        break;
      }
    }
    final bottomSummary = [
      if (orderTypeLabel != null && orderTypeLabel.isNotEmpty) orderTypeLabel,
      if (paymentLabel != null && paymentLabel.isNotEmpty) paymentLabel,
    ].join(' · ');

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(l10n.checkoutTitle),
        backgroundColor: context.appColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;
            final isWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CheckoutItemsCard(
                                cart: cart,
                                currency: currency,
                                onEditCart: () => _editCart(context),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 380,
                              child: CheckoutForm(
                                cart: cart,
                                settings: settings,
                                checkoutState: checkoutState,
                                quoteState: quoteState,
                                currency: currency,
                                notesController: notesController,
                                paymentMethod: paymentMethod,
                                availableTypes: availableTypes,
                                isOpen: isOpen,
                                isSupportedType: isSupportedType,
                                isTypeAvailable: isTypeAvailable,
                                isDelivery: isDelivery,
                                isDineIn: isDineIn,
                                onPaymentChanged: onPaymentChanged,
                                onPickAddress: onPickAddress,
                                onSelectAddress: onSelectAddress,
                                onAddNewAddress: onAddNewAddress,
                                onRetryAddresses: onRetryAddresses,
                                onRetryTables: onRetryTables,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CheckoutItemsCard(
                              cart: cart,
                              currency: currency,
                              onEditCart: () => _editCart(context),
                            ),
                            const SizedBox(height: 16),
                            CheckoutForm(
                              cart: cart,
                              settings: settings,
                              checkoutState: checkoutState,
                              quoteState: quoteState,
                              currency: currency,
                              notesController: notesController,
                              paymentMethod: paymentMethod,
                              availableTypes: availableTypes,
                              isOpen: isOpen,
                              isSupportedType: isSupportedType,
                              isTypeAvailable: isTypeAvailable,
                              isDelivery: isDelivery,
                              isDineIn: isDineIn,
                              onPaymentChanged: onPaymentChanged,
                              onPickAddress: onPickAddress,
                              onSelectAddress: onSelectAddress,
                              onAddNewAddress: onAddNewAddress,
                              onRetryAddresses: onRetryAddresses,
                              onRetryTables: onRetryTables,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        total: total,
        currency: currency,
        enabled: canSubmit,
        submitting: checkoutState.isSubmitting,
        onSubmit: onSubmit,
        summary: bottomSummary.isEmpty ? null : bottomSummary,
      ),
    );
  }

  void _editCart(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.cart);
    }
  }
}

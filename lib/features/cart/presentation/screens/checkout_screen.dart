import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_content.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/order_success_view.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Cart checkout: address, payment, notes and order submission.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  String? _lang;
  String? _paymentMethod;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final lang = Localizations.localeOf(context).languageCode;
    if (_lang == lang) return;
    _lang = lang;

    context.read<CheckoutCubit>().loadAddresses(lang: lang);
    context.read<CheckoutCubit>().loadTables(lang: lang);
    context.read<CartQuoteCubit>().enable(
      lang: lang,
      cart: context.read<CartCubit>().state,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final selectedId = context.read<CheckoutCubit>().state.selectedAddress?.id;
    final address = await context.push<Address>(
      AppRoutes.selectAddress,
      extra: selectedId,
    );
    if (!mounted || address == null) return;
    context.read<CheckoutCubit>().selectAddress(address);
    context.read<CheckoutCubit>().loadAddresses(lang: _lang ?? 'ar');
  }

  Future<void> _addNewAddress() async {
    final address = await context.push<Address>(AppRoutes.addAddress);
    if (!mounted) return;
    if (address != null) {
      context.read<CheckoutCubit>().selectAddress(address);
    }
    context.read<CheckoutCubit>().loadAddresses(lang: _lang ?? 'ar');
  }

  void _onAddressSelected(Address address) {
    context.read<CheckoutCubit>().selectAddress(address);
  }

  void _submit({required Cart cart, required RestaurantSettings? settings}) {
    final payment = _effectivePaymentMethod(settings);
    if (payment == null) return;

    final address = context.read<CheckoutCubit>().state.selectedAddress;
    final table = context.read<CheckoutCubit>().state.selectedTable;
    final draft = OrderDraft(
      orderType: cart.orderType,
      paymentMethod: payment,
      addressId: cart.orderType == 'delivery' ? address?.id : null,
      diningTableId: cart.orderType == 'dine_in' ? table?.id : null,
      notes: _notesController.text,
    );

    context.read<CheckoutCubit>().submit(
      cart: cart,
      draft: draft,
      lang: _lang ?? 'ar',
    );
  }

  String? _effectivePaymentMethod(RestaurantSettings? settings) {
    final methods =
        settings?.ordering.paymentMethods ?? const <PaymentOption>[];
    if (methods.any((method) => method.value == _paymentMethod)) {
      return _paymentMethod;
    }
    return methods.isEmpty ? null : methods.first.value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<StoreConfigCubit, StoreConfigState>(
      builder: (context, storeState) {
        final settings = storeState.settings;
        final currency = settings?.currency ?? const StoreCurrency();

        return BlocConsumer<CheckoutCubit, CheckoutState>(
          listenWhen: (previous, current) =>
              current.hasOrder && !previous.hasOrder,
          listener: (context, state) {
            context.read<CartCubit>().clear();
          },
          builder: (context, checkoutState) {
            final order = checkoutState.order;
            if (order != null) {
              return OrderSuccessView(
                order: order,
                currency: currency,
                onDone: () => context.go(AppRoutes.home),
              );
            }

            return BlocBuilder<CartCubit, Cart>(
              builder: (context, cart) {
                if (cart.isEmpty) {
                  return Scaffold(
                    backgroundColor: context.appColors.background,
                    appBar: AppBar(
                      title: Text(l10n.checkoutTitle),
                      backgroundColor: context.appColors.surface,
                      surfaceTintColor: Colors.transparent,
                    ),
                    body: CartEmptyState(
                      onBrowseMenu: () => context.go(AppRoutes.menu),
                    ),
                  );
                }

                return BlocBuilder<CartQuoteCubit, CartQuoteState>(
                  builder: (context, quoteState) {
                    final total = quoteState.quote?.total ?? cart.subtotal;

                    return PopScope(
                      canPop: !checkoutState.isSubmitting,
                      child: CheckoutContent(
                        cart: cart,
                        settings: settings,
                        checkoutState: checkoutState,
                        quoteState: quoteState,
                        currency: currency,
                        total: total,
                        notesController: _notesController,
                        paymentMethod: _effectivePaymentMethod(settings),
                        onPaymentChanged: (value) =>
                            setState(() => _paymentMethod = value),
                        onPickAddress: _pickAddress,
                        onSelectAddress: _onAddressSelected,
                        onAddNewAddress: _addNewAddress,
                        onSubmit: () => _submit(cart: cart, settings: settings),
                        onRetryAddresses: () => context
                            .read<CheckoutCubit>()
                            .loadAddresses(lang: _lang ?? 'ar'),
                        onRetryTables: () => context
                            .read<CheckoutCubit>()
                            .loadTables(lang: _lang ?? 'ar'),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

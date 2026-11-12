import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_line.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/cart_line_card.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/cart_quote_summary.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Cart tab: the editable cart lines plus the server quote summary.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _lang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    if (_lang == lang) return;

    _lang = lang;
    context.read<CartQuoteCubit>().enable(
      lang: lang,
      cart: context.read<CartCubit>().state,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(l10n.navCart),
        backgroundColor: context.appColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<CartCubit, Cart>(
        builder: (context, cart) {
          if (cart.isEmpty) {
            return CartEmptyState(
              onBrowseMenu: () => context.go(AppRoutes.menu),
            );
          }

          return BlocBuilder<CartQuoteCubit, CartQuoteState>(
            builder: (context, quoteState) {
              return BlocBuilder<StoreConfigCubit, StoreConfigState>(
                builder: (context, storeState) {
                  final currency =
                      storeState.settings?.currency ?? const StoreCurrency();

                  return RefreshIndicator(
                    onRefresh: () => context.read<CartQuoteCubit>().retry(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontalPadding = constraints.maxWidth >= 600
                            ? 32.0
                            : 16.0;
                        final isWide = constraints.maxWidth >= 900;

                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            32,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1080),
                              child: isWide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _CartLines(
                                            cart: cart,
                                            currency: currency,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        SizedBox(
                                          width: 340,
                                          child: CartQuoteSummary(
                                            cart: cart,
                                            state: quoteState,
                                            currency: currency,
                                            onRetry: () => context
                                                .read<CartQuoteCubit>()
                                                .retry(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _CartLines(
                                          cart: cart,
                                          currency: currency,
                                        ),
                                        const SizedBox(height: 16),
                                        CartQuoteSummary(
                                          cart: cart,
                                          state: quoteState,
                                          currency: currency,
                                          onRetry: () => context
                                              .read<CartQuoteCubit>()
                                              .retry(),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CartLines extends StatelessWidget {
  const _CartLines({required this.cart, required this.currency});

  final Cart cart;
  final StoreCurrency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final cartCubit = context.read<CartCubit>();
    final cards = <Widget>[];

    for (var index = 0; index < cart.lines.length; index++) {
      final line = cart.lines[index];
      if (index > 0) cards.add(const SizedBox(height: 10));
      cards.add(
        CartLineCard(
          key: ValueKey(_lineKey(line)),
          line: line,
          currency: currency,
          onIncrement: () => cartCubit.incrementLine(line),
          onDecrement: () => cartCubit.decrementLine(line),
          onRemove: () => cartCubit.removeLine(line),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.menuItemsCount(cart.itemsCount),
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...cards,
      ],
    );
  }

  String _lineKey(CartLine line) {
    final addons = [
      for (final addon in line.addons)
        if (addon.id != null) addon.id,
    ]..sort();

    return 'cart-line-${line.item.id}-${line.option?.id}-'
        '${line.weight}-${addons.join(',')}-${line.notes}';
  }
}

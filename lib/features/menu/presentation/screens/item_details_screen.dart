import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/item_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/item_details_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/item_details_widgets.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_item_cards.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Single dish page opened from the menu cards.
class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload the dish copy when the app language changes while it is open.
    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<ItemDetailsCubit>();
    if (cubit.state.lang != lang) cubit.load(lang: lang);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _changeQuantity(int value) {
    if (value == _quantity) return;
    setState(() => _quantity = value);
  }

  void _addToCart(BuildContext context, MenuItemDetails details) {
    if (details.item.id == null) return;

    context.read<CartCubit>().add(
      details.item,
      quantity: _quantity,
      notes: _notesController.text,
    );

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.addedToCart)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ItemDetailsCubit, ItemDetailsState>(
      builder: (context, state) {
        final details = state.details;

        if (details == null) {
          return _StatusScaffold(
            child: state.status == MenuStatus.failure
                ? MenuErrorState(
                    message: l10n.itemDetailsError,
                    onRetry: () => context.read<ItemDetailsCubit>().retry(),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.brandGreen,
                    ),
                  ),
          );
        }

        return BlocBuilder<StoreConfigCubit, StoreConfigState>(
          builder: (context, storeState) {
            final currency =
                storeState.settings?.currency ?? const StoreCurrency();

            return _DetailsScaffold(
              details: details,
              currency: currency,
              quantity: _quantity,
              notesController: _notesController,
              onQuantityChanged: _changeQuantity,
              onAddToCart: () => _addToCart(context, details),
            );
          },
        );
      },
    );
  }
}

class _DetailsScaffold extends StatelessWidget {
  const _DetailsScaffold({
    required this.details,
    required this.currency,
    required this.quantity,
    required this.notesController,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final MenuItemDetails details;
  final StoreCurrency currency;
  final int quantity;
  final TextEditingController notesController;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = details.item;
    final category = details.category;
    final size = MediaQuery.sizeOf(context);
    final imageHeight = (size.width * 0.62).clamp(220.0, 380.0);
    final horizontalPadding = size.width >= 600 ? 32.0 : 20.0;
    final total = item.price * quantity;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: imageHeight,
            backgroundColor: context.appColors.surface,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.5,
            leadingWidth: 64,
            leading: const Padding(
              padding: EdgeInsetsDirectional.only(start: 8),
              child: Center(child: ItemBackButton()),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadiusDirectional.vertical(
                  bottom: Radius.circular(24),
                ),
                child: ItemHeroImage(url: item.image),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (category != null && category.name.trim().isNotEmpty)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _CategoryChip(name: category.name),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        item.name,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: context.appColors.titleColor,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.hasDescription
                            ? item.description
                            : l10n.itemDetailsFreshlyPrepared,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _PriceLabel(currency: currency, item: item),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.itemDetailsQuantity,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: ItemQuantityStepper(
                          quantity: quantity,
                          onChanged: onQuantityChanged,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.itemDetailsSpecialInstructions,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesController,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: _notesDecoration(context, l10n),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartBar(
        label: l10n.itemDetailsAddToCartPrice(currency.format(total)),
        onPressed: onAddToCart,
      ),
    );
  }

  InputDecoration _notesDecoration(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final colors = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return InputDecoration(
      hintText: l10n.itemDetailsSpecialInstructionsHint,
      hintStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: context.appColors.brandGreen, width: 1.4),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final brand = context.appColors.brandGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: brand,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.currency, required this.item});

  final StoreCurrency currency;
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(
          currency.format(item.price),
          style: TextStyle(
            color: context.appColors.brandGreen,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (item.hasDiscount)
          Text(
            currency.format(item.compareAtPrice!),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: brand,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading/failure shell with a way back.
class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(start: 8),
          child: Center(child: ItemBackButton()),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}

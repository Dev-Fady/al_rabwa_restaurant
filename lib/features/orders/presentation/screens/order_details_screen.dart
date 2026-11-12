import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/order_details_state.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/orders_state.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/widgets/order_shared_widgets.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Full page for one order, opened from the order history.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload the order copy when the app language changes while it is open.
    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<OrderDetailsCubit>();
    if (cubit.state.lang != lang) cubit.load(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<StoreConfigCubit, StoreConfigState>(
      builder: (context, storeState) {
        final currency = storeState.settings?.currency ?? const StoreCurrency();

        return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            final order = state.order;

            return Scaffold(
              backgroundColor: context.appColors.background,
              appBar: AppBar(
                title: Text(l10n.orderDetailsTitle),
                backgroundColor: context.appColors.surface,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
              ),
              body: order == null
                  ? _DetailsStatusBody(state: state)
                  : _DetailsBody(order: order, currency: currency),
            );
          },
        );
      },
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.order, required this.currency});

  final Order order;
  final StoreCurrency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;

        return RefreshIndicator(
          onRefresh: () => context.read<OrderDetailsCubit>().load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              28,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OrderHeaderCard(order: order),
                      if (_hasCustomer) ...[
                        const SizedBox(height: 12),
                        _OrderSectionCard(
                          title: l10n.orderDetailsCustomer,
                          icon: Icons.person_outline_rounded,
                          child: _CustomerDetails(order: order),
                        ),
                      ],
                      if (_hasLocation) ...[
                        const SizedBox(height: 12),
                        _OrderSectionCard(
                          title: l10n.orderDetailsLocation,
                          icon: Icons.location_on_outlined,
                          child: _LocationDetails(order: order),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _OrderSectionCard(
                        title: l10n.orderDetailsItems,
                        icon: Icons.restaurant_menu_rounded,
                        subtitle: l10n.menuItemsCount(order.items.length),
                        child: _ItemsList(order: order, currency: currency),
                      ),
                      if (order.hasNotes) ...[
                        const SizedBox(height: 12),
                        _OrderSectionCard(
                          title: l10n.checkoutNotes,
                          icon: Icons.sticky_note_2_outlined,
                          child: Text(
                            order.notes,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                      if (_hasPayment) ...[
                        const SizedBox(height: 12),
                        _OrderSectionCard(
                          title: l10n.orderDetailsPayment,
                          icon: Icons.payments_outlined,
                          child: _PaymentDetails(order: order),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _OrderSectionCard(
                        title: l10n.orderDetailsTotals,
                        icon: Icons.receipt_long_outlined,
                        child: _TotalsDetails(order: order, currency: currency),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _hasCustomer =>
      order.customerName.isNotEmpty || order.customerPhone.isNotEmpty;

  bool get _hasLocation =>
      order.hasAddress ||
      order.hasTable ||
      order.hasCarNumber ||
      order.companyName.isNotEmpty;

  bool get _hasPayment =>
      order.payment.displayMethod.isNotEmpty ||
      order.payment.displayStatus.isNotEmpty ||
      order.couponCode.isNotEmpty;
}

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final number = order.displayNumber;
    final date = formatOrderDate(context, order.createdAt);
    final typeLabel = order.type.displayLabel;
    final meta = [if (typeLabel.isNotEmpty) typeLabel, ?date].join(' • ');

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderTypeIcon(type: order.type.value, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number == null
                          ? l10n.navOrders
                          : l10n.checkoutOrderNumber('$number'),
                      style: TextStyle(
                        color: context.appColors.titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (order.status.displayLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OrderStatusBadge(
                label: order.status.displayLabel,
                value: order.status.value,
              ),
            ),
          ],
          if (order.status.hasMessage) ...[
            const SizedBox(height: 12),
            _StatusMessage(message: order.status.message),
          ],
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final brand = context.appColors.brandGreen;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 17, color: brand),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerDetails extends StatelessWidget {
  const _CustomerDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (order.customerName.isNotEmpty)
          OrderInfoLine(
            icon: Icons.person_outline_rounded,
            text: order.customerName,
          ),
        if (order.customerPhone.isNotEmpty)
          OrderInfoLine(icon: Icons.call_outlined, text: order.customerPhone),
      ],
    );
  }
}

class _LocationDetails extends StatelessWidget {
  const _LocationDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final address = order.address;
    final addressNotes = address?.notes.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (order.hasTable)
          OrderInfoLine(
            icon: Icons.table_restaurant_outlined,
            text: '${l10n.checkoutTable}: ${order.table}',
          ),
        if (order.hasAddress)
          OrderInfoLine(
            icon: Icons.location_on_outlined,
            text: address!.summary,
          ),
        if (order.hasAddress && addressNotes.isNotEmpty)
          OrderInfoLine(icon: Icons.signpost_outlined, text: addressNotes),
        if (order.hasCarNumber)
          OrderInfoLine(
            icon: Icons.directions_car_outlined,
            text: '${l10n.orderDetailsCarNumber}: ${order.carNumber}',
          ),
        if (order.companyName.isNotEmpty)
          OrderInfoLine(
            icon: Icons.business_outlined,
            text: '${l10n.orderDetailsCompany}: ${order.companyName}',
          ),
      ],
    );
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList({required this.order, required this.currency});

  final Order order;
  final StoreCurrency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (order.items.isEmpty) {
      return Text(
        l10n.ordersEmptyItems,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < order.items.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          OrderItemRow(item: order.items[index], currency: currency),
        ],
      ],
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (order.payment.displayMethod.isNotEmpty)
          OrderInfoChip(
            icon: Icons.payments_outlined,
            label: order.payment.displayMethod,
          ),
        if (order.payment.displayStatus.isNotEmpty)
          OrderStatusBadge(
            label: order.payment.displayStatus,
            value: order.payment.statusValue,
          ),
        if (order.couponCode.isNotEmpty)
          OrderInfoChip(
            icon: Icons.local_offer_outlined,
            label: '${l10n.orderDetailsCoupon}: ${order.couponCode}',
          ),
      ],
    );
  }
}

class _TotalsDetails extends StatelessWidget {
  const _TotalsDetails({required this.order, required this.currency});

  final Order order;
  final StoreCurrency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderTotalRow(
          label: l10n.cartSubtotal,
          value: currency.format(order.subtotal),
        ),
        if (order.hasDiscount) ...[
          const SizedBox(height: 6),
          OrderTotalRow(
            label: l10n.cartDiscount,
            value: '-${currency.format(order.discount)}',
            valueColor: colors.error,
          ),
        ],
        if (order.hasTax) ...[
          const SizedBox(height: 6),
          OrderTotalRow(
            label: l10n.taxLabel,
            value: currency.format(order.tax),
          ),
        ],
        if (order.hasServiceCharge) ...[
          const SizedBox(height: 6),
          OrderTotalRow(
            label: l10n.serviceLabel,
            value: currency.format(order.serviceCharge),
          ),
        ],
        if (order.hasDeliveryFee) ...[
          const SizedBox(height: 6),
          OrderTotalRow(
            label: l10n.deliveryFeeLabel,
            value: currency.format(order.deliveryFee),
          ),
        ],
        const SizedBox(height: 8),
        OrderTotalRow(
          label: l10n.cartTotal,
          value: currency.format(order.total),
          isTotal: true,
        ),
      ],
    );
  }
}

class _OrderSectionCard extends StatelessWidget {
  const _OrderSectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;
    final hasSubtitle = subtitle?.trim().isNotEmpty ?? false;

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailsStatusBody extends StatelessWidget {
  const _DetailsStatusBody({required this.state});

  final OrderDetailsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    if (state.hasError) {
      final raw = state.errorMessage?.trim() ?? '';
      final message = raw.isEmpty ? l10n.orderDetailsError : raw;

      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 50, color: colors.error),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => context.read<OrderDetailsCubit>().retry(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: state.status == OrdersStatus.initial || state.isLoading
          ? CircularProgressIndicator(color: context.appColors.brandGreen)
          : const SizedBox.shrink(),
    );
  }
}

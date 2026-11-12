import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_text_button.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_details_state.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/widgets/delete_address_dialog.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/item_details_widgets.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Shows one saved address and opens the add form in edit mode.
class AddressDetailsScreen extends StatelessWidget {
  const AddressDetailsScreen({super.key});

  Future<void> _editAddress(BuildContext context, Address address) async {
    final updated = await context.push<Address>(
      AppRoutes.addAddress,
      extra: address,
    );
    if (!context.mounted || updated == null) return;

    context.read<AddressDetailsCubit>().applyAddress(updated);
  }

  Future<void> _deleteAddress(BuildContext context, Address address) async {
    final confirmed = await showDeleteAddressDialog(
      context,
      addressName: address.displayName,
    );
    if (!context.mounted || !confirmed) return;

    await context.read<AddressDetailsCubit>().deleteAddress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AddressDetailsCubit, AddressDetailsState>(
      listenWhen: (previous, current) =>
          previous.isDeleted != current.isDeleted ||
          (current.deleteError != null &&
              previous.deleteError != current.deleteError),
      listener: (context, state) {
        if (state.isDeleted) {
          context.pop();
          return;
        }

        final deleteError = state.deleteError;
        if (deleteError == null) return;

        final raw = deleteError.trim();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(raw.isEmpty ? l10n.addressDeleteError : raw),
            ),
          );
      },
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          backgroundColor: context.appColors.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leadingWidth: 64,
          leading: const Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: Center(child: ItemBackButton()),
          ),
          title: Text(
            l10n.addressDetailsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.appColors.brandGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 600
                  ? 32.0
                  : 16.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: BlocBuilder<AddressDetailsCubit, AddressDetailsState>(
                    builder: (context, state) {
                      final address = state.address;
                      if (address == null && state.isLoading) {
                        return const _DetailsLoading();
                      }

                      if (address == null) {
                        return _DetailsError(
                          message: _errorMessage(l10n, state),
                          retryLabel: l10n.retry,
                          onRetry: () =>
                              context.read<AddressDetailsCubit>().load(),
                        );
                      }

                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          28,
                        ),
                        children: [
                          _AddressHeader(address: address),
                          const SizedBox(height: 16),
                          _AddressDetailsCard(address: address),
                          const SizedBox(height: 22),
                          AppTextButton(
                            buttonText: l10n.addressEditTitle,
                            onPressed: () => _editAddress(context, address),
                            backgroundColor: context.appColors.brandGreen,
                            borderRadius: 16,
                            buttonHeight: 54,
                            textStyle: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DeleteAddressButton(
                            label: l10n.addressDelete,
                            isLoading: state.isDeleting,
                            onPressed: state.isDeleting
                                ? null
                                : () => _deleteAddress(context, address),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, AddressDetailsState state) {
    final raw = state.errorMessage?.trim() ?? '';
    return raw.isEmpty ? l10n.addressDetailsError : raw;
  }
}

class _AddressHeader extends StatelessWidget {
  const _AddressHeader({required this.address});

  final Address address;

  IconData get _kindIcon => switch (address.kind) {
    AddressKind.home => Icons.home_rounded,
    AddressKind.work => Icons.work_rounded,
    AddressKind.other => Icons.place_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.appColors.brandGreen;
    final l10n = AppLocalizations.of(context)!;
    final summary = address.summary.trim();
    final showSummary = summary.isNotEmpty && summary != address.displayName;
    final kindLabel = address.kindLabel.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_kindIcon, size: 23, color: brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.appColors.titleColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (showSummary) ...[
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                if (kindLabel.isNotEmpty || !address.isDeliverable) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (kindLabel.isNotEmpty)
                        _Tag(label: kindLabel, color: brand),
                      if (!address.isDeliverable)
                        _Tag(
                          label: l10n.addressOutsideArea,
                          color: colors.error,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AddressDetailsCard extends StatelessWidget {
  const _AddressDetailsCard({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final point = address.point;

    final rows = <Widget>[
      if (address.area.trim().isNotEmpty)
        _DetailRow(label: l10n.addressAreaField, value: address.area.trim()),
      if (address.street.trim().isNotEmpty)
        _DetailRow(
          label: l10n.addressStreetField,
          value: address.street.trim(),
        ),
      if (address.building.trim().isNotEmpty)
        _DetailRow(
          label: l10n.addressBuildingField,
          value: address.building.trim(),
        ),
      if (address.notes.trim().isNotEmpty)
        _DetailRow(label: l10n.addressNotesField, value: address.notes.trim()),
      if (point != null)
        _DetailRow(
          label: l10n.addressCoordinates,
          value:
              '${point.latitude.toStringAsFixed(5)}, '
              '${point.longitude.toStringAsFixed(5)}',
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addressDetailsInfo,
            style: theme.textTheme.titleSmall?.copyWith(
              color: context.appColors.titleColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) const Divider(height: 18),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _DeleteAddressButton extends StatelessWidget {
  const _DeleteAddressButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: colors.error,
              ),
            )
          : const Icon(Icons.delete_outline_rounded, size: 21),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        minimumSize: const Size.fromHeight(54),
        side: BorderSide(
          color: colors.error.withValues(alpha: 0.5),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.appColors.brandGreen),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 46, color: colors.error),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(retryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// One saved address in the delivery location picker.
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
    this.isDefault = false,
    this.isSettingDefault = false,
    this.isDeleting = false,
    this.onDetails,
    this.onEdit,
    this.onSetDefault,
    this.onDelete,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;

  /// Whether the backend currently treats this address as the default.
  final bool isDefault;

  /// Whether a "set as default" request is running for this address.
  final bool isSettingDefault;

  /// Whether a delete request is running for this address.
  final bool isDeleting;

  /// Opens the read-only details screen for this address.
  final VoidCallback? onDetails;

  /// Opens the add-address form prefilled with this address.
  final VoidCallback? onEdit;

  /// Marks this address as the customer's default.
  final VoidCallback? onSetDefault;

  /// Deletes this address after the caller confirms.
  final VoidCallback? onDelete;

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

    return Semantics(
      button: true,
      selected: selected,
      label: address.displayName,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? brand
                    : colors.outlineVariant.withValues(alpha: 0.8),
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KindIcon(icon: _kindIcon, selected: selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: context.appColors.titleColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 17,
                              color: brand,
                            ),
                          ],
                        ],
                      ),
                      if (showSummary) ...[
                        const SizedBox(height: 4),
                        Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (!address.isDeliverable) ...[
                        const SizedBox(height: 8),
                        _NotDeliverableBadge(label: l10n.addressOutsideArea),
                      ],
                      if (isDefault) ...[
                        const SizedBox(height: 8),
                        _DefaultBadge(label: l10n.addressDefault),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isSettingDefault || isDeleting)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(top: 9, bottom: 9),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  )
                else if (onDetails != null ||
                    onEdit != null ||
                    onSetDefault != null ||
                    onDelete != null)
                  _AddressMenu(
                    onDetails: onDetails,
                    onEdit: onEdit,
                    onSetDefault: onSetDefault,
                    onDelete: onDelete,
                    canSetDefault: !isDefault,
                  ),
                const SizedBox(width: 4),
                _DefaultCheckbox(isDefault: isDefault, onChanged: onSetDefault),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? brand.withValues(alpha: 0.12)
            : colors.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 21,
        color: selected ? brand : colors.onSurfaceVariant,
      ),
    );
  }
}

class _DefaultCheckbox extends StatelessWidget {
  const _DefaultCheckbox({required this.isDefault, required this.onChanged});

  final bool isDefault;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = context.appColors.brandGreen;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: isDefault ? l10n.addressDefault : l10n.addressSetDefault,
      child: Checkbox(
        value: isDefault,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
        activeColor: brand,
        checkColor: colors.onPrimary,
        side: BorderSide(color: colors.outline, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _NotDeliverableBadge extends StatelessWidget {
  const _NotDeliverableBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final brand = context.appColors.brandGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: brand),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: brand,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum _AddressAction { details, edit, setDefault, delete }

class _AddressMenu extends StatelessWidget {
  const _AddressMenu({
    this.onDetails,
    this.onEdit,
    this.onSetDefault,
    this.onDelete,
    this.canSetDefault = false,
  });

  final VoidCallback? onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;
  final bool canSetDefault;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<_AddressAction>(
      tooltip: l10n.addressOptions,
      icon: Icon(Icons.more_horiz_rounded, color: colors.onSurfaceVariant),
      iconSize: 22,
      onSelected: (action) {
        switch (action) {
          case _AddressAction.details:
            onDetails?.call();
          case _AddressAction.edit:
            onEdit?.call();
          case _AddressAction.setDefault:
            onSetDefault?.call();
          case _AddressAction.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        if (onDetails != null)
          PopupMenuItem(
            value: _AddressAction.details,
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20),
                const SizedBox(width: 10),
                Flexible(child: Text(l10n.addressViewDetails)),
              ],
            ),
          ),
        if (onEdit != null)
          PopupMenuItem(
            value: _AddressAction.edit,
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, size: 20),
                const SizedBox(width: 10),
                Flexible(child: Text(l10n.addressEditTitle)),
              ],
            ),
          ),
        if (onSetDefault != null && canSetDefault)
          PopupMenuItem(
            value: _AddressAction.setDefault,
            child: Row(
              children: [
                const Icon(Icons.star_outline_rounded, size: 20),
                const SizedBox(width: 10),
                Flexible(child: Text(l10n.addressSetDefault)),
              ],
            ),
          ),
        if (onDelete != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: _AddressAction.delete,
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: colors.error,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.addressDelete,
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

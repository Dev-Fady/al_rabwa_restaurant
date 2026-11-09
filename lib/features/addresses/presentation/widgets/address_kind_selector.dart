import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Home / Work / Other segmented control shown above the address fields.
class AddressKindSelector extends StatelessWidget {
  const AddressKindSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final AddressKind selected;
  final ValueChanged<AddressKind> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: 4,
        children: [
          for (final kind in AddressKind.values)
            Expanded(
              child: _KindOption(
                kind: kind,
                isSelected: kind == selected,
                enabled: enabled,
                onTap: () => onChanged(kind),
              ),
            ),
        ],
      ),
    );
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption({
    required this.kind,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final AddressKind kind;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  IconData get _icon => switch (kind) {
    AddressKind.home => Icons.home_rounded,
    AddressKind.work => Icons.work_rounded,
    AddressKind.other => Icons.place_rounded,
  };

  String _label(AppLocalizations l10n) => switch (kind) {
    AddressKind.home => l10n.addressKindHome,
    AddressKind.work => l10n.addressKindWork,
    AddressKind.other => l10n.addressKindOther,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.appColors.brandGreen;
    final label = _label(AppLocalizations.of(context)!);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: enabled && !isSelected ? onTap : null,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                size: 18,
                color: isSelected ? brand : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? brand : colors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

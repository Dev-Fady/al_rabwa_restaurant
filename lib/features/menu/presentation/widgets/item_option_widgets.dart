import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Weight values without trailing zeros: `0.25`, `0.5`, `10`.
String formatWeightAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;
}

/// Portion choices of a dish; exactly one can be selected.
class ItemOptionsSection extends StatelessWidget {
  const ItemOptionsSection({
    super.key,
    required this.options,
    required this.currency,
    required this.selectedId,
    required this.onChanged,
  });

  final List<MenuItemOption> options;
  final StoreCurrency currency;
  final int? selectedId;
  final ValueChanged<MenuItemOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: l10n.itemDetailsChooseOne),
        const SizedBox(height: 10),
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _ChoiceTile(
            selected: options[index].id == selectedId,
            leading: Icon(
              options[index].id == selectedId
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 22,
            ),
            label: options[index].name,
            priceLabel: options[index].hasPrice
                ? '+ ${currency.format(options[index].price)}'
                : null,
            onTap: () => onChanged(options[index]),
          ),
        ],
      ],
    );
  }
}

/// Extras of a dish; any number of them can be selected.
class ItemAddonsSection extends StatelessWidget {
  const ItemAddonsSection({
    super.key,
    required this.addons,
    required this.currency,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<MenuItemAddon> addons;
  final StoreCurrency currency;
  final Set<int> selectedIds;
  final ValueChanged<MenuItemAddon> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: l10n.itemDetailsAddons),
        const SizedBox(height: 10),
        for (var index = 0; index < addons.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _ChoiceTile(
            selected: selectedIds.contains(addons[index].id),
            leading: Icon(
              selectedIds.contains(addons[index].id)
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 22,
            ),
            label: addons[index].name,
            priceLabel: addons[index].hasPrice
                ? '+ ${currency.format(addons[index].price)}'
                : null,
            onTap: () => onToggle(addons[index]),
          ),
        ],
      ],
    );
  }
}

/// Selectable weight of dishes sold by the kilo.
class ItemWeightSection extends StatelessWidget {
  const ItemWeightSection({
    super.key,
    required this.range,
    required this.selected,
    required this.onChanged,
  });

  final MenuItemWeight range;
  final double selected;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final choices = range.choices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 2,
          children: [
            _SectionTitle(title: l10n.itemDetailsWeight),
            Text(
              l10n.itemDetailsWeightHint(
                formatWeightAmount(range.min),
                formatWeightAmount(range.max),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: choices.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final value = choices[index];
              return _WeightChip(
                label: formatWeightAmount(value),
                selected: (value - selected).abs() < 0.0001,
                onTap: () => onChanged(value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.leading,
    required this.label,
    required this.onTap,
    this.priceLabel,
  });

  final bool selected;
  final Widget leading;
  final String label;
  final String? priceLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Material(
      color: selected ? brand.withValues(alpha: 0.07) : colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? brand
                  : colors.outlineVariant.withValues(alpha: 0.9),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  color: selected ? brand : colors.onSurfaceVariant,
                ),
                child: leading,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (priceLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  priceLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightChip extends StatelessWidget {
  const _WeightChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Material(
      color: selected ? brand : colors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 56),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? brand
                  : colors.outlineVariant.withValues(alpha: 0.9),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontSize: 13.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

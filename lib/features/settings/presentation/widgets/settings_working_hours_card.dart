import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Soft accent card with the restaurant's working hours and open/closed state.
///
/// [OrderingSettings.workingHours] is kept as the raw API map, so the card
/// reads the `from`/`to` keys defensively and simply hides the range when the
/// backend does not provide a usable one.
class SettingsWorkingHoursCard extends StatelessWidget {
  const SettingsWorkingHoursCard({super.key, required this.ordering});

  final OrderingSettings ordering;

  static const String _rangeSeparator = '·';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final primary = context.appColors.brandGreen;
    final accent = context.appColors.accent;

    final from = _readHour(ordering.workingHours['from']);
    final to = _readHour(ordering.workingHours['to']);
    final range = from.isNotEmpty && to.isNotEmpty ? '$from – $to' : null;

    final isOpen = ordering.enabled && ordering.acceptingOrdersNow;
    final closedMessage = ordering.closedMessage.trim();
    final status = isOpen
        ? l10n.storeOpenShort
        : (closedMessage.isNotEmpty ? closedMessage : l10n.storeClosed);

    // Blend with the surface so the card keeps its soft tint in dark mode too.
    final surface = theme.colorScheme.surface;
    final softStart = Color.alphaBlend(accent.withValues(alpha: 0.16), surface);
    final softEnd = Color.alphaBlend(accent.withValues(alpha: 0.06), surface);

    final detailStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [softStart, softEnd],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 19,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.workingHoursLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _HoursLine(
            range: range,
            status: status,
            style: detailStyle,
            separator: _rangeSeparator,
          ),
        ],
      ),
    );
  }

  /// Normalizes a raw working-hours value into a trimmed display string.
  static String _readHour(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}

/// Lays the range out left-to-right so `from – to` never flips in Arabic.
///
/// The line is flush with the card's end edge (right in Arabic), like the
/// storefront, while the localized status keeps the reader's text direction.
class _HoursLine extends StatelessWidget {
  const _HoursLine({
    required this.range,
    required this.status,
    required this.style,
    required this.separator,
  });

  final String? range;
  final String status;
  final TextStyle? style;
  final String separator;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final isRtl = direction == TextDirection.rtl;
    final range = this.range;

    if (range == null) {
      return Text(status, style: style);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        alignment: isRtl ? WrapAlignment.end : WrapAlignment.start,
        spacing: 6,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(range, style: style),
          Text(separator, style: style),
          Directionality(
            textDirection: direction,
            child: Text(status, style: style),
          ),
        ],
      ),
    );
  }
}

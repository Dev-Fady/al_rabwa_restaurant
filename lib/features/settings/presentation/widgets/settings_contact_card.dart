import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Restaurant contact card on the store tab.
///
/// Every value comes from `contact` in `GET /api/settings`. The card stays
/// visible when the backend has no contact data yet and swaps the rows for a
/// friendly empty state, so the section never collapses silently.
class SettingsContactCard extends StatelessWidget {
  const SettingsContactCard({super.key, required this.contact});

  final StoreContact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final entries = _entries(contact, l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          scheme.onSurface.withValues(alpha: 0.03),
          scheme.surface,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactTitle(title: l10n.contactTitle),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            _ContactEmptyState(
              message: l10n.contactEmpty,
              hint: l10n.contactEmptyHint,
            )
          else
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.45),
                ),
              _ContactRow(entry: entries[i], onTap: entries[i].open),
            ],
        ],
      ),
    );
  }

  /// Builds one row per contact value the backend actually provides.
  static List<_ContactEntry> _entries(
    StoreContact contact,
    AppLocalizations l10n,
  ) {
    final phone = contact.phone.trim();
    final whatsapp = contact.whatsapp.trim();
    final instagram = contact.instagram.trim();
    final facebook = contact.facebook.trim();
    final location = contact.location.trim();

    return [
      if (phone.isNotEmpty)
        _ContactEntry(
          icon: Icons.call_outlined,
          label: l10n.phoneLabel,
          value: phone,
          uri: _phoneUri(phone),
          keepLtr: true,
        ),
      if (whatsapp.isNotEmpty)
        _ContactEntry(
          icon: Icons.chat_bubble_outline_rounded,
          label: l10n.whatsappLabel,
          value: whatsapp,
          uri: _whatsAppUri(whatsapp),
          keepLtr: true,
        ),
      if (instagram.isNotEmpty)
        _ContactEntry(
          icon: Icons.camera_alt_outlined,
          label: l10n.instagramLabel,
          value: instagram,
          uri: _socialUri(instagram, 'instagram.com'),
          keepLtr: true,
        ),
      if (facebook.isNotEmpty)
        _ContactEntry(
          icon: Icons.facebook_rounded,
          label: l10n.facebookLabel,
          value: facebook,
          uri: _socialUri(facebook, 'facebook.com'),
          keepLtr: true,
        ),
      if (location.isNotEmpty)
        _ContactEntry(
          icon: Icons.place_outlined,
          label: l10n.locationLabel,
          value: location,
          uri: _mapsUri(location),
        ),
    ];
  }

  static Uri? _phoneUri(String value) {
    final number = value.replaceAll(RegExp(r'[^0-9+]'), '');
    return number.isEmpty ? null : Uri(scheme: 'tel', path: number);
  }

  static Uri? _whatsAppUri(String value) {
    final external = _externalUri(value);
    if (external != null) return external;
    final number = value.replaceAll(RegExp(r'[^0-9]'), '');
    return number.isEmpty ? null : Uri.https('wa.me', '/$number');
  }

  static Uri? _socialUri(String value, String host) {
    final external = _externalUri(value);
    if (external != null) return external;
    var handle = value.replaceAll(RegExp(r'^@+'), '');
    handle = handle.replaceAll(RegExp(r'/+$'), '');
    return handle.isEmpty ? null : Uri.https(host, '/$handle');
  }

  static Uri? _mapsUri(String value) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': value,
    });
  }

  /// Accepts a backend value that is already a full link.
  static Uri? _externalUri(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.scheme.startsWith('http')) {
      return uri;
    }
    return null;
  }
}

class _ContactTitle extends StatelessWidget {
  const _ContactTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = context.appColors.brandGreen;
    final accent = context.appColors.accent;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(Icons.support_agent_rounded, size: 19, color: primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.entry, required this.onTap});

  final _ContactEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = context.appColors.brandGreen;
    final canOpen = onTap != null;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(entry.icon, size: 18, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: entry.keepLtr
                      ? TextDirection.ltr
                      : Directionality.of(context),
                  child: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (canOpen) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new_rounded,
              size: 15,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ],
      ),
    );

    if (!canOpen) return content;

    return Semantics(
      button: true,
      label: '${entry.label}: ${entry.value}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          overlayColor: WidgetStatePropertyAll(
            scheme.onSurface.withValues(alpha: 0.05),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _ContactEmptyState extends StatelessWidget {
  const _ContactEmptyState({required this.message, required this.hint});

  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = context.appColors.brandGreen;
    final accent = context.appColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_unread_chat_alt_outlined,
              size: 23,
              color: primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactEntry {
  const _ContactEntry({
    required this.icon,
    required this.label,
    required this.value,
    this.uri,
    this.keepLtr = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Uri? uri;

  /// Phone numbers must keep their digit order inside an RTL paragraph.
  final bool keepLtr;

  VoidCallback? get open {
    final uri = this.uri;
    if (uri == null) return null;
    return () => _launch(uri);
  }
}

Future<void> _launch(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Ignore launcher failures: the storefront stays usable.
  }
}

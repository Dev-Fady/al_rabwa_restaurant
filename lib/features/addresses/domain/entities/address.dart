import 'geo_point.dart';

/// The three kinds the backend accepts for `POST /addresses`.
enum AddressKind {
  home('home'),
  work('work'),
  other('other');

  const AddressKind(this.apiValue);

  /// Value sent to the API (`kind` field).
  final String apiValue;

  /// Unknown/absent values fall back to [AddressKind.other].
  static AddressKind fromApi(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final kind in AddressKind.values) {
      if (kind.apiValue == normalized) return kind;
    }
    return AddressKind.other;
  }
}

/// A saved delivery address returned by the backend.
class Address {
  const Address({
    required this.id,
    required this.kind,
    required this.kindLabel,
    required this.label,
    required this.title,
    required this.summary,
    required this.deliveryZone,
    required this.isDeliverable,
    required this.area,
    required this.street,
    required this.building,
    required this.notes,
    required this.point,
    required this.lastUsedAt,
    this.isDefault = false,
  });

  final int? id;
  final AddressKind kind;

  /// Localized kind name supplied by the backend (e.g. "المنزل").
  final String kindLabel;

  /// Customer-given name; falls back to [title] on the server.
  final String label;

  /// Display name chosen by the backend (`label` or the kind label).
  final String title;

  /// One-line address assembled by the backend from its parts.
  final String summary;

  /// Delivery zone the point falls in, when the backend matched one.
  final String? deliveryZone;

  /// Whether the restaurant currently delivers to [point].
  final bool isDeliverable;

  final String area;
  final String street;
  final String building;
  final String notes;
  final GeoPoint? point;
  final DateTime? lastUsedAt;

  /// Whether the backend marked this address as the customer's default.
  final bool isDefault;

  /// Name to show in a location bar: the customer's label, the backend title,
  /// then the assembled summary.
  String get displayName {
    if (label.trim().isNotEmpty) return label.trim();
    if (title.trim().isNotEmpty) return title.trim();
    return summary.trim();
  }
}

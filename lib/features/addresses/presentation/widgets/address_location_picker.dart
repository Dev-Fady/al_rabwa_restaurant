import 'package:al_rabwa_restaurant/core/constants/map_constants.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap picker with a pin fixed at the map centre.
///
/// The coordinate is whatever sits under the pin, so the customer drags the
/// map instead of a marker (no "snap back" jumps, works the same on every
/// platform). Because all orders are inside Qatar the camera is constrained to
/// the country and opens on Doha, so the customer normally starts at the right
/// zoom on the right city.
class AddressLocationPicker extends StatefulWidget {
  const AddressLocationPicker({
    super.key,
    required this.point,
    required this.focusPoint,
    required this.focusRequest,
    required this.isLocating,
    required this.onLocate,
  });

  /// Receives every camera move; the form reads it when saving.
  final ValueNotifier<GeoPoint> point;

  /// Device location to jump to, applied when [focusRequest] changes.
  final GeoPoint? focusPoint;
  final int focusRequest;

  final bool isLocating;
  final VoidCallback onLocate;

  /// City-level zoom: the whole of Doha is visible, so the customer only
  /// needs a short drag instead of searching from a world view.
  static const double initialZoom = 12.5;

  /// Street-level zoom after "use my location".
  static const double focusZoom = 16;

  @override
  State<AddressLocationPicker> createState() => _AddressLocationPickerState();
}

class _AddressLocationPickerState extends State<AddressLocationPicker> {
  final MapController _mapController = MapController();

  static final LatLngBounds _qatarBounds = LatLngBounds(
    const LatLng(GeoPoint.minLatitude, GeoPoint.minLongitude),
    const LatLng(GeoPoint.maxLatitude, GeoPoint.maxLongitude),
  );

  @override
  void didUpdateWidget(covariant AddressLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusRequest != oldWidget.focusRequest) {
      _moveTo(widget.focusPoint);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _moveTo(GeoPoint? point) {
    if (point == null) return;

    try {
      _mapController.move(
        LatLng(point.latitude, point.longitude),
        AddressLocationPicker.focusZoom,
      );
    } catch (_) {
      // The map is not attached yet (or already disposed); it opens on the
      // initial centre anyway.
    }
  }

  void _handlePositionChanged(MapCamera camera, bool hasGesture) {
    final point = GeoPoint(
      latitude: camera.center.latitude,
      longitude: camera.center.longitude,
    );
    if (point != widget.point.value) {
      widget.point.value = point;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                widget.point.value.latitude,
                widget.point.value.longitude,
              ),
              initialZoom: AddressLocationPicker.initialZoom,
              minZoom: 10,
              maxZoom: 18,
              // Only Qatar is deliverable; the centre (the pin) can never
              // leave the country no matter how far the customer drags.
              cameraConstraint: CameraConstraint.containCenter(
                bounds: _qatarBounds,
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPositionChanged: _handlePositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: MapConstants.tileUrlTemplate,
                userAgentPackageName: MapConstants.tileUserAgentPackageName,
                maxNativeZoom: 19,
              ),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                showFlutterMapAttribution: false,
                permanentHeight: 18,
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    textStyle: TextStyle(
                      fontSize: 9,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: brand,
                  shadows: const [
                    Shadow(
                      color: Color(0x40000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 10,
            start: 10,
            child: _LocateButton(
              label: l10n.addressUseCurrentLocation,
              isLocating: widget.isLocating,
              onTap: widget.onLocate,
            ),
          ),
          PositionedDirectional(
            start: 12,
            end: 12,
            bottom: 30,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC1D1D1D),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.addressMapHint,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton({
    required this.label,
    required this.isLocating,
    required this.onTap,
  });

  final String label;
  final bool isLocating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: isLocating ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 14, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLocating)
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  else
                    Icon(
                      Icons.my_location_rounded,
                      size: 16,
                      color: context.appColors.brandGreen,
                    ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'map_placeholder.dart';

/// Live Google map of a delivery destination (store or customer) with the
/// Driver's own position as the blue my-location dot. Turn-by-turn stays in
/// the external Google Maps app ("Open in Google Maps").
///
/// Falls back to [MapPlaceholder] when the order has no coordinates.
class DestinationMap extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  /// Shown on the marker's info window.
  final String markerTitle;

  /// Optional caption in the map's top corner.
  final String? label;
  final double height;

  const DestinationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.markerTitle,
    this.label,
    this.height = 220,
  });

  // Inside a scroll view the map would otherwise lose its pan/zoom drags to
  // the page scroll.
  static final Set<Factory<OneSequenceGestureRecognizer>> _mapGestures =
      <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      };

  @override
  Widget build(BuildContext context) {
    final double? lat = latitude;
    final double? lng = longitude;
    if (lat == null || lng == null) {
      return MapPlaceholder(label: label, height: height);
    }

    final AppColors c = context.colors;
    final LatLng destination = LatLng(lat, lng);
    final String? caption = label;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl.r),
      child: SizedBox(
        height: height.h,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: destination,
                zoom: 15,
              ),
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  infoWindow: InfoWindow(title: markerTitle),
                ),
              },
              // Shows nothing (no crash) until location permission is granted.
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              gestureRecognizers: _mapGestures,
            ),
            if (caption != null)
              PositionedDirectional(
                top: AppSpacing.sm.h,
                start: AppSpacing.sm.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: AppSpacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    caption,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

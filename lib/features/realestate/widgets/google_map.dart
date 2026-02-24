import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class PropertyGoogleMap extends StatelessWidget {
  final dynamic property;
  final LatLng? userLatLng;
  final Set<Polyline> polylines;

  const PropertyGoogleMap({
    super.key,
    required this.property,
    required this.userLatLng,
    required this.polylines, required CameraPosition initialCameraPosition,
  });

  @override
  Widget build(BuildContext context) {
    if (property.lat == null || property.lng == null) {
      return const SizedBox();
    }

    final propertyLatLng = LatLng(property.lat!, property.lng!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: propertyLatLng,
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('property'),
              position: propertyLatLng,
            ),
            if (userLatLng != null)
              Marker(
                markerId: const MarkerId('user'),
                position: userLatLng!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
          },
          polylines: polylines,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }
}


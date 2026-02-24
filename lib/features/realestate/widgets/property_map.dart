import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PropertyMap extends StatelessWidget {
  final double lat;
  final double lng;

  const PropertyMap({
    super.key,
    required this.lat,
    required this.lng,
  });
// Removed mutable field 'selectedPropertyId' to ensure immutability.

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
  children: [
    FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.marketworld.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 46,
              height: 46,
              child: const Icon(
                Icons.location_on,
                size: 46,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),

    // 🔍 Zoom buttons
    Positioned(
      right: 12,
      bottom: 12,
      child: Column(
        children: [
          _zoomButton(Icons.add),
          const SizedBox(height: 6),
          _zoomButton(Icons.remove),
        ],
      ),
    ),
  ],
        ),
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: () {},
      backgroundColor: Colors.white,
      child: Icon(icon, color: Colors.black),
    );
  }
}

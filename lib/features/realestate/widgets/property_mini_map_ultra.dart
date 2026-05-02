import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_world/features/realestate/pages/property_full_map_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyMiniMapUltra extends StatelessWidget {

  const PropertyMiniMapUltra({
    required this.lat, required this.lng, required this.title, super.key,
  });
  final double lat;
  final double lng;
  final String title;

  Future<void> _openGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ignore: unused_element
  Future<void> _startNavigation() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(lat, lng);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('property'),
                    position: position,
                    infoWindow: InfoWindow(title: title),
                  ),
                },
             
                liteModeEnabled: true, // 🔥 مهم للأداء
              ),
            ),

            // 🔥 Gradient Overlay
            // Container(
            //   height: 250,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Colors.black.withOpacity(0.4),
            //         Colors.transparent,
            //       ],
            //       begin: Alignment.bottomCenter,
            //       end: Alignment.topCenter,
            //     ),
            //   ),
            // ),

            // 📍 Buttons
            Positioned(
              bottom: 12,
              left: 12,
              child: Column(
                children: [
                  Tooltip(
                    message: 'Open in Google Maps',
                    child: _buildIconButton(
                      icon: Icons.location_on,
                      onTap: _openGoogleMaps,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: 'Get Directions',
                    child: _buildIconButton(
                      icon: Icons.navigation,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyFullMapPage(
                              lat: lat,
                              lng: lng,
                              title: title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.blue),
      ),
    );
  }
}

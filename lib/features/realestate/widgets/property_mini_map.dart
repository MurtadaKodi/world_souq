// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PropertyMiniMap extends StatelessWidget {
//   final dynamic property;
//   final LatLng? userLatLng;
//   final VoidCallback onOpenFullMap;

//   const PropertyMiniMap({
//     super.key,
//     required this.property,
//     required this.userLatLng,
//     required this.onOpenFullMap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (property.lat == null || property.lng == null) {
//       return const SizedBox();
//     }

//     final propertyLatLng = LatLng(property.lat!, property.lng!);

//     return GestureDetector(
//       onTap: () {
//   _openGoogleMaps(property.lat!, property.lng!);
// },
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           children: [
//             SizedBox(
//               height: 180,
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: propertyLatLng,
//                   zoom: 14,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId('property'),
//                     position: propertyLatLng,
//                   ),
//                   if (userLatLng != null)
//                     Marker(
//                       markerId: const MarkerId('user'),
//                       position: userLatLng!,
//                       icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueAzure,
//                       ),
//                     ),
//                 },
//                 zoomControlsEnabled: false,
//                 myLocationButtonEnabled: false,
//                 rotateGesturesEnabled: false,
//                 scrollGesturesEnabled: false,
//                 zoomGesturesEnabled: false,
//                 tiltGesturesEnabled: false,
//               ),
//             ),

//             Positioned(
//               right: 12,
//               bottom: 12,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   'عرض الخريطة',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//  Future<void> _openGoogleMaps(double lat, double lng) async {
//   final url = Uri.parse(
//     'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
//   );

//   if (await canLaunchUrl(url)) {
//     await launchUrl(url, mode: LaunchMode.externalApplication);
//   } else {
//     throw 'Could not open Google Maps';
//   }
// }
// }
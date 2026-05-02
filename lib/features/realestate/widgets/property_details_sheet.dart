// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../models/property_model.dart';

// class PropertyDetailsSheet extends StatelessWidget {
//   final PropertyModel property;
//   final VoidCallback onBook;

//   const PropertyDetailsSheet({
//     super.key,
//     required this.property,
//     required this.onBook,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width > 800;

//     return Stack(
//   children: [
//     Container(
//       padding: const EdgeInsets.all(16),
//       child: isWide
//           ? Row(
//               children: [
//                 Expanded(child: _buildImage()),
//                 const SizedBox(width: 20),
//                 Expanded(child: _buildDetails(context)),
//               ],
//             )
//           : Column(
//   children: [
//     _buildImage(),
//     const SizedBox(height: 10),
//     _buildMiniMap(),
//     const SizedBox(height: 10),
//     Flexible(child: _buildDetails(context)),
//   ],
// )
//     ),

//     // ❌ زر الإغلاق
//     Positioned(
//       top: 10,
//       right: 10,
//       child: CircleAvatar(
//         backgroundColor: Colors.black.withOpacity(0.6),
//         child: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//     ),
//   ],
// );
//   }

//   // ================= MINI MAP =================

//   Widget _buildMiniMap() {
//   if (property.lat == null || property.lng == null) {
//     return const SizedBox();
//   }

//   return SizedBox(
//     height: 120,
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(property.lat!, property.lng!),
//           zoom: 14,
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId(property.id),
//             position: LatLng(property.lat!, property.lng!),
//           ),
//         },
//         zoomControlsEnabled: false,
//         scrollGesturesEnabled: false,
//         zoomGesturesEnabled: false,
//         rotateGesturesEnabled: false,
//         tiltGesturesEnabled: false,
//         myLocationButtonEnabled: false,
//       ),
//     ),
//   );
// }

//   // ================= IMAGE =================

//   Widget _buildImage() {
//     final images = property.mediaPaths;

//     return SizedBox(
//       height: 180,
//       child: PageView.builder(
//         itemCount: images.isEmpty ? 1 : images.length,
//         itemBuilder: (_, i) {
//           final img = images.isNotEmpty
//               ? images[i]
//               : property.mainImage;

//           return ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: img != null
//                 ? Image.network(
//                     img,
//                     fit: BoxFit.cover,
//                   )
//                 : Container(color: Colors.grey.shade300),
//           );
//         },
//       ),
//     );
//   }

//   // ================= DETAILS =================

//   Widget _buildDetails(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Title + Price
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 property.title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Text(
//               '${property.price.toInt()} ${property.currency}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 8),

//         // Location
//         Text(
//           '${property.city} • ${property.area}',
//           style: TextStyle(color: Colors.grey.shade600),
//         ),

//         const SizedBox(height: 12),

//         // Grid Info
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             _chip(property.type),
//             _chip(property.purpose),
//             _chip(property.address ?? 'N/A'),
//           ],
//         ),

//         const SizedBox(height: 12),

//         // Description (مختصر)
//         Text(
//           property.description,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),

//         const SizedBox(height: 16),

//         // Buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: onBook,
//                 child: const Text('احجز'),
//               ),
//             ),
//             const SizedBox(width: 10),
//             IconButton(
//               onPressed: () {},
//               icon: const Icon(Icons.favorite_border),
//             )
//           ],
//         ),
//       ],
//     );
//   }

//   // ================= CHIP =================

//   Widget _chip(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 12),
//       ),
//     );
//   }
// }
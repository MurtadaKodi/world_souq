// import 'package:flutter/material.dart';
// import 'property_map.dart';

// class LazyPropertyMap extends StatefulWidget {
//   final double lat;
//   final double lng;
//   final dynamic property;
//   final Function(dynamic) onOpenFullMap;

//   const LazyPropertyMap({
//     super.key,
//     required this.lat,
//     required this.lng,
//     required this.property,
//     required this.onOpenFullMap,
//   });

//   @override
//   State<LazyPropertyMap> createState() => _LazyPropertyMapState();
// }

// class _LazyPropertyMapState extends State<LazyPropertyMap> {
//   bool showMap = false;

//   @override
//   Widget build(BuildContext context) {
//     if (!showMap) {
//       return GestureDetector(
//         onTap: () => setState(() => showMap = true),
//         child: Container(
//           height: 220,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.grey.shade200,
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.map, size: 36),
//                 SizedBox(height: 8),
//                 Text('اضغط لعرض الخريطة'),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return PropertyMap(lat: widget.lat, lng: widget.lng, property: widget.property, onOpenFullMap: widget.onOpenFullMap);
//   }
// }

// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';

// import '../../storage/firebase_storage_service.dart';
// import '../models/property_model.dart';



// // ================= EMPTY STATE =================

// // ignore: unused_element
// class _EmptyState extends StatelessWidget {
//   const _EmptyState();

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         color: Colors.black87,
//         borderRadius:
//             BorderRadius.circular(14),
//       ),
//       child: const Padding(
//         padding: EdgeInsets.all(14),
//         child: Text(
//           'لا توجد عقارات ضمن هذا النطاق.\nجرّب توسيع المسافة.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//             height: 1.4,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ================= PROPERTY SHEET =================

// // ignore: unused_element
// class _NearbyPropertySheet
//     extends StatelessWidget {
//   final PropertyModel property;
//   final FirebaseStorageService
//       storageService;
//   final VoidCallback onNavigate;
//   final VoidCallback onBook;

//   const _NearbyPropertySheet({
//     required this.property,
//     required this.storageService,
//     required this.onNavigate,
//     required this.onBook,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final imagePath =
//         property.mainImage ??
//             (property.mediaPaths.isNotEmpty
//                 ? property.mediaPaths.first
//                 : null);

//     return Container(
//       margin: const EdgeInsets.only(top: 80),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius:
//             const BorderRadius.vertical(
//                 top: Radius.circular(24)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             if (imagePath != null)
//               FutureBuilder<String>(
//                 future: storageService
//                     .resolveDownloadUrl(
//                         imagePath),
//                 builder: (context, snap) {
//                   if (!snap.hasData) {
//                     return const SizedBox(
//                       height: 180,
//                       child: Center(
//                         child:
//                             CircularProgressIndicator(),
//                       ),
//                     );
//                   }

//                   return ClipRRect(
//                     borderRadius:
//                         BorderRadius.circular(16),
//                     child: Image.network(
//                       snap.data!,
//                       height: 180,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   );
//                 },
//               )
//             else
//               Container(
//                 height: 180,
//                 color: Colors.grey[300],
//                 child: const Icon(
//                     Icons.image,
//                     size: 60),
//               ),

//             const SizedBox(height: 16),

//             Text(
//               property.title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               '${property.price.toStringAsFixed(0)} ${property.currency}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color:
//                     Colors.redAccent,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(property.address ?? ''),

//             const SizedBox(height: 18),

//             Row(
//               children: [
//                 Expanded(
//                   child:
//                       ElevatedButton.icon(
//                     onPressed:
//                         onNavigate,
//                     icon: const Icon(
//                         Icons.navigation),
//                     label:
//                         const Text(
//                             'Google Map'),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child:
//                       ElevatedButton.icon(
//                     onPressed: onBook,
//                     icon: const Icon(
//                         Icons.event),
//                     label:
//                         const Text(
//                             'حجز موعد'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../models/property_model.dart';
// import '../services/property_storage_service.dart';

// class TopFavoritePropertiesPage extends StatelessWidget {
//   const TopFavoritePropertiesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid =
//         FirebaseAuth.instance.currentUser?.uid;

//     if (uid == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text('يجب تسجيل الدخول'),
//         ),
//       );
//     }

//     final propertyService =
//         PropertyStorageService();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           '🏆 أكثر العقارات حفظاً',
//         ),
//       ),

//       body: StreamBuilder<List<PropertyModel>>(
//         stream: propertyService
//             .streamTopFavoriteProperties(uid),

//         builder: (context, snapshot) {

//           if (!snapshot.hasData) {
//             return const Center(
//               child:
//                   CircularProgressIndicator(),
//             );
//           }

//           final properties =
//               snapshot.data!;

//           if (properties.isEmpty) {
//             return const Center(
//               child: Text(
//                 'لا توجد عقارات محفوظة بعد',
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: properties.length,

//             itemBuilder: (context, index) {

//               final p = properties[index];

//               return Card(
//                 margin:
//                     const EdgeInsets.only(
//                   bottom: 16,
//                 ),

//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     18,
//                   ),
//                 ),

//                 child: ListTile(
//                   contentPadding:
//                       const EdgeInsets.all(12),

//                   leading:
//                       p.mediaPaths.isNotEmpty
//                           ? ClipRRect(
//                               borderRadius:
//                                   BorderRadius
//                                       .circular(
//                                 12,
//                               ),

//                               child: Image.network(
//                                 p.mediaPaths
//                                     .first,

//                                 width: 70,
//                                 height: 70,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           : Container(
//                               width: 70,
//                               height: 70,

//                               decoration:
//                                   BoxDecoration(
//                                 color:
//                                     Colors.grey
//                                         .shade300,

//                                 borderRadius:
//                                     BorderRadius
//                                         .circular(
//                                   12,
//                                 ),
//                               ),

//                               child: const Icon(
//                                 Icons.home,
//                               ),
//                             ),

//                   title: Text(
//                     p.title,
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                   ),

//                   subtitle: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment
//                             .start,

//                     children: [

//                       const SizedBox(
//                         height: 6,
//                       ),

//                       Text(
//                         '${p.price} ${p.currency}',
//                       ),

//                       const SizedBox(
//                         height: 4,
//                       ),

//                       Row(
//                         children: [

//                           const Icon(
//                             Icons.favorite,
//                             color: Colors.pink,
//                             size: 18,
//                           ),

//                           const SizedBox(
//                             width: 4,
//                           ),

//                           Text(
//                             '${p.favoritesCount}',
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
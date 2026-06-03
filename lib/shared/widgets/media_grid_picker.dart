// import 'package:flutter/material.dart';
// import 'package:market_world/shared/widgets/adaptive_image.dart';

// class MediaGridPicker extends StatelessWidget {

//   const MediaGridPicker({
//     required this.images, required this.mainImage, required this.onPick, required this.onRemove, required this.onSetMain, super.key,
//   });
//   final List<String> images;
//   final String? mainImage;
//   final VoidCallback onPick;
//   final void Function(String) onRemove;
//   final void Function(String) onSetMain;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text(
//               'الصور',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const Spacer(),
//             OutlinedButton.icon(
//               onPressed: onPick,
//               icon: const Icon(Icons.add_photo_alternate),
//               label: const Text('إضافة صور'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: images.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//           ),
//           itemBuilder: (context, index) {
//             final path = images[index];
//             final isMain = path == mainImage;

//             return Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: AdaptiveImage(
//                     path: path,
//                   ),
//                 ),
//                 Positioned(
//                   top: 4,
//                   right: 4,
//                   child: InkWell(
//                     onTap: () => onRemove(path),
//                     child: const CircleAvatar(
//                       radius: 10,
//                       backgroundColor: Colors.black54,
//                       child: Icon(
//                         Icons.close,
//                         size: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 4,
//                   left: 4,
//                   child: InkWell(
//                     onTap: () => onSetMain(path),
//                     child: CircleAvatar(
//                       radius: 10,
//                       backgroundColor:
//                           isMain ? Colors.amber : Colors.black45,
//                       child: Icon(
//                         Icons.star,
//                         size: 14,
//                         color: isMain ? Colors.black : Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

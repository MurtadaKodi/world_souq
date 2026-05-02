// import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';

// class SimplePhotoView extends StatelessWidget {
//   final List<String> images;
//   final int initialIndex;

//   const SimplePhotoView({
//     super.key,
//     required this.images,
//     required this.initialIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final controller = PageController(initialPage: initialIndex);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           /// 🔥 Gallery
//           PhotoViewGallery.builder(
//             pageController: controller,
//             itemCount: images.length,
//             scrollPhysics: const BouncingScrollPhysics(),

//             builder: (context, index) {
//               final image = images[index];

//               return PhotoViewGalleryPageOptions(
//                 imageProvider: NetworkImage(image),
//                 minScale: PhotoViewComputedScale.contained,
//                 maxScale: PhotoViewComputedScale.covered * 3,

//                 heroAttributes: PhotoViewHeroAttributes(tag: image),
//               );
//             },

//             backgroundDecoration: const BoxDecoration(
//               color: Colors.black,
//             ),
//           ),

//           /// ❌ زر الإغلاق
//           Positioned(
//             top: 40,
//             right: 20,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: const CircleAvatar(
//                 backgroundColor: Colors.black54,
//                 child: Icon(Icons.close, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SimplePhotoView extends StatelessWidget {

  const SimplePhotoView({
    required this.images, required this.initialIndex, super.key,
  });
  final List<String> images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final image = images[initialIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(image),
        ),
      ),
    );
  }
}
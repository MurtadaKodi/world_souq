// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';

// class StorageImage extends StatelessWidget {

//   const StorageImage({
//     required this.path, super.key,
//     this.fit = BoxFit.cover,
//   });
//   final String path;
//   final BoxFit fit;

//   Future<String> _resolveUrl() async {
//     if (path.startsWith('http')) return path;
//     return FirebaseStorage.instance.ref(path).getDownloadURL();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: _resolveUrl(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(strokeWidth: 2),
//           );
//         }

//         if (!snapshot.hasData) {
//           return const Center(
//             child: Icon(Icons.broken_image, size: 40),
//           );
//         }

//         return CachedNetworkImage(
//           imageUrl: snapshot.data!,
//           fit: fit,
//           placeholder: (_, __) => const Center(
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//           errorWidget: (_, __, ___) =>
//               const Center(child: Icon(Icons.broken_image)),
//         );
//       },
//     );
//   }
// }

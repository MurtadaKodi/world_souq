// import 'package:flutter/material.dart';
// import 'package:market_world/shared/widgets/adaptive_image.dart';

// class FullscreenGalleryPage extends StatefulWidget {

//   const FullscreenGalleryPage({
//     required this.images, required this.initialIndex, required this.heroTagPrefix, super.key,
//   });
//   final List<String> images;
//   final int initialIndex;
//   final String heroTagPrefix;

//   @override
//   State<FullscreenGalleryPage> createState() =>
//       _FullscreenGalleryPageState();
// }

// class _FullscreenGalleryPageState extends State<FullscreenGalleryPage> {
//   late final PageController _controller;
//   late int _index;

//   @override
//   void initState() {
//     super.initState();
//     _index = widget.initialIndex;
//     _controller = PageController(initialPage: _index);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           '${_index + 1} / ${widget.images.length}',
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//       body: PageView.builder(
//         controller: _controller,
//         itemCount: widget.images.length,
//         onPageChanged: (i) => setState(() => _index = i),
//         itemBuilder: (context, i) {
//           return Hero(
//             tag: '${widget.heroTagPrefix}_$i',
//             child: InteractiveViewer(
//               minScale: 1,
//               maxScale: 4,
//               child: Center(
//                 child: AdaptiveImage(
//                   path: widget.images[i],
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) => const Icon(
//                     Icons.broken_image_outlined,
//                     color: Colors.white,
//                     size: 48,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

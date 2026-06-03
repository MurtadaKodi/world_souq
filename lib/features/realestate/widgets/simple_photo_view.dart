import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SimplePhotoView extends StatelessWidget {
  const SimplePhotoView({
    required this.images,
    required this.initialIndex,
    super.key,
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

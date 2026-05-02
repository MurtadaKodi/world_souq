import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';

class PropertyImage extends StatelessWidget {

  const PropertyImage({
    required this.path, super.key,
    this.radius,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });
  final String path; // ✅ Storage path مثل: properties/<id>/<file>.jpg
  final BorderRadius? radius;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final storage = FirebaseStorageService();

    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: FutureBuilder<String>(
        future: storage.resolveDownloadUrl(path),
        builder: (context, snap) {
          // ✅ Placeholder أثناء جلب URL
          if (!snap.hasData) {
            return _ShimmerBox(width: width, height: height);
          }

          return CachedNetworkImage(
            imageUrl: snap.data!,
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 250),
            placeholder: (_, __) => _ShimmerBox(width: width, height: height),
            errorWidget: (_, __, ___) => Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {

  const _ShimmerBox({this.width, this.height});
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

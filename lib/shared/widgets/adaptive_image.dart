import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AdaptiveImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 🌐 Firebase / Network image
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: errorBuilder ??
            (_, __, ___) =>
                const Icon(Icons.broken_image_outlined),
      );
    }

    // 📱 Mobile local file (camera / gallery)
    if (!kIsWeb && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: errorBuilder ??
            (_, __, ___) =>
                const Icon(Icons.broken_image_outlined),
      );
    }

    // 🖼️ Asset fallback
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: errorBuilder ??
          (_, __, ___) =>
              const Icon(Icons.broken_image_outlined),
    );
  }
}

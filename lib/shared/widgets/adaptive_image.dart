import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String path;
  final BoxFit fit;

  final Widget Function(
    BuildContext,
    Object,
    StackTrace?,
  )? errorBuilder;

  @override
  Widget build(BuildContext context) {

    // 🌐 Firebase / Network / Blob
    if (path.startsWith('http') ||
        path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            errorBuilder ??
            (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                ),
      );
    }

    // 📱 Android / iOS local file
    if (!kIsWeb) {
      return Image.file(
        File(path),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            errorBuilder ??
            (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                ),
      );
    }

    // 🖼️ fallback
    return const Icon(
      Icons.image_outlined,
    );
  }
}
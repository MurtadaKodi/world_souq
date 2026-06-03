import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Map<String, String> _urlCache = {};

  // ================= Upload =================

  Future<String> uploadImage({
    required XFile file,
    required String folder,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$folder/$fileName';

    final ref = _storage.ref(path);

    final Uint8List bytes = await file.readAsBytes();

    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    return path;
  }

  // ================= Resolve =================

  Future<String> resolveDownloadUrl(String pathOrUrl) async {
    if (pathOrUrl.startsWith('http')) {
      return pathOrUrl;
    }

    if (_urlCache.containsKey(pathOrUrl)) {
      return _urlCache[pathOrUrl]!;
    }

    final url = await _storage.ref(pathOrUrl).getDownloadURL();

    _urlCache[pathOrUrl] = url;

    return url;
  }

  Future<void> preloadImage(
    String path,
    BuildContext context,
  ) async {
    if (_urlCache.containsKey(path)) return;

    final url = await resolveDownloadUrl(path);

    // ignore: use_build_context_synchronously
    await precacheImage(NetworkImage(url), context);
  }

  String getCachedUrl(String path) {
    final url = _urlCache[path];

    if (url == null) {
      throw Exception(
        'URL not cached yet for path: $path',
      );
    }

    return url;
  }

  // ================= Delete =================

  Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();

    _urlCache.remove(path);
  }

  Future<void> deleteFolder(String folderPath) async {
    if (!folderPath.startsWith('properties/')) {
      throw Exception(
        'Unsafe delete blocked: $folderPath',
      );
    }

    final ref = _storage.ref(folderPath);

    final list = await ref.listAll();

    for (final item in list.items) {
      await item.delete();
      _urlCache.remove(item.fullPath);
    }
  }
}
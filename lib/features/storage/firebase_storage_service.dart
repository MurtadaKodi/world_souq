import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 🧠 cache للـ download URLs
  final Map<String, String> _urlCache = {};

  // ================= Upload =================

  /// ⬆️ رفع صورة وإرجاع PATH فقط (بدون URL)
  Future<String> uploadImage({
    required String localPathOrUrl,
    required String folder,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$folder/$fileName';
    final ref = _storage.ref(path);

    UploadTask task;

    if (kIsWeb) {
      final bytes = await _readWebBytes(localPathOrUrl);
      task = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
    } else {
      task = ref.putFile(
        File(localPathOrUrl),
        SettableMetadata(contentType: contentType),
      );
    }

    await task;
    return path; // ✅ PATH فقط
  }

  // ================= Resolve =================

  /// 🔗 path → downloadURL (مع كاش)
  Future<String> resolveDownloadUrl(String pathOrUrl) async {
  // لو أصلاً URL لا نحوله
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

  /// ⚡ preload + cache
  Future<void> preloadImage(String path, BuildContext context) async {
    if (_urlCache.containsKey(path)) return;

    final url = await resolveDownloadUrl(path);
    // ignore: use_build_context_synchronously
    await precacheImage(NetworkImage(url), context);
  }

  /// 🔒 جلب URL من الكاش فقط (اختياري)
  String getCachedUrl(String path) {
    final url = _urlCache[path];
    if (url == null) {
      throw Exception('URL not cached yet for path: $path');
    }
    return url;
  }

  // ================= Delete =================

  /// ✅ NEW: حذف ملف واحد
  Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();

    // تنظيف الكاش
    _urlCache.remove(path);
  }

  // ignore: unintended_html_in_doc_comment
  /// 🗑 حذف مجلد كامل (مثلاً properties/<id>)
  Future<void> deleteFolder(String folderPath) async {
    // حماية بسيطة حتى لا تحذف أي شيء بالغلط
    if (!folderPath.startsWith('properties/')) {
      throw Exception('Unsafe delete blocked: $folderPath');
    }

    final ref = _storage.ref(folderPath);
    final list = await ref.listAll();

    for (final item in list.items) {
      await item.delete();
      _urlCache.remove(item.fullPath);
    }
  }

  // ================= Helpers =================

  Future<Uint8List> _readWebBytes(String urlOrPath) async {
    final uri = Uri.parse(urlOrPath);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to read web image bytes: ${res.statusCode}');
    }
    return res.bodyBytes;
  }
}

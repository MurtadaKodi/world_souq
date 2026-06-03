import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// رفع صورة واحدة وإرجاع رابط التحميل
  Future<String> uploadPropertyImage({
    required String propertyId,
    required XFile file,
  }) async {
    try {
      final safeFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(' ', '_')}';

      final ref = _storage
          .ref()
          .child('properties/$propertyId/$safeFileName');

      // ✅ يعمل على Web + Android + iOS
      final bytes = await file.readAsBytes();

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('🔥 Upload Error: $e');
      rethrow;
    }
  }

  /// حذف صورة
  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('🔥 Delete Error: $e');
    }
  }
}
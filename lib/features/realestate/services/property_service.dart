import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_world/core/services/storage_service.dart';
import 'package:market_world/features/realestate/models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ===============================
  /// 🔹 Stream جميع العقارات
  /// ===============================
  Stream<List<PropertyModel>> streamAllProperties() {
    return _db
        .collection('properties')
        .where('lat', isNotEqualTo: null)
        .where('lng', isNotEqualTo: null)
        .snapshots()
        .map(_mapSnapshotToProperties);
  }
Future<void> createProperty({
  required String ownerId,
  required String title,
  required String description,
  required double price,
  required String city,
  required String area,
  required List<XFile> images,
}) async {
  final docRef = _db.collection('properties').doc();
  final propertyId = docRef.id;

  final storageService = StorageService();
  final imageUrls = <String>[];

  // 🔥 رفع الصور أولاً
  for (final image in images) {
    final url = await storageService.uploadPropertyImage(
      propertyId: propertyId,
      file: image,
    );
    imageUrls.add(url);
  }

  // 🔥 حفظ البيانات في Firestore
  await docRef.set({
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'price': price,
    'currency': 'QAR',
    'city': city,
    'area': area,
    'mediaPaths': imageUrls,
    'mainImage': imageUrls.isNotEmpty ? imageUrls.first : null,
    'favoritesCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
/// ===============================
  /// 🔹  إرسال تقييم للعقار Favorites
  /// ===============================

  /// ===============================
  /// 🔹 جلب عقارات محددة عبر IDs
  /// ===============================
  Stream<List<PropertyModel>> getPropertiesByIds(List<String> ids) {
  if (ids.isEmpty) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('properties')
      .where(FieldPath.documentId, whereIn: ids)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map(PropertyModel.fromDoc).toList(),);
}

  /// ===============================
  // ignore: unintended_html_in_doc_comment
  /// 🔹 تحويل Snapshot إلى List<PropertyModel>
  /// ===============================
  List<PropertyModel> _mapSnapshotToProperties(
      QuerySnapshot snapshot,) {
    return snapshot.docs
        .map(
          PropertyModel.fromDoc,
        )
        .toList();
  }
}
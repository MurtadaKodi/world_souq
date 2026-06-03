import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_world/features/realestate/models/property_model.dart';

class PropertyStorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String newPropertyId() => _db.collection('properties').doc().id;

  Future<void> createProperty(PropertyModel p) async {
  final data = p.toJson();

  data['searchKeywords'] = buildSearchKeywords(p);

  data['createdAt'] = FieldValue.serverTimestamp();

  await _db
      .collection('properties')
      .doc(p.id)
      .set(data);
}

  Future<void> updateProperty(PropertyModel p) {
    final data = p.toJson();
    data['searchKeywords'] = buildSearchKeywords(p);
    data['updatedAt'] = FieldValue.serverTimestamp();

    return _db.collection('properties').doc(p.id).update(data);
  }

  Future<void> deleteProperty(String id) {
    return _db.collection('properties').doc(id).delete();
  }

  Stream<List<PropertyModel>> streamMyProperties(String ownerId) {
    return _db.collection('properties').where('ownerId', isEqualTo: ownerId).snapshots().map(
          (s) => s.docs.map(PropertyModel.fromDoc).toList(),
        );
  }

  Stream<List<PropertyModel>> streamAllProperties() {
    return _db.collection('properties').orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(PropertyModel.fromDoc).toList(),
        );
  }

  Stream<int> streamTotalFavoritesForOwner(
    String ownerId,
  ) {
    return _db
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      int total = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        total += (data['favoritesCount'] ?? 0) as int;
      }

      return total;
    });
  }

  Stream<int> streamMyPropertiesCount(String uid) {
    return _db
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<int> countMyProperties(String ownerId) async {
    final snap = await _db.collection('properties').where('ownerId', isEqualTo: ownerId).get();

    return snap.docs.length;
  }

  Stream<List<PropertyModel>> searchProperties({String? keyword}) {
    Query query = _db.collection('properties');

    if (keyword != null && keyword.isNotEmpty) {
      query = query.where(
        'keywords',
        arrayContains: keyword.toLowerCase(),
      );
    }

    return query.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(PropertyModel.fromDoc).toList(),
        );
  }

  List<String> buildSearchKeywords(PropertyModel p) {
    final buffer = <String>{};

    void addValue(String? value) {
      if (value == null || value.trim().isEmpty) return;

      final parts = value.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '').split(RegExp(r'\s+'));

      for (final part in parts) {
        if (part.length >= 2) {
          buffer.add(part);
        }
      }
    }

    // نصوص أساسية
    addValue(p.title);
    addValue(p.city);
    addValue(p.area);
    addValue(p.type);
    addValue(p.purpose);
    addValue(p.address);

    // أرقام مهمة
    buffer.add(p.price.toStringAsFixed(0));
    buffer.add(p.currency.toLowerCase());

    return buffer.toList();
  }

 Stream<List<PropertyModel>>
    streamTopFavoriteProperties(
  String uid,
) {
  return _db
      .collection('properties')
      .where('ownerId', isEqualTo: uid)
      .where(
        'favoritesCount',
        isGreaterThan: 0,
      )
      .orderBy(
        'favoritesCount',
        descending: true,
      )
      .limit(10)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(PropertyModel.fromDoc)
            .toList(),
      );
}

  Stream<List<PropertyModel>> streamPropertiesByOwner(String ownerId) {
    return _db.collection('properties').where('ownerId', isEqualTo: ownerId).snapshots().map(
          (s) => s.docs.map(PropertyModel.fromDoc).toList(),
        );
  }

  streamFavoritesOnMyProperties(String uid) {}


}

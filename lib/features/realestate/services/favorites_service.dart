import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favoritesRef {
    final uid = _uid;
    if (uid == null) return null;

    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites');
  }

  // ❤️ إضافة
  Future<void> addToFavorites(String propertyId) async {
  final uid = _uid;
  if (uid == null) return;

  final batch = _db.batch();

  final favRef = _db
      .collection('favorites')
      .doc(uid)
      .collection('items')
      .doc(propertyId);

  final propertyRef =
      _db.collection('properties').doc(propertyId);

  batch.set(favRef, {
    'propertyId': propertyId,
    'createdAt': FieldValue.serverTimestamp(),
  });

  batch.update(propertyRef, {
    'favoritesCount': FieldValue.increment(1),
  });

  await batch.commit();
}

  // ❌ حذف
  Future<void> removeFromFavorites(String propertyId) async {
  final uid = _uid;
  if (uid == null) return;

  final batch = _db.batch();

  final favRef = _db
      .collection('favorites')
      .doc(uid)
      .collection('items')
      .doc(propertyId);

  final propertyRef =
      _db.collection('properties').doc(propertyId);

  batch.delete(favRef);

  batch.update(propertyRef, {
    'favoritesCount': FieldValue.increment(-1),
  });

  await batch.commit();
}

  // 🔍 هل مفضل؟
  Stream<bool> isFavorite(String propertyId) {
    final ref = _favoritesRef;
    if (ref == null) return const Stream.empty();

    return ref
        .doc(propertyId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // 📋 جميع المفضلات
  Stream<List<String>> getFavorites() {
    final ref = _favoritesRef;
    if (ref == null) return const Stream.empty();

    return ref.snapshots().map(
        (snapshot) => snapshot.docs.map((d) => d.id).toList(),);
  }

  Stream<int> favoritesCount() {
    final ref = _favoritesRef;
    if (ref == null) return const Stream.empty();

    return ref.snapshots().map((s) => s.docs.length);
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandlordDashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// ===============================
  /// 🏠 عدد العقارات
  /// ===============================
  Stream<int> propertiesCount() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// ===============================
  /// 📊 إحصائيات الحجوزات
  /// ===============================
  Stream<Map<String, int>> bookingStats() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('bookings')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      int pending = 0;
      int confirmed = 0;
      int completed = 0;
      int cancelled = 0;

      for (final doc in snapshot.docs) {
        switch (doc['status']) {
          case 'pending':
            pending++;
            break;
          case 'confirmed':
            confirmed++;
            break;
          case 'completed':
            completed++;
            break;
          case 'cancelled':
            cancelled++;
            break;
        }
      }

      return {
        'total': snapshot.docs.length,
        'pending': pending,
        'confirmed': confirmed,
        'completed': completed,
        'cancelled': cancelled,
      };
    });
  }

  /// ===============================
  /// ❤️ عدد المفضلات على عقاراتي
  /// ===============================
  Stream<int> favoritesOnMyProperties() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .asyncMap((propertiesSnapshot) async {
      int totalFavorites = 0;

      for (final property in propertiesSnapshot.docs) {
        final favSnapshot = await _db
            .collectionGroup('favorites')
            .where('propertyId', isEqualTo: property.id)
            .get();

        totalFavorites += favSnapshot.docs.length;
      }

      return totalFavorites;
    });
  }
}
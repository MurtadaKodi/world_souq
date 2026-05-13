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
      var pending = 0;
      var confirmed = 0;
      var completed = 0;
      var cancelled = 0;

      for (final doc in snapshot.docs) {
        switch (doc['status']) {
          case 'pending':
            pending++;
          case 'confirmed':
            confirmed++;
          case 'completed':
            completed++;
          case 'cancelled':
            cancelled++;
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
      .map((snapshot) {

    int total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      total +=
          (data['favoritesCount'] ?? 0)
              as int;
    }

    return total;
  });
}
}
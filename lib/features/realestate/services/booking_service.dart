import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'bookings';

  String? get _uid => _auth.currentUser?.uid;

  // ================= GET BY ID =================

  Future<BookingModel> getBookingById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    return BookingModel.fromDoc(doc);
  }

  // ================= CREATE =================

  Future<void> createBooking(BookingModel booking) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('NOT_LOGGED_IN');
    }

    // ❌ منع الحجز في نفس الوقت
    final conflict = await _db
        .collection(_collection)
        .where('propertyId', isEqualTo: booking.propertyId)
        .where(
          'visitDate',
          isEqualTo: Timestamp.fromDate(booking.visitDate),
        )
        .where('visitTime', isEqualTo: booking.visitTime)
        .get();

    if (conflict.docs.isNotEmpty) {
      throw Exception('TIME_ALREADY_BOOKED');
    }

    await _db.collection(_collection).add({
  ...booking.toJson(),
  'clientId': uid,
  'ownerId': booking.ownerId, // 🔴 تأكد أنه محفوظ
  'status': 'pending',
  'createdAt': FieldValue.serverTimestamp(),
});
  }

  // ================= STREAMS =================

  Stream<List<BookingModel>> streamPropertyBookingsForDate(
    String propertyId,
    DateTime date,
  ) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _db
        .collection(_collection)
        .where('propertyId', isEqualTo: propertyId)
        .where('visitDate', isGreaterThanOrEqualTo: start)
        .where('visitDate', isLessThan: end)
        .snapshots()
        .map(
          (s) => s.docs.map(BookingModel.fromDoc).toList(),
        );
  }
  Stream<Map<String, int>> streamOwnerBookingStats() {
  final uid = _uid;
  if (uid == null) return const Stream.empty();

  return _db
      .collection(_collection)
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    int pending = 0;
    int confirmed = 0;
    int completed = 0;
    int cancelled = 0;

    for (final d in snap.docs) {
      switch (d['status']) {
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
      'total': snap.docs.length,
      'pending': pending,
      'confirmed': confirmed,
      'completed': completed,
      'cancelled': cancelled,
    };
  });
}

  Stream<List<BookingModel>> streamMyBookings() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection(_collection)
        .where('clientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(BookingModel.fromDoc).toList(),
        );
  }

  Stream<List<BookingModel>> streamOwnerBookings() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection(_collection)
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(BookingModel.fromDoc).toList(),
        );
  }

  // ================= STATUS =================

  Future<void> updateStatus(String id, String status) async {
    await _db.collection(_collection).doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmBooking(String id) =>
      updateStatus(id, 'confirmed');

  Future<void> cancelBooking(String id) =>
      updateStatus(id, 'cancelled');

  Future<void> completeBooking(String id) =>
      updateStatus(id, 'completed');

  Future<Map<String, int>> getOwnerBookingStats(String uid) async {
  final snap = await _db
      .collection(_collection)
      .where('ownerId', isEqualTo: uid)
      .get();

  int pending = 0;
  int confirmed = 0;
  int completed = 0;
  int cancelled = 0;

  for (final d in snap.docs) {
    switch (d['status']) {
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
    'total': snap.docs.length,
    'pending': pending,
    'confirmed': confirmed,
    'completed': completed,
    'cancelled': cancelled,
  };
}

  Future<Map<String, int>> getTenantBookingStats(String uid) async {
    throw UnimplementedError('getTenantBookingStats is not yet implemented.');
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_world/features/realestate/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'bookings';

  String? get _uid => _auth.currentUser?.uid;

  static const bool isDemoMode = false;

  // ================= CREATE =================

  Future<void> createBooking(BookingModel booking) async {
    final uid = _uid;
    if (uid == null) {
      throw 'يجب تسجيل الدخول أولاً';
    }

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
      throw 'هذا الوقت محجوز مسبقاً';
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _db.collection(_collection).add({
      ...booking.toJson(),
      'clientId': uid,
      'ownerId': booking.ownerId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= STREAMS =================

  Stream<List<BookingModel>> streamMyBookings() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection(_collection)
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map(BookingModel.fromDoc).toList());
  }

  Stream<List<BookingModel>> streamOwnerBookings() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection(_collection)
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map(BookingModel.fromDoc).toList());
  }

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
        .map((s) => s.docs.map(BookingModel.fromDoc).toList());
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

  // ================= DELETE =================

  Future<void> deleteBooking(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('NOT_LOGGED_IN');

    final docRef = _db.collection(_collection).doc(id);
    final doc = await docRef.get();

    if (!doc.exists) throw Exception('BOOKING_NOT_FOUND');

    final data = doc.data()!;
    if (uid != data['ownerId'] && uid != data['clientId']) {
      throw Exception('NOT_AUTHORIZED');
    }

    await docRef.delete();
  }
  Future<BookingModel> getBookingById(String id) async {
  final doc = await _db.collection(_collection).doc(id).get();
  return BookingModel.fromDoc(doc);
}
Stream<Map<String, int>> streamOwnerBookingStats() {
  final uid = _uid;
  if (uid == null) {
    return Stream.value({
    'total': 0,
    'pending': 0,
    'completed': 0,
  });
  }

  return _db
      .collection(_collection)
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final total = snap.docs.length;
    var pending = 0;
    var completed = 0;

    for (final d in snap.docs) {
      final status = d['status'] ?? 'pending';

      if (status == 'pending') pending++;
      if (status == 'completed') completed++;
    }

    return {
      'total': total,
      'pending': pending,
      'completed': completed,
    };
  });
}
Future<Map<String, int>> getTenantBookingStats(String uid) async {
  final snap = await _db
      .collection(_collection)
      .where('clientId', isEqualTo: uid)
      .get();

  var pending = 0;
  var confirmed = 0;
  var completed = 0;
  var cancelled = 0;

  for (final d in snap.docs) {
    switch (d['status']) {
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
    'total': snap.docs.length,
    'pending': pending,
    'confirmed': confirmed,
    'completed': completed,
    'cancelled': cancelled,
  };
}
}
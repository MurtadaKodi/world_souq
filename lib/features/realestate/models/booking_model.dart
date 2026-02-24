import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String ownerId;

  final String clientName;
  final String clientPhone;

  final DateTime visitDate;
  final String visitTime;

  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.ownerId,
    required this.clientName,
    required this.clientPhone,
    required this.visitDate,
    required this.visitTime,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'propertyName': propertyName,
        'ownerId': ownerId,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'visitDate': Timestamp.fromDate(visitDate),
        'visitTime': visitTime,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory BookingModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      propertyId: data['propertyId'],
      propertyName: data['propertyName'],
      ownerId: data['ownerId'],
      clientName: data['clientName'],
      clientPhone: data['clientPhone'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      visitTime: data['visitTime'],
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
    // ================= UI GETTERS =================

  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';

}

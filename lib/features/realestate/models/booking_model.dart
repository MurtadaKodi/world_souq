import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {

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

  factory BookingModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      propertyId: data['propertyId']?.toString() ?? '',
      propertyName: data['propertyName']?.toString() ?? '',
      ownerId: data['ownerId']?.toString() ?? '',
      clientName: data['clientName']?.toString() ?? '',
      clientPhone: data['clientPhone']?.toString() ?? '',
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      visitTime: data['visitTime']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
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

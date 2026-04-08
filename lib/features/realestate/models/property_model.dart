import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String id;
  final String ownerId;

  final String title;
  final String description;
  final double price;
  final String currency;

  final String type;
  final String purpose;

  final String city;
  final String area;

  final List<String> mediaPaths;
  final String? mainImage;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  final List<String> searchKeywords;

  final double? lat;
  final double? lng;

  final String? address;
  final int favoritesCount;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'QAR',
    required this.type,
    required this.purpose,
    required this.city,
    required this.area,
    required this.mediaPaths,
    this.mainImage,
    this.createdAt,
    this.updatedAt,
    this.searchKeywords = const [],
    this.lat,
    this.lng,
    this.address, required this.favoritesCount,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory PropertyModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double? lat = _toDouble(data['lat']);
    double? lng = _toDouble(data['lng']);

    final loc = data['location'];
    if ((lat == null || lng == null) && loc is GeoPoint) {
      lat = loc.latitude;
      lng = loc.longitude;
    }

    return PropertyModel(
      id: doc.id,
      ownerId: (data['ownerId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      price: _toDouble(data['price']) ?? 0,
      currency: (data['currency'] ?? 'QAR').toString(),
      type: (data['type'] ?? '').toString(),
      purpose: (data['purpose'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      area: (data['area'] ?? '').toString(),
      mediaPaths: (data['mediaPaths'] is List)
          ? List<String>.from(
              (data['mediaPaths'] as List).map((e) => e.toString()),
            )
          : const [],
      mainImage: data['mainImage']?.toString(),
      createdAt:
          data['createdAt'] is Timestamp ? data['createdAt'] : null,
      updatedAt:
          data['updatedAt'] is Timestamp ? data['updatedAt'] : null,
      searchKeywords: (data['searchKeywords'] is List)
          ? List<String>.from(
              (data['searchKeywords'] as List).map((e) => e.toString()),
            )
          : const [],
      lat: lat,
      lng: lng,
      address: data['address']?.toString(), favoritesCount: (data['favoritesCount'] is int)
    ? data['favoritesCount']
    : int.tryParse(data['favoritesCount']?.toString() ?? '') ?? 0,
    );
  }

  get imageUrls => null;

  Map<String, dynamic> toJson() {
  return {
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'price': price,
    'currency': currency,
    'type': type,
    'purpose': purpose,
    'city': city,
    'area': area,
    'mediaPaths': mediaPaths,
    'mainImage': mainImage,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'searchKeywords': searchKeywords,
    'lat': lat,
    'lng': lng,
    'address': address,
    'favoritesCount': favoritesCount,
  };
}
}
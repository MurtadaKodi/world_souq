class UserProfileModel {
  final String uid;
  final String name;
  final String phone;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.phone,
  });

  factory UserProfileModel.fromJson(String uid, Map<String, dynamic> data) {
    return UserProfileModel(
      uid: uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

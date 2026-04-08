import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// ================= GET PROFILE =================
  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return doc.data();
  }

  /// ================= SAVE FCM TOKEN =================
  Future<void> saveFcmToken(String token) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).set(
      {
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

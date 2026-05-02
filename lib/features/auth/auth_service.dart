import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String? get uid => _auth.currentUser?.uid;

  // 🔐 LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 🔓 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 👤 ROLE
  Future<void> saveUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set(
      {
        'role': role,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data()?['role'] as String?;
  }

  // 🚫 CHECK ACTIVE
  Future<void> ensureUserIsActive() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data()?['active'] == false) {
      await _auth.signOut();
      throw Exception('USER_DISABLED');
    }
  }

  // ✅ REGISTER (الحل النهائي)
  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 🔹 Firestore (لا نخليها تكسر العملية)
      try {
        await _db.collection('users').doc(uid).set({
          'email': email,
          'role': role,
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
          'active': true,
        });
      } catch (e) {
        // 👇 تجاهل الخطأ
        // ignore: avoid_print
        print('⚠️ Firestore error ignored: $e');
      }

    } on FirebaseAuthException {
      rethrow; // فقط Firebase errors
    }
  }

  // 🔁 UPGRADE anonymous → email
  Future<void> linkAnonymousWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw Exception('No anonymous user');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.linkWithCredential(credential);
  }
}
import 'package:flutter/material.dart';
import 'package:market_world/core/services/role_cache_service.dart';
import 'package:market_world/features/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {

  AuthProvider(this._authService) {
    _authService.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
  final AuthService _authService;
  Future<void> ensureUserIsActive() async {
  await _authService.ensureUserIsActive();
}

  // 👑 ADMIN CHECK
Future<bool> isAdmin() async {
  final cached = await RoleCacheService.isAdmin();
  if (cached) return true;

  final role = await _authService.getUserRole();
  if (role != null) {
    await RoleCacheService.saveRole(role);
  }
  return role == 'admin';
}



  // 🔐 LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email, password: password);
  }
  // 🔓 LOGOUT
Future<void> logout() async {
  await _authService.logout();
  await RoleCacheService.clear(); // 🧹 clear cache
}

// Add background refresh method
Future<void> _refreshRoleFromServer() async {
  final role = await _authService.getUserRole();
  if (role != null) {
    await RoleCacheService.saveRole(role);
    notifyListeners();
  }
}



  // 🔁 UPGRADE anonymous → email
  Future<void> upgradeToEmail({
    required String email,
    required String password,
  }) {
    return _authService.linkAnonymousWithEmail(
      email: email,
      password: password,
    );
  }

  // 👤 ROLE
  Future<void> saveRole(String role) async {
  await _authService.saveUserRole(role);
  await RoleCacheService.saveRole(role); // ⚡ cache
}


  Future<String?> fetchUserRole() async {
  // 1️⃣ Try cache first
  final cachedRole = await RoleCacheService.getRole();
  if (cachedRole != null) {
    // Refresh in background
    _refreshRoleFromServer();
    return cachedRole;
  }

  // 2️⃣ Fallback to Firestore
  final role = await _authService.getUserRole();
  if (role != null) {
    await RoleCacheService.saveRole(role);
  }
  return role;
}
Future<void> register({
  required String email,
  required String password,
  required String role,
}) async {
  await _authService.register(
    email: email,
    password: password,
    role: role,
  );
}



  String? get uid => _authService.uid;
}


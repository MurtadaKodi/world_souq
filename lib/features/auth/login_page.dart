// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_world/features/shared/services/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:market_world/features/realestate/navigation/landlord_bottom_nav.dart';
import 'package:market_world/features/realestate/navigation/tenant_bottom_nav.dart';
import '../../core/constants/enums.dart';
import '../../core/providers/language_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final UserRole role;

  const LoginPage({
    super.key,
    required this.role,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  final UserProfileService _profileService = UserProfileService();

  bool obscure = true;
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // ================= VALIDATION =================
  bool _validate(BuildContext context) {
    final isArabic = context.read<LanguageProvider>().isArabic;

    if (emailCtrl.text.trim().isEmpty) {
      _showError(
        isArabic ? 'البريد الإلكتروني مطلوب' : 'Email is required',
      );
      return false;
    }

    if (!emailCtrl.text.contains('@')) {
      _showError(
        isArabic ? 'صيغة البريد غير صحيحة' : 'Invalid email format',
      );
      return false;
    }

    if (passwordCtrl.text.length < 6) {
      _showError(
        isArabic
            ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
            : 'Password must be at least 6 characters',
      );
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ================= FCM SETUP =================
  Future<void> _setupFcm() async {
  // 🚫 أوقف التنفيذ بالكامل على Web
  if (kIsWeb) {
    debugPrint('⚠️ FCM disabled on Web');
    return;
  }

  debugPrint('🔔 Setting up FCM...');

  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final token = await messaging.getToken();
  if (token != null) {
    await _profileService.saveFcmToken(token);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    _profileService.saveFcmToken(newToken);
  });
}


  // ================= LOGIN =================
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_validate(context)) return;

    final isArabic = context.read<LanguageProvider>().isArabic;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );

      if (!mounted) return;

      // إعداد FCM بعد تسجيل الدخول
      await _setupFcm();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تم تسجيل الدخول بنجاح 🎉' : 'Login successful 🎉',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      if (widget.role == UserRole.tenant) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TenantBottomNav(openBookingId: null, initialIndex: 0)),
        );
      } else if (widget.role == UserRole.landlord) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LandlordBottomNav()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;

      switch (e.code) {
        case 'user-not-found':
          msg = isArabic
              ? 'لا يوجد حساب بهذا البريد'
              : 'No account found for this email';
          break;
        case 'wrong-password':
          msg = isArabic ? 'كلمة المرور غير صحيحة' : 'Incorrect password';
          break;
        case 'user-disabled':
          msg = isArabic
              ? 'تم تعطيل هذا الحساب'
              : 'This account has been disabled';
          break;
        default:
          msg = isArabic ? 'فشل تسجيل الدخول' : 'Login failed';
      }

      _showError(msg);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(isArabic ? 'تسجيل الدخول' : 'Login'),
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://res.cloudinary.com/dmklduciw/image/upload/v1769102423/login_ppicpw.png',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white70,
                BlendMode.lighten,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// HERO
                Hero(
                  tag: 'auth-hero',
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.store,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  widget.role.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                /// EMAIL
                TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText:
                        isArabic ? 'البريد الإلكتروني' : 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 12),

                /// PASSWORD
                TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: passwordCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText:
                        isArabic ? 'كلمة المرور' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscure = !obscure),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: loading ? null : _login,
                    child: Text(
                      loading
                          ? '...'
                          : (isArabic ? 'دخول' : 'Login'),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// REGISTER
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RegisterPage(role: widget.role),
                      ),
                    );
                  },
                  child: Text(
                    isArabic
                        ? 'إنشاء حساب جديد'
                        : 'Create new account',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use, avoid_catches_without_on_clauses, inference_failure_on_instance_creation

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/core/providers/auth_provider.dart';
import 'package:market_world/shared/navigation/main_bottom_nav.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.role, super.key});
  final UserRole role;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;




Future<void> _register() async {
  FocusScope.of(context).unfocus();
  setState(() => loading = true);

  final isArabic =
      Localizations.localeOf(context).languageCode == 'ar';

  try {
    final authProvider = context.read<AuthProvider>();

    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

   if (email.isEmpty || password.length < 6) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(isArabic
          ? 'يرجى إدخال بيانات صحيحة'
          : 'Please enter valid data',),
    ),
  );
  setState(() => loading = false);
  return;
}

    await authProvider.register(
      email: email,
      password: password,
      role: widget.role.name,
    );

    if (!mounted) return;

   ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      isArabic
          ? 'تم إنشاء الحساب بنجاح 🎉'
          : 'Account created successfully 🎉',
    ),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 2),
  ),
);

// ⏳ انتظر قبل الانتقال
Future.delayed(const Duration(seconds: 1), () {
  Navigator.pushReplacement(
    // ignore: use_build_context_synchronously
    context,
    MaterialPageRoute(
      builder: (_) => MainBottomNav(role: widget.role),
    ),
  );
});

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainBottomNav(role: widget.role),
      ),
    );
  }

  // ✅ هنا السحر الحقيقي
  on FirebaseAuthException catch (e) {
    String msg;

    switch (e.code) {
      case 'email-already-in-use':
        msg = isArabic
            ? 'هذا البريد مستخدم بالفعل، حاول تسجيل الدخول'
            : 'This email is already registered. Try logging in.';

      case 'invalid-email':
        msg = isArabic
            ? 'صيغة البريد غير صحيحة'
            : 'Invalid email format';

      case 'weak-password':
        msg = isArabic
            ? 'كلمة المرور ضعيفة'
            : 'Password is too weak';

      default:
        msg = isArabic
            ? 'فشل إنشاء الحساب'
            : 'Registration failed';
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );

    // 🔥 تحويل ذكي لصفحة Login
    if (e.code == 'email-already-in-use') {
      Future.delayed(const Duration(seconds: 1), () {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });
    }
  }

  catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'حدث خطأ غير متوقع'
              : 'An unexpected error occurred',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) setState(() => loading = false);
  }
}

 @override
Widget build(BuildContext context) {
  final isArabic =
      Localizations.localeOf(context).languageCode == 'ar';

  return Scaffold(
    body: Stack(
      children: [
        // 🖼️ Background
        Positioned.fill(
          child: Image.asset(
            'lib/assets/images/login_bg2.jpeg',
            fit: BoxFit.cover,
          ),
        ),

        // 🌫️ Overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // ✨ Content
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 👑 Title
                        const Text(
                          'Dari',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          isArabic ? 'إنشاء حساب' : 'Create Account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 📧 Email
                        TextField(
                          controller: emailCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText:
                                isArabic ? 'البريد الإلكتروني' : 'Email',
                            hintStyle:
                                const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.email,
                                color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🔒 Password
                        TextField(
                          controller: passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText:
                                isArabic ? 'كلمة المرور' : 'Password',
                            hintStyle:
                                const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.lock,
                                color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🚀 Register Button
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.purple,
                                Colors.blue,
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    isArabic ? 'إنشاء حساب' : 'Register',
                                    style:
                                        const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔙 Back to Login
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            isArabic
                                ? 'لديك حساب؟ تسجيل الدخول'
                                : 'Already have an account? Login',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

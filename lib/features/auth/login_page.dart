// lib/features/auth/login_page.dart

// ignore_for_file: deprecated_member_use, inference_failure_on_instance_creation, inference_failure_on_function_invocation, avoid_print

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/core/providers/language_provider.dart';
import 'package:market_world/features/auth/register_page.dart';
import 'package:market_world/features/realestate/navigation/landlord_bottom_nav.dart';
import 'package:market_world/features/realestate/navigation/tenant_bottom_nav.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.role, super.key});
  final UserRole role;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool obscure = true;
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate(BuildContext context) {
    final isArabic = context.read<LanguageProvider>().isArabic;

    if (emailCtrl.text.isEmpty) {
      _showError(isArabic ? 'البريد مطلوب' : 'Email required');
      return false;
    }

    if (!emailCtrl.text.contains('@')) {
      _showError(isArabic ? 'بريد غير صحيح' : 'Invalid email');
      return false;
    }

    if (passwordCtrl.text.length < 6) {
      _showError(isArabic ? 'كلمة المرور ضعيفة' : 'Weak password');
      return false;
    }

    return true;
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('⚠️'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_validate(context)) return;

    final isArabic = context.read<LanguageProvider>().isArabic;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم الدخول 🎉' : 'Login success 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.role == UserRole.tenant) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TenantBottomNav(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LandlordBottomNav(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('🔥 ERROR: ${e.code}');

      _showError(e.message ?? 'Login failed');
    } catch (e) {
      print('🔥 UNKNOWN: $e');
      _showError(isArabic ? 'خطأ غير متوقع' : 'Unexpected error');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return Scaffold(
      body: Stack(
        children: [
          // 🖼️ Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/login_bg2.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // 🌫️ Dark Overlay
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

                  // 🔥 Glass Effect
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
                            isArabic ? 'تسجيل الدخول' : 'Login',
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
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.white),
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
                            controller: passwordCtrl,
                            obscureText: obscure,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'كلمة المرور' : 'Password',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // 🚀 Login Button (Gradient)
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
                              onPressed: loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      isArabic ? 'دخول' : 'Login',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🆕 Register
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
                              isArabic ? 'إنشاء حساب' : 'Create Account',
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

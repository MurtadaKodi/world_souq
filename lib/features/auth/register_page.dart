// ignore_for_file: avoid_catches_without_on_clauses, inference_failure_on_instance_creation

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'إنشاء حساب'
              : 'Create Account',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : _register,
                child: Text(loading ? '...' : 'Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

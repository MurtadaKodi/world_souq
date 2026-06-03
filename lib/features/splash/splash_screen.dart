// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:market_world/features/entry/entry_gate_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_world/features/realestate/navigation/landlord_bottom_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _glow;
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _glow = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.repeat(reverse: true);

    _goNext();
  }

  Future<void> _goNext() async {
  await Future.delayed(const Duration(seconds: 3));

  if (!mounted) return;

  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LandlordBottomNav(),
      ),
    );
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const EntryGatePage(),
    ),
  );
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // 🖼️ Background
        Positioned.fill(
          child: Image.asset(
            'lib/assets/images/splash.png',
            fit: BoxFit.cover,
          ),
        ),

        // 🌑 Overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3), // أخف عشان الشعار يظهر
          ),
        ),

        // ✨ Bottom Text (احترافي)
        Positioned(
          bottom: 60,
          left: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Opacity(
                opacity: _fade.value,
                child: child,
              );
            },
            child:   const Column(
              children: [
                Text(
                  'Smart Real Estate Platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'البوابة العقارية الذكية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}

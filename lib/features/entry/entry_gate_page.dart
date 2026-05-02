// ignore_for_file: cascade_invocations, avoid_positional_boolean_parameters, inference_failure_on_instance_creation, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:market_world/core/providers/language_provider.dart';
import 'package:market_world/features/admin/admin_login_page.dart';
import 'package:market_world/features/landing/landing_page.dart';
import 'package:market_world/shared/widgets/app_app_bar.dart';
import 'package:market_world/shared/widgets/reusble_glass_button.dart';
import 'package:provider/provider.dart';

class EntryGatePage extends StatefulWidget {
  const EntryGatePage({super.key});

  @override
  State<EntryGatePage> createState() => _EntryGatePageState();
}

class _EntryGatePageState extends State<EntryGatePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;
  late Timer _timer;
  late DateTime now;

  @override
  @override
  void initState() {
    super.initState();

    now = DateTime.now();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        setState(() => now = DateTime.now());
      },
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    // Define the current date and time
    final now = DateTime.now();

    return Scaffold(
      appBar: AppAppBar(
        title: context.watch<LanguageProvider>().isArabic ? 'بوابة الدخول' : 'Entry Gate',
        showBack: false,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🌊 TOP WAVE
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return ClipPath(
                clipper: AnimatedTopWaveClipper(_controller.value),
                child: Container(
                  height: isSmall ? 180 : 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0D47A1),
                        Colors.black54,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          /// 🧱 CONTENT
          SafeArea(
            bottom: false, // 👈 الموجة بالأسفل لا تتأثر
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: isSmall
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: const Column(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 16),
                    //     child: TextButton(
                    //       onPressed: () {
                    //         context.watch<LanguageProvider>().toggleLanguage();
                    //       },
                    //       child: Text(
                    //         context.watch<LanguageProvider>().isArabic
                    //             ? 'EN'
                    //             : 'AR',
                    //         style: const TextStyle(
                    //           color: Colors.white70,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: isSmall ? 20 : 40),

                    /// 📅 DATE (optional)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          children: [
                            /// ⏰ Dynamic Date & Time
                            buildDateTime(
                              context,
                              context.watch<LanguageProvider>().isArabic,
                              now,
                            ),

                            SizedBox(height: isSmall ? 20 : 40),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// 🌍 LOGO / IMAGE
                    FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: slideAnim,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              children: [
                                /// 🌍 LOGO
                                Container(
                                  width: isSmall ? 120 : 160,
                                  height: isSmall ? 120 : 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://res.cloudinary.com/dmklduciw/image/upload/v1766076111/world_qtzza4.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: isSmall ? 20 : 40),

                                /// 👋 WELCOME TEXT
                                Text(
                                  context.watch<LanguageProvider>().isArabic ? 'مرحبا' : 'Welcome',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: isSmall ? 20 : 40),
                                Text(
                                  context.watch<LanguageProvider>().isArabic
                                      ? 'داري العقارية'
                                      : 'Dari Real Estate',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// ⬅️➡️ ACTIONS
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// 👤 USER
                            GlassButton(
                              width: (size.width * 0.8).toInt(),
                              text: context.watch<LanguageProvider>().isArabic
                                  ? 'الدخول كمستخدم'
                                  : 'User Login',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LandingPage(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: isSmall ? 30 : 50),

                            /// 👑 ADMIN
                            GlassButton(
                              width: (size.width * 0.8).toInt(),
                              primary: false,
                              text: context.watch<LanguageProvider>().isArabic
                                  ? 'دخول المدير'
                                  : 'Admin Login',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminLoginPage(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: isSmall ? 10 : 20),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: isSmall ? 20 : 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to determine if it's night time (e.g., after 6pm or before 6am)
  bool get isNight {
    final hour = now.hour;
    return hour < 6 || hour >= 18;
  }

  Widget buildDateTime(BuildContext context, bool isArabic, DateTime now) {
    final dateText = isArabic
        ? DateFormat('EEEE، d MMMM y', 'ar').format(now)
        : DateFormat('EEEE, MMM d y', 'en').format(now);

    final timeText = DateFormat('hh:mm:ss a').format(now);

    final color = isNight ? Colors.indigo.shade300 : Colors.orange.shade700;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        // 🖥️ يظهر عند hover (Web)
        message: timeText,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedTopWaveClipper extends CustomClipper<Path> {
  AnimatedTopWaveClipper(this.progress);
  final double progress;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);

    const waveHeight = 20;
    final waveLength = size.width;

    path.quadraticBezierTo(
      waveLength * 0.25,
      size.height - 60 + waveHeight * (1 - progress),
      waveLength * 0.5,
      size.height - 60,
    );

    path.quadraticBezierTo(
      waveLength * 0.75,
      size.height - 60 - waveHeight * progress,
      waveLength,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant AnimatedTopWaveClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 40,
    );

    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 80,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

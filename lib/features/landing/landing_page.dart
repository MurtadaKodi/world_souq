// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/core/providers/language_provider.dart';
import 'package:market_world/features/auth/login_page.dart';
import 'package:provider/provider.dart';

/// ================= Landing Page =================

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late DateTime now;
  late final Timer _timer;

  bool get isNight => now.hour < 6 || now.hour > 18;

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
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _go(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: LoginPage(role: role),
          );
        },
      ),
    );
  }

  Widget buildDateTime(BuildContext context, bool isArabic) {
    final dateText = isArabic
        ? DateFormat('EEEE، d MMMM y', 'ar').format(now)
        : DateFormat('EEEE, MMM d y', 'en').format(now);

    final timeText = DateFormat('hh:mm:ss a').format(now);

    final color = isNight ? Colors.indigo.shade300 : Colors.orange.shade700;

    return Tooltip(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;

    final items = [
      {
        'title': isArabic ? 'مستأجر' : 'Tenant',
        'subtitle': isArabic ? 'ابحث واحجز زيارة' : 'Find & book a property',
        'icon': Icons.key_outlined,
        'size': 40.0,
        'role': UserRole.tenant,
        'color': Colors.orange,
      },
      {
        'title': isArabic ? 'مؤجّر' : 'Landlord',
        'subtitle': isArabic ? 'أضف وأدر عقاراتك' : 'Add & manage properties',
        'icon': Icons.home_work_outlined,
        'size': 40.0,
        'role': UserRole.landlord,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
    body: Stack(
  children: [
    Positioned.fill(
      child: Image.network(
        'https://res.cloudinary.com/dmklduciw/image/upload/v1768933674/tenant2_k8lf0e.webp',
        fit: BoxFit.cover,
      ),
    ),

    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ),

    SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 40 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Column(
                          children: [
                            const Icon(
                              Icons.apartment,
                              size: 70,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isArabic ? 'مرحباً بك' : 'Welcome',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isArabic
                                  ? 'اختر نوع الحساب'
                                  : 'Choose account type',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return _LuxuryRoleCard(
                            title: item['title'] as String,
                            subtitle: item['subtitle'] as String,
                            icon: item['icon'] as IconData,
                            color: item['color'] as Color,
                            delay: index * 200,
                            onTap: () =>
                                _go(context, item['role'] as UserRole),
                          );
                        },
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  ],
),
    );
  }
}

/// ================= Luxury Card =================

class _LuxuryRoleCard extends StatelessWidget {

  const _LuxuryRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.delay,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value as double,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),

          // 🧊 Glass Effect
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),

              padding: const EdgeInsets.all(16),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(icon, size: 40, color: Colors.white),

                  const SizedBox(height: 10),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


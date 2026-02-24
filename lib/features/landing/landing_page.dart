// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:market_world/shared/widgets/app_app_bar.dart';
import '../../core/constants/enums.dart';
import '../../core/providers/language_provider.dart';
import '../auth/login_page.dart';

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

    final color =
        isNight ? Colors.indigo.shade300 : Colors.orange.shade700;

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
        'subtitle':
            isArabic ? 'ابحث واحجز زيارة' : 'Find & book a property',
        'icon': Icons.key_outlined,
        'role': UserRole.tenant,
        'color': Colors.orange,
      },
      {
        'title': isArabic ? 'مؤجّر' : 'Landlord',
        'subtitle':
            isArabic ? 'أضف وأدر عقاراتك' : 'Add & manage properties',
        'icon': Icons.home_work_outlined,
        'role': UserRole.landlord,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: const AppAppBar(
        title: 'World Real Estate',
        showBack: false,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://res.cloudinary.com/dmklduciw/image/upload/v1768933674/tenant2_k8lf0e.webp',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white70,
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// Header
            Column(
          children: [
            Hero(
              tag: 'auth-hero',
              child: Icon(
            Icons.apartment,
            size: 72,
            color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isArabic ? 'مرحباً بك' : 'Welcome',
              style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            buildDateTime(context, isArabic),

            const SizedBox(height: 8),

            Text(
              isArabic
              ? 'اختر نوع الحساب'
              : 'Choose account type',
              style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
              ),
            ),
          ],
            ),

            const SizedBox(height: 40),

            /// Grid
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 40,
              childAspectRatio: 0.9,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _RoleCard(
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
            onTap: () =>
                _go(context, item['role'] as UserRole),
              );
            },
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

/// ================= Role Card =================

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              Color.lerp(color, Colors.black, 0.25)!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

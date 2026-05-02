import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/pages/bookings_page.dart';
import 'package:market_world/features/realestate/services/booking_service.dart';

class TenantDashboardPage extends StatelessWidget {
  const TenantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('يجب تسجيل الدخول'));
    }

    final bookingService = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: bookingService.getTenantBookingStats(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              children: [
                _StatCard(
                  title: 'كل الحجوزات',
                  value: stats['total'].toString(),
                  icon: Icons.event_note,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'قيد الانتظار',
                  value: stats['pending'].toString(),
                  icon: Icons.hourglass_bottom,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'مؤكدة',
                  value: stats['confirmed'].toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'مكتملة',
                  value: stats['completed'].toString(),
                  icon: Icons.verified_outlined,
                  color: Colors.teal,
                ),
                _StatCard(
                  title: 'ملغاة',
                  value: stats['cancelled'].toString(),
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                ),
                _ActionCard(
                  title: 'حجوزاتي',
                  icon: Icons.list_alt_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

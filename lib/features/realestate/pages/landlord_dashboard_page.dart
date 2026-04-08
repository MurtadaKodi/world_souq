// ignore_for_file: deprecated_member_use, unused_local_variable
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/pages/property_form_page.dart';
import 'package:market_world/features/realestate/services/booking_service.dart';
import 'package:market_world/features/realestate/services/property_storage_service.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

class LandlordDashboardPage extends StatelessWidget {
  const LandlordDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يجب تسجيل الدخول')),
      );
    }

    final bookingService = BookingService();
    final propertyService = PropertyStorageService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('إضافة عقار'),
        onPressed: () {
          Navigator.push(
            context,
            // ignore: prefer_const_constructors
            MaterialPageRoute(builder: (_) => PropertyFormPage()),
          );
        },
      ),
      body: StreamBuilder<DashboardData>(
        stream: _dashboardStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          final data = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _DashboardHeader(),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _StatCard('عقاراتي', data.propertiesCount, Icons.home,
                        Colors.indigo),
                    _StatCard('الحجوزات', data.totalBookings, Icons.event,
                        Colors.blue),
                    _StatCard('قيد الانتظار', data.pending,
                        Icons.hourglass_bottom, Colors.orange),
                    _StatCard(
                        'مكتملة', data.completed, Icons.verified, Colors.teal),
                    _StatCard('المفضلات', data.favorites, Icons.favorite,
                        Colors.pink),
                  ]),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _RevenueCard(totalBookings: data.totalBookings),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(child: _QuickActions()),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _TopFavorites(uid: uid),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 🎨 1️⃣ Header احترافي
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.indigo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'مرحباً ${user?.email ?? ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 📊 2️⃣ Stat Card Widget
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// 📊 3️⃣ Grid الإحصائيات
// ignore: unused_element
class _StatsGrid extends StatelessWidget {
  final int propertiesCount;
  final Map<String, int> stats;
  final int favoritesCount;

  const _StatsGrid({
    required this.propertiesCount,
    required this.stats,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _StatCard('عقاراتي', propertiesCount, Icons.home, Colors.indigo),
        _StatCard('الحجوزات', stats['total'] ?? 0, Icons.event, Colors.blue),
        _StatCard('قيد الانتظار', stats['pending'] ?? 0, Icons.hourglass_bottom,
            Colors.orange),
        _StatCard(
            'مكتملة', stats['completed'] ?? 0, Icons.verified, Colors.teal),
        _StatCard('المفضلات', favoritesCount, Icons.favorite, Colors.pink),
      ],
    );
  }
}

Stream<DashboardData> _dashboardStream(String uid) {
  final propertyService = PropertyStorageService();
  final bookingService = BookingService();

  final propertiesStream = propertyService.streamMyPropertiesCount(uid);

  final bookingStream = bookingService.streamOwnerBookingStats();

  final favoritesStream = propertyService.streamFavoritesOnMyProperties(uid);

  return StreamZip([
    propertiesStream,
    bookingStream,
    favoritesStream,
  ]).map((values) {
    final propertiesCount = values[0] as int;
    final stats = values[1] as Map<String, int>;
    final favorites = values[2] as int;

    return DashboardData(
      propertiesCount: propertiesCount,
      totalBookings: stats['total'] ?? 0,
      pending: stats['pending'] ?? 0,
      completed: stats['completed'] ?? 0,
      favorites: favorites,
    );
  });
}

class DashboardData {
  final int propertiesCount;
  final int totalBookings;
  final int pending;
  final int completed;
  final int favorites;

  DashboardData({
    required this.propertiesCount,
    required this.totalBookings,
    required this.pending,
    required this.completed,
    required this.favorites,
  });
}

// 💰 3️⃣ بطاقة الأرباح
class _RevenueCard extends StatelessWidget {
  final int totalBookings;

  const _RevenueCard({required this.totalBookings});

  @override
  Widget build(BuildContext context) {
    final revenue = totalBookings * 500; // مثال مؤقت

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, size: 40, color: Colors.green),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إجمالي الأرباح'),
              Text(
                '$revenue ر.ق',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ⚡️ 6️⃣ إجراءات سريعة ⚡ 4️⃣ Quick Actions
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.home_work),
            label: const Text('عقاراتي'),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: const Text('الحجوزات'),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

// 🏆 5️⃣ أفضل العقارات
class _TopFavorites extends StatelessWidget {
  final String uid;

  const _TopFavorites({required this.uid});

  @override
  Widget build(BuildContext context) {
    final propertyService = PropertyStorageService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 أكثر العقارات حفظاً',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: StreamBuilder<List<PropertyModel>>(
            stream: propertyService.streamTopFavoriteProperties(uid),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final properties = snap.data!;
              if (properties.isEmpty) {
                return const Center(child: Text('لا توجد مفضلات بعد'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final p = properties[index];

                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(
                          p.imageUrls.isNotEmpty
                              ? p.imageUrls.first
                              : 'https://via.placeholder.com/300',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${p.price} ر.ق',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

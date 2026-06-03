// ignore_for_file: inference_failure_on_instance_creation, deprecated_member_use, unused_local_variable
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_world/features/entry/entry_gate_page.dart';
import 'package:market_world/features/realestate/models/booking_model.dart';
import 'package:market_world/features/realestate/pages/owner_bookings_page.dart';
import 'package:market_world/features/realestate/pages/owner_properties_page.dart';
import 'package:market_world/features/realestate/pages/property_form_page.dart';
import 'package:market_world/features/realestate/services/booking_service.dart';
import 'package:market_world/features/realestate/services/property_storage_service.dart';
import 'package:market_world/features/storage/firebase_storage_service.dart';

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
    final PropertyStorageService _storageService = PropertyStorageService();
    final bookingService = BookingService();
    final propertyService = PropertyStorageService();
    final storage = FirebaseStorageService();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('إضافة عقار'),
        onPressed: () {
          Navigator.push(
            context,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerPropertiesPage(),
                          ),
                        );
                      },
                      child: _StatCard(
                        'عقاراتي',
                        data.propertiesCount,
                        Icons.home,
                        Colors.indigo,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerBookingsPage(),
                          ),
                        );
                      },
                      child: _StatCard(
                        'الحجوزات',
                        data.totalBookings,
                        Icons.event,
                        Colors.blue,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerBookingsPage(
                                statusFilter: 'pending', title: 'الحجوزات قيد الانتظار'),
                          ),
                        );
                      },
                      child: _StatCard(
                        'قيد الانتظار',
                        data.pending,
                        Icons.hourglass_bottom,
                        Colors.orange,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerBookingsPage(
                                statusFilter: 'completed', title: 'الحجوزات المكتملة'),
                          ),
                        );
                      },
                      child: _StatCard(
                        'مكتملة',
                        data.completed,
                        Icons.verified,
                        Colors.teal,
                      ),
                    ),
                    // ==================================================
                    // TopFavoritePropertiesPage '🏆 أكثر العقارات حفظاً'
                    // ==================================================

                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const TopFavoritePropertiesPage(),
                    //       ),
                    //     );
                    //   },
                    //   child: _StatCard(
                    //     'المفضلات',
                    //     data.favorites,
                    //     Icons.favorite,
                    //     Colors.pink,
                    //   ),
                    // ),
                  ]),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),
              // SliverPadding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   sliver: SliverToBoxAdapter(
              //     child: _RevenueCard(totalBookings: data.totalBookings),
              //   ),
              // ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(child: _QuickActions()),
              ),
              // SliverPadding(
              //   padding: const EdgeInsets.all(16),
              //   sliver: SliverToBoxAdapter(
              //     child: _TopFavorites(uid: uid),
              //   ),
              // ),
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
      child: Stack(
        children: [
          Row(
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
          Positioned(
            top: 8,
            right: 20,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EntryGatePage(),
                  ),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 28,
                ),
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
  const _StatCard(this.label, this.value, this.icon, this.color);
  final String label;
  final int value;
  final IconData icon;
  final Color color;

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
  const _StatsGrid({
    required this.propertiesCount,
    required this.stats,
    required this.favoritesCount,
  });
  final int propertiesCount;
  final Map<String, int> stats;
  final int favoritesCount;

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
        _StatCard(
          'قيد الانتظار',
          stats['pending'] ?? 0,
          Icons.hourglass_bottom,
          Colors.orange,
        ),
        _StatCard(
          'مكتملة',
          stats['completed'] ?? 0,
          Icons.verified,
          Colors.teal,
        ),
        _StatCard('المفضلات', favoritesCount, Icons.favorite, Colors.pink),
      ],
    );
  }
}

Stream<DashboardData> _dashboardStream(String uid) {
  final propertyService = PropertyStorageService();
  final bookingService = BookingService();

  final controller = StreamController<DashboardData>();

  int propertiesCount = 0;
  int favorites = 0;
  List<BookingModel> bookings = [];

  void emit() {
    controller.add(
      DashboardData(
        propertiesCount: propertiesCount,
        totalBookings: bookings.length,
        pending: bookings.where((b) => b.status == 'pending').length,
        completed: bookings.where((b) => b.status == 'completed').length,
        // favorites: favorites,
      ),
    );
  }

  final sub1 = propertyService.streamMyPropertiesCount(uid).listen((v) {
    propertiesCount = v;
    emit();
  });

  final sub2 = propertyService.streamTotalFavoritesForOwner(uid).listen((v) {
    favorites = v;

    emit();
  });

  final sub3 = bookingService.streamOwnerBookings().listen((v) {
    bookings = v;
    emit();
  });

  controller.onCancel = () {
    sub1.cancel();
    sub2.cancel();
    sub3.cancel();
  };

  return controller.stream;
}

class DashboardData {
  DashboardData({
    required this.propertiesCount,
    required this.totalBookings,
    required this.pending,
    required this.completed,
    // required this.favorites,
  });
  final int propertiesCount;
  final int totalBookings;
  final int pending;
  final int completed;
  // final int favorites;
}

// 💰 3️⃣ بطاقة الأرباح
// class _RevenueCard extends StatelessWidget {
//   const _RevenueCard({required this.totalBookings});
//   final int totalBookings;

//   @override
//   Widget build(BuildContext context) {
//     final revenue = totalBookings * 500; // مثال مؤقت

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.attach_money, size: 40, color: Colors.green),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('إجمالي الأرباح'),
//               Text(
//                 '$revenue ر.ق',
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OwnerPropertiesPage(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: const Text('الحجوزات'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OwnerBookingsPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 🏆 5️⃣ أفضل العقارات
// class _TopFavorites extends StatelessWidget {
//   const _TopFavorites({required this.uid});
//   final String uid;

//   @override
//   Widget build(BuildContext context) {
//     final propertyService = PropertyStorageService();
//     final storage = FirebaseStorageService();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           '🏆 أكثر العقارات حفظاً',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 200,
//           child: StreamBuilder<List<PropertyModel>>(
//             stream: propertyService.streamTopFavoriteProperties(uid),
//             builder: (context, snap) {
//               if (!snap.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final properties = snap.data!;
//               if (properties.isEmpty) {
//                 return const Center(child: Text('لا توجد مفضلات بعد'));
//               }

//               return ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: properties.length,
//                 itemBuilder: (context, index) {
//                   final p = properties[index];

//                   return Container(
//                     width: 220,
//                     margin: const EdgeInsets.only(right: 12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Stack(
//                         children: [
//                           // 🖼️ الصورة
//                           Positioned.fill(
//                             child: p.mediaPaths.isNotEmpty
//                                 ? Image.network(
//                                     p.mediaPaths.first,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => _placeholder(),
//                                     loadingBuilder: (_, child, progress) {
//                                       if (progress == null) {
//                                         return child;
//                                       }

//                                       return _placeholder();
//                                     },
//                                   )
//                                 : _placeholder(),
//                           ),

//                           // 🌑 overlay
//                           Positioned.fill(
//                             child: Container(
//                               color: Colors.black.withOpacity(0.4),
//                             ),
//                           ),

//                           // 📄 النص
//                           Positioned(
//                             left: 12,
//                             right: 12,
//                             bottom: 12,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   p.title,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${p.price} ر.ق',
//                                   style: const TextStyle(color: Colors.white70),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _placeholder() {
//     return Container(
//       color: Colors.grey[300],
//       child: const Center(
//         child: Icon(Icons.image, size: 40, color: Colors.grey),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/features/realestate/pages/booking_details_page.dart';
import 'package:market_world/features/realestate/pages/bookings_page.dart';
import 'package:market_world/features/realestate/pages/my_properties_page.dart';
import 'package:market_world/features/realestate/pages/owner_bookings_page.dart';
import 'package:market_world/features/realestate/pages/properties_page.dart';
import 'package:market_world/features/realestate/services/favorites_service.dart';
import 'package:market_world/features/shared_pages/profile_page.dart';
import 'package:market_world/features/realestate/pages/landlord_dashboard_page.dart';
// import 'package:market_world/features/realestate/pages/booking_details_page.dart';
import 'package:market_world/features/realestate/pages/favorites_page.dart';

class MainBottomNav extends StatefulWidget {
  final UserRole role;

  /// ⭐ مهم للإشعارات
  final int initialIndex;
  final String? openBookingId;

  const MainBottomNav({
    super.key,
    required this.role,
    this.initialIndex = 0,
    this.openBookingId,
  });

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  late int index;
  bool _openedFromNotification = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;

    if (widget.openBookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_openedFromNotification) return;
        _openedFromNotification = true;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => BookingDetailsPage(
            bookingId: widget.openBookingId!,
            isLandlord: widget.role == UserRole.landlord,
          ),
        );
      });
    }
  }

  List<Widget> get pages {
    if (widget.role == UserRole.tenant) {
      return [
        const PropertiesPage(), // بحث
        const BookingsPage(), // حجوزاتي
        const ProfilePage(isLandlord: false),
        FavoritesPage(), // المفضلة
      ];
    } else if (widget.role == UserRole.landlord) {
      return const [
        LandlordDashboardPage(), // لوحة التحكم
        MyPropertiesPage(),
        OwnerBookingsPage(),
        ProfilePage(isLandlord: true),
      ];
    } else {
      return const [
        MyPropertiesPage(),
        OwnerBookingsPage(),
        ProfilePage(isLandlord: false),
      ];
    }
  }

  List<BottomNavigationBarItem> get items {
    if (widget.role == UserRole.tenant) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'حجوزاتي'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
      ];
    } else if (widget.role == UserRole.landlord) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'لوحة التحكم',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work_outlined),
          label: 'عقاراتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_available),
          label: 'الحجوزات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'الحساب',
        ),
      ];
    } else {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'عقاراتي',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event_available),
          label: 'الحجوزات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الحساب',
        ),
        BottomNavigationBarItem(
          icon: StreamBuilder<int>(
            stream: _favoritesService.favoritesCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.favorite),
                  if (count > 0)
                    Positioned(
                      right: -6,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          label: 'المفضلة',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: items,
      ),
    );
  }
}

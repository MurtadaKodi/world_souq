import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/pages/booking_details_page.dart';
import 'package:market_world/features/realestate/pages/landlord_dashboard_page.dart';
import '../pages/owner_bookings_page.dart';
import '../../shared_pages/profile_page.dart';

class LandlordBottomNav extends StatefulWidget {
  final int initialIndex;
  final String? openBookingId;

  const LandlordBottomNav({
    super.key,
    this.initialIndex = 0,
    this.openBookingId,
  });

  @override
  State<LandlordBottomNav> createState() => _LandlordBottomNavState();
}

class _LandlordBottomNavState extends State<LandlordBottomNav> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    // ⭐ فتح صفحة تفاصيل الحجز تلقائيًا
    if (widget.openBookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
       if (widget.openBookingId != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BookingDetailsPage(
        bookingId: widget.openBookingId!,
        isLandlord: true,
      ),
    );
  });
}
      });
    }
  }

  List<Widget> get _pages => const [
        LandlordDashboardPage(),
        OwnerBookingsPage(),
        ProfilePage(isLandlord: true),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}
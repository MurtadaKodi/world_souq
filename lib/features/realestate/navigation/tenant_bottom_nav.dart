import 'package:flutter/material.dart';
import '../pages/properties_list_page.dart';
import '../pages/bookings_page.dart';
import '../pages/property_map_page.dart';
import '../../shared_pages/profile_page.dart';
import '../pages/booking_details_page.dart';

class TenantBottomNav extends StatefulWidget {
  final int initialIndex;
  final String? openBookingId;
  final String? focusPropertyId; // ✅ جديد

  const TenantBottomNav({
    super.key,
    this.initialIndex = 0,
    this.openBookingId,
    this.focusPropertyId,
  });


  @override
  State<TenantBottomNav> createState() => _TenantBottomNavState();
}

class _TenantBottomNavState extends State<TenantBottomNav> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    // ⭐ فتح تفاصيل الحجز مباشرة إذا وُجد
    if (widget.openBookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsPage(
              bookingId: widget.openBookingId!,
              isLandlord: false,
            ),
          ),
        );
      });
    }
  }

  List<Widget> get _pages => [
  PropertiesMapPage(
    focusPropertyId: widget.focusPropertyId, // ✅ تمرير التركيز
  ),
  const PropertiesListPage(),
  const BookingsPage(),
  const ProfilePage(isLandlord: false),
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
            icon: Icon(Icons.map_outlined),
            label: 'الخريطة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'القائمة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}
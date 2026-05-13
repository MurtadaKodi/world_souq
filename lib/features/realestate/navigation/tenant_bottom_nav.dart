// ignore_for_file: inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/features/realestate/pages/booking_details_page.dart';
import 'package:market_world/features/realestate/pages/bookings_page.dart';
import 'package:market_world/features/realestate/pages/properties_list_page.dart';
import 'package:market_world/features/realestate/pages/properties_map_page.dart';
import 'package:market_world/features/shared_pages/profile_page.dart';

class TenantBottomNav extends StatefulWidget { // ✅ جديد

  const TenantBottomNav({
    super.key,
    this.initialIndex = 0,
    this.openBookingId,
    this.focusPropertyId,
  });
  final int initialIndex;
  final String? openBookingId;
  final String? focusPropertyId;

  @override
  State<TenantBottomNav> createState() => _TenantBottomNavState();
}

class _TenantBottomNavState extends State<TenantBottomNav> {
  late int _index;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex;

    _pages = [
  PropertiesMapPage(
    focusPropertyId: widget.focusPropertyId,
    role: UserRole.tenant,
    initialIndex: 0,
  ),
  const PropertiesListPage(),
  const BookingsPage(),
  const ProfilePage(isLandlord: false),
];

    // فتح تفاصيل الحجز
    if (widget.openBookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => BookingDetailsPage(
            bookingId: widget.openBookingId!,
            isLandlord: false,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            label: isArabic ? 'الخريطة' : 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: isArabic ? 'القائمة' : 'List',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_note),
            label: isArabic ? 'حجوزاتي' : 'My Bookings',
          ),  
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: isArabic ? 'الحساب' : 'Account',
          ),
        ],
      ),
    );
  }
}

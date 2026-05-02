// ignore_for_file: inference_failure_on_instance_creation

import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/booking_model.dart';
import 'package:market_world/features/realestate/navigation/tenant_bottom_nav.dart';
import 'package:market_world/features/realestate/services/booking_service.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key, this.isLandlord = false});
  final bool isLandlord;

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: Localizations.localeOf(context).languageCode == 'ar'
            ? const Text('حجوزاتي')
            : const Text('My Bookings'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: service.streamMyBookings(),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ: ${snapshot.error}'),
            );
          }

          final bookings = snapshot.data ?? [];

          // 📭 Empty
          if (bookings.isEmpty) {
            return const Center(
              child: Text('لا توجد حجوزات حالياً'),
            );
          }

          // ✅ List
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final item = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(item.propertyName),
                  subtitle: Text(
                    '${item.clientName} • ${item.visitDate.toLocal()}',
                  ),

                  // 🔥 فتح الموقع على الخريطة
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TenantBottomNav(
                          focusPropertyId: item.propertyId,
                        ),
                      ),
                      (route) => false,
                    );
                  },

                  // ❌ حذف الحجز
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await service.deleteBooking(item.id);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف الحجز'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'property_map_page.dart';

class BookingsPage extends StatelessWidget {
  final bool? isLandlord;

  const BookingsPage({super.key, this.isLandlord = true});

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: StreamBuilder<List<BookingModel>>(
        stream: service.streamMyBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات'));
          }

          final items = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final b = items[i];
              return Card(
                child: ListTile(
                  title: Text(b.propertyName),
                  subtitle: Text(
                    '${b.visitDate.day}/${b.visitDate.month} • ${b.visitTime}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertiesMapPage(
                          focusPropertyId: b.propertyId,
                          focusDate: b.visitDate,
                          focusTime: b.visitTime,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

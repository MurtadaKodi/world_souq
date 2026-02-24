import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزات عقاراتي')),
      body: StreamBuilder<List<BookingModel>>(
        stream: service.streamOwnerBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل الحجوزات'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final b = items[i];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.propertyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('العميل: ${b.clientName} • ${b.clientPhone}'),
                      const SizedBox(height: 6),
                      Text('الموعد: ${b.visitTime} • ${b.visitDate.day}/${b.visitDate.month}/${b.visitDate.year}'),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: b.status == 'confirmed'
                                ? null
                                : () => service.confirmBooking(b.id),
                            child: const Text('تأكيد'),
                          ),
                          OutlinedButton(
                            onPressed: b.status == 'cancelled'
                                ? null
                                : () => service.cancelBooking(b.id),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: b.status == 'completed'
                                ? null
                                : () => service.completeBooking(b.id),
                            child: const Text('إكمال'),
                          ),
                        ],
                      ),
                    ],
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

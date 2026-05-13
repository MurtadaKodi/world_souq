import 'package:flutter/material.dart';
import 'package:market_world/features/realestate/models/booking_model.dart';
import 'package:market_world/features/realestate/services/booking_service.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return Colors.blue;
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({
    super.key,
    this.statusFilter,
    this.title,
  });

  final String? statusFilter;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'حجوزات عقاراتي'),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: service.streamOwnerBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل الحجوزات'));
          }

          final allItems = snapshot.data ?? [];

          final items = statusFilter == null
              ? allItems
              : allItems.where((b) => b.status == statusFilter).toList();
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
                  side: BorderSide(color: getStatusColor(b.status)),
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
                      Text(
                          'الموعد: ${b.visitTime} • ${b.visitDate.day}/${b.visitDate.month}/${b.visitDate.year}'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          /// ✅ تأكيد
                          OutlinedButton(
                            onPressed: b.status == 'pending'
                                ? () async {
                                    await service.confirmBooking(b.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
                                    );
                                  }
                                : null,
                            child: const Text('تأكيد'),
                          ),

                          /// ❌ إلغاء
                          OutlinedButton(
                            onPressed: (b.status == 'pending' || b.status == 'confirmed')
                                ? () async {
                                    await service.cancelBooking(b.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
                                    );
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('إلغاء'),
                          ),

                          /// 🎉 إكمال
                          ElevatedButton(
                            onPressed: b.status == 'confirmed'
                                ? () async {
                                    await service.completeBooking(b.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('إكمال'),
                          ),
                        ],
                      )
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

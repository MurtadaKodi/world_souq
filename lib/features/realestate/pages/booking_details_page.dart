import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;
  final bool isLandlord;

 const BookingDetailsPage({
    super.key,
    required this.bookingId,
    required this.isLandlord,
  });

  @override
  Widget build(BuildContext context) {
    final service = BookingService();

    return FutureBuilder<BookingModel>(
      future: service.getBookingById(bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
if (snapshot.hasError) {
  return const Scaffold(
    body: Center(child: Text('حدث خطأ أثناء تحميل الحجز')),
  );
}

        final booking = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل الحجز'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile(
                  title: 'العقار',
                  value: booking.propertyName,
                  icon: Icons.home_work_outlined,
                ),
                _infoTile(
                  title: 'التاريخ',
                  value: _formatDate(booking.visitDate),
                  icon: Icons.calendar_today,
                ),
                _infoTile(
                  title: 'الوقت',
                  value: booking.visitTime,
                  icon: Icons.schedule,
                ),
                _infoTile(
                  title: 'الحالة',
                  value: booking.statusText,
                  icon: Icons.info_outline,
                  valueColor: _statusColor(booking.status),
                ),

                const Divider(height: 32),

                if (isLandlord) ...[
                  const Text(
                    'بيانات المستأجر',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoTile(
                    title: 'الاسم',
                    value: booking.clientName,
                    icon: Icons.person_outline,
                  ),
                  _infoTile(
                    title: 'الهاتف',
                    value: booking.clientPhone,
                    icon: Icons.phone_outlined,
                  ),
                ],

                const Spacer(),

                if (isLandlord)
                  _landlordActions(context, service, booking),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= ACTIONS =================

  Widget _landlordActions(
    BuildContext context,
    BookingService service,
    BookingModel booking,
  ) {
    return Column(
      children: [
        if (booking.isPending)
          FilledButton(
            onPressed: () async {
              await service.confirmBooking(booking.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('تأكيد الحجز'),
          ),

        if (booking.isConfirmed) ...[
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              await service.completeBooking(booking.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('إتمام الزيارة'),
          ),
        ],

        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final ok = await _confirmCancel(context);
            if (!ok) return;

            await service.cancelBooking(booking.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('إلغاء الحجز'),
        ),
      ],
    );
  }

  // ================= UI HELPERS =================

  static Widget _infoTile({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  static Future<bool> _confirmCancel(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('تأكيد الإلغاء'),
            content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('تراجع'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('نعم، إلغاء'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

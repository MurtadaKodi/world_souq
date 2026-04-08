// lib/features/realestate/widgets/booking_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/property_model.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';



class BookingDialog extends StatefulWidget {
  final PropertyModel property;

  const BookingDialog({
    super.key,
    required this.property,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final bookingService = BookingService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حجز زيارة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 👤 الاسم
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 8),

            // 📞 الهاتف
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // 📅 التاريخ
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                selectedDate == null
                    ? 'اختر التاريخ'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (d != null) setState(() => selectedDate = d);
              },
            ),

            // ⏰ الوقت
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(
                selectedTime == null
                    ? 'اختر الوقت'
                    : selectedTime!.format(context),
              ),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) setState(() => selectedTime = t);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('تأكيد الحجز'),
        ),
      ],
    );
  }
  bool _loading = false;


  bool get _canSubmit =>
      _nameCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty &&
      selectedDate != null &&
      selectedTime != null;
      

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

  final booking = BookingModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  propertyId: widget.property.id,
  propertyName: widget.property.title,
  ownerId: widget.property.ownerId,
  clientName: _nameCtrl.text.trim(),
  clientPhone: _phoneCtrl.text.trim(),
  visitDate: selectedDate!,
  visitTime: selectedTime!.format(context),
);


  if (_loading) return;
setState(() => _loading = true);

await bookingService.createBooking(booking);

if (!mounted) return;
setState(() => _loading = false);


    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال طلب الحجز بنجاح')),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_world/core/services/local_notification_service.dart';
import 'package:market_world/features/entry/entry_gate_page.dart';
import 'package:market_world/features/realestate/models/booking_model.dart';
import 'package:market_world/features/realestate/models/property_model.dart';
import 'package:market_world/features/realestate/services/booking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDialog extends StatefulWidget {
  const BookingDialog({
    required this.propertyId,
    required this.propertyName,
    required this.ownerId,
    super.key, required PropertyModel property,
  });
  final String propertyId;
  final String propertyName;
  final String ownerId;

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime selectedDate = DateTime.now();

  bool _isPastTime(String time) {
    // ignore: unnecessary_null_comparison
    if (selectedDate == null) return false;

    final now = DateTime.now();

    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) return false;

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final slotTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    return slotTime.isBefore(now);
  }

  String? selectedTime;
  final List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  List<String> bookedTimes = [];
  final service = BookingService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedPhone();
    _loadUserData();
    _loadBookings(); // 🔥 مهم
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone');

    if (phone != null) {
      _phoneCtrl.text = phone;
    }
  }

  Future<void> _loadBookings() async {
    service
        .streamPropertyBookingsForDate(widget.propertyId, selectedDate)
        .listen((list) {
      setState(() {
        bookedTimes = list.map((e) => e.visitTime).toList();
      });
    });
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = doc.data();

    if (data != null) {
      _nameCtrl.text = (data['name'] as String?) ?? '';
      _phoneCtrl.text = (data['phone'] as String?) ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'اختر موعد الزيارة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              /// 📅 التاريخ
              ListTile(
                title: Text(
                  '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                      selectedTime = null;
                    });
                    _loadBookings();
                  }
                },
              ),

              const SizedBox(height: 12),

              /// ⏰ الأوقات
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time) {
                  final isBooked = bookedTimes.contains(time);
                  final isPast = _isPastTime(time);
                  final isSelected = selectedTime == time;

                  return GestureDetector(
                    onTap: (isBooked || isPast)
                        ? null
                        : () {
                            setState(() => selectedTime = time);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                              )
                            : null,
                        color: isPast ? Colors.grey : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBooked
                              ? const Color.fromARGB(255, 224, 119, 119)
                              : isPast
                                  ? Colors.grey
                                  : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Legend(color: Colors.blue, text: 'مختار'),
                  _Legend(color: Colors.red, text: 'محجوز'),
                  _Legend(color: Colors.white, text: 'متاح'),
                ],
              ),

              const SizedBox(height: 20),

              /// ✅ زر تأكيد
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: selectedTime == null
                    ? null
                    : () async {
                        if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
                          await _showError('الرجاء إدخال الاسم ورقم الهاتف');
                          return;
                        }

                        if (_phoneCtrl.text.length < 8) {
                          await _showError('رقم الهاتف غير صحيح');
                          return;
                        }

                        try {
                          await service.createBooking(
                            BookingModel(
                              id: '',
                              propertyId: widget.propertyId,
                              propertyName: widget.propertyName,
                              ownerId: widget.ownerId,
                              clientName: _nameCtrl.text,
                              clientPhone: _phoneCtrl.text,
                              visitDate: selectedDate,
                              visitTime: selectedTime!,
                            ),
                          );

                          // 🔔 Notification
                          await LocalNotificationService.showBookingSuccess();

                          // 💾 حفظ رقم الهاتف
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('user_phone', _phoneCtrl.text);

                          if (!context.mounted) return;

                          Navigator.pop(context);

                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );

                          if (!mounted) return;

                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('تم الحجز بنجاح 🎉'),
                              content: const Text(
                                  'تم تسجيل الحجز بنجاح، سيتم التواصل معك قريباً',),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('متابعة التصفح'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();

                                    Navigator.of(
                                      dialogContext,
                                      rootNavigator: true,
                                    ).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const EntryGatePage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('الرجوع للبداية'),
                                ),
                              ],
                            ),
                          );

                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ تم الحجز')),
                          );
                        } catch (e) {
                          await showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('تنبيه'),
                              content: Text(e.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('حسناً'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                child: const Text('تأكيد الحجز'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تنبيه'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

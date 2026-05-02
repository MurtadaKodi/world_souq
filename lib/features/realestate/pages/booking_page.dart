// import 'package:flutter/material.dart';
// import 'package:market_world/features/realestate/models/booking_model.dart';
// import '../models/property_model.dart';
// import '../services/booking_service.dart';

// class BookingPage extends StatefulWidget {
//   final PropertyModel property;

//   const BookingPage({super.key, required this.property});

//   @override
//   State<BookingPage> createState() => _BookingPageState();
// }

// class _BookingPageState extends State<BookingPage> {
//   DateTime? selectedDate;
//   String? selectedTime;

//   final List<String> times = [
//     '10:00 AM',
//     '12:00 PM',
//     '02:00 PM',
//     '04:00 PM',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('حجز موعد')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // 🏠 Property Info
//             Text(
//               widget.property.title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             Text(
//               '${widget.property.price} ${widget.property.currency}',
//               style: const TextStyle(color: Colors.grey),
//             ),

//             const SizedBox(height: 20),

//             // 📅 Date Picker
//             ElevatedButton(
//               onPressed: () async {
//                 final date = await showDatePicker(
//                   context: context,
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(2030),
//                 );

//                 if (date != null) {
//                   setState(() => selectedDate = date);
//                 }
//               },
//               child: Text(
//                 selectedDate == null
//                     ? 'اختر التاريخ'
//                     : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ⏰ Time Picker
//             Wrap(
//               spacing: 10,
//               children: times.map((time) {
//                 final isSelected = selectedTime == time;

//                 return ChoiceChip(
//                   label: Text(time),
//                   selected: isSelected,
//                   onSelected: (_) {
//                     setState(() => selectedTime = time);
//                   },
//                 );
//               }).toList(),
//             ),

//             const Spacer(),

//             // ✅ Confirm Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: (selectedDate != null && selectedTime != null)
//                     ? _confirmBooking
//                     : null,
//                 child: const Text('تأكيد الحجز'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =========================
//   // 🔥 Confirm Booking
//   // =========================

//  Future<void> _confirmBooking() async {
//   final booking = BookingModel(
//     id: DateTime.now().millisecondsSinceEpoch.toString(),
//     propertyId: widget.property.id,
//     propertyName: widget.property.title,
//     ownerId: widget.property.ownerId,
//     clientName: 'User', // أو اربطه بالمستخدم لاحقاً
//     clientPhone: 'N/A',
//     visitDate: selectedDate!,
//     visitTime: selectedTime!,
//   );

//   await BookingService().createBooking(booking);

//   if (!mounted) return;

//   Navigator.pop(context);

//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(
//       content: Text('تم تأكيد الحجز بنجاح ✅'),
//     ),
//   );
// }
// }
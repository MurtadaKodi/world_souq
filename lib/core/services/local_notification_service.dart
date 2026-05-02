import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
  settings: settings,
);
  }

  static Future<void> showBookingSuccess() async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Bookings',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 0,
      title: 'تم الحجز بنجاح 🎉',
      body: 'تم تأكيد موعد زيارتك للعقار',
      notificationDetails: details,
    );
  }
}

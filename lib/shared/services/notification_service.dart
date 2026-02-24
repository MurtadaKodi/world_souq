import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:market_world/core/constants/enums.dart';
import 'package:market_world/shared/navigation/main_bottom_nav.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

class NotificationService {
  static Future<void> init() async {
    // 🚫 لا نشغل الإشعارات على Web
    if (kIsWeb) return;

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      final initialMessage =
          await messaging.getInitialMessage();

      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp
          .listen(_handleMessage);

    } catch (e) {
      debugPrint(
          '⚠️ Messaging initialization failed: $e');
    }
  }

  // ================= HANDLER =================

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;

    final String? type = data['type'];
    final String? bookingId = data['bookingId'];

    if (type == null || bookingId == null) {
      debugPrint('🔴 Notification missing data');
      return;
    }

    late UserRole role;
    late int tabIndex;

    switch (type) {
      case 'new_booking':
        role = UserRole.landlord;
        tabIndex = 2;
        break;

      case 'booking_confirmed':
        role = UserRole.tenant;
        tabIndex = 1;
        break;

      default:
        debugPrint(
            '⚠️ Unknown notification type: $type');
        return;
    }

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainBottomNav(
          role: role,
          initialIndex: tabIndex,
          openBookingId: bookingId,
        ),
      ),
      (route) => false,
    );
  }

  static Future<void> saveUserToken() async {
    // 🚫 لا نحفظ FCM على Web
    if (kIsWeb) return;

    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();

    if (token == null) return;

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}

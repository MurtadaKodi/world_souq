
// ignore_for_file: dead_code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:market_world/core/providers/auth_provider.dart' as app_auth;
import 'package:market_world/core/providers/language_provider.dart';
import 'package:market_world/core/services/local_notification_service.dart';
import 'package:market_world/core/theme/app_theme.dart';
import 'package:market_world/features/auth/auth_service.dart';
import 'package:market_world/features/entry/entry_gate_page.dart';
import 'package:market_world/features/splash/splash_screen.dart';
import 'package:market_world/firebase_options.dart';
import 'package:market_world/shared/services/notification_service.dart';
import 'package:provider/provider.dart';

/// 🔑 Global Navigator Key (للإشعارات)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.init();

  // =========================
  // 🔥 Firebase Init
  // =========================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// =========================
// 🔥 Firebase Emulator Setup
// =========================
const useEmulator = false;

if (useEmulator) {
  debugPrint('🔥 Firebase Emulator Connected');
} else {
  debugPrint('🚀 Running on Production Firebase');
}

  // =========================
  // 🔔 Notifications
  // =========================
  if (kIsWeb) {
    await NotificationService.init();
    await NotificationService.saveUserToken();
  }

  final authService = AuthService();
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(authService),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// =========================
// 🧱 APP
// =========================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,

          title: 'MarketWorld Real Estate',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),

          // 🌍 Localization
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ↔️ RTL / LTR
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.textDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },

          // 🧭 Routes
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/entry': (_) => const EntryGatePage(),
          },
        );
      },
    );
  }
}

Future<void> saveToken() async {
  if (kIsWeb) return;

  final token = await FirebaseMessaging.instance.getToken();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid != null && token != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'fcmToken': token,
      },
      SetOptions(merge: true),
    );
  }
}

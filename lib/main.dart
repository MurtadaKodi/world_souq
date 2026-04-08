import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'features/auth/auth_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/entry/entry_gate_page.dart';
import 'shared/services/notification_service.dart';

/// 🔑 Global Navigator Key (للإشعارات)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // 🔥 Firebase Init
  // =========================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// =========================
// 🔥 Firebase Emulator Setup
// =========================
const bool useEmulator = kDebugMode;

if (useEmulator) {
  String host = 'localhost';

  // Android Emulator fix
  if (!kIsWeb && Platform.isAndroid) {
    host = '10.0.2.2';
  }

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseStorage.instance.useStorageEmulator(host, 9199);

  debugPrint('🔥 Firebase Emulator Connected');
  debugPrint(useEmulator
    ? '🧪 Running on Emulator'
    : '🚀 Running on Production');
}

  // =========================
  // 🔔 Notifications
  // =========================
  if (kIsWeb) {
    await NotificationService.init();
    await NotificationService.saveUserToken();
  }

  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
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

          title: 'Marketplace',

          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,

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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
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

  // ✅ Firebase أولًا (مهم جدًا)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ تهيئة الإشعارات (آمنة الآن)
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

          // 🌍 اللغة
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

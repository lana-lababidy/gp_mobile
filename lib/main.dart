// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// مزوّداتك/الكنترولرز
import 'controllers/cases_controller.dart';

// الشاشات
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cases_list_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_screen.dart';

// الحارس
import 'widgets/exit_guard.dart';

// API/Dio
import 'api/dio_client.dart';
import 'api/auth_api.dart';

/// هندلر رسائل FCM بالخلفية (لازم تكون top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // لوج اختياري
  // debugPrint('🔔 (BG) ${message.messageId} | ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Firebase لمرة واحدة
  await Firebase.initializeApp();

  // ✅ تسجيل معالج الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ صلاحية الإشعارات (أندرويد 13+)
  await FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);

  // ✅ طباعة التوكين بالكونسول (انسخو وجرّب عليه من Firebase Console)
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM TOKEN => $fcmToken');

  // (اختياري) لوج بسيط أثناء عمل التطبيق
  FirebaseMessaging.onMessage.listen((m) {
    debugPrint('🔔 (FG) ${m.notification?.title} | ${m.notification?.body}');
  });
  FirebaseMessaging.onMessageOpenedApp.listen((m) {
    debugPrint('🔔 (TAP) opened app with data: ${m.data}');
    // لاحقاً إذا بدك تنقّل حسب data['case_id'] مثلاً
  });

  // استخدم نفس السيرفر الذي اختبرته على Postman
  const String kBaseUrl = 'https://abshir-api.justfortesting.ovh/api';
  // لو بدك خادم محلي لاحقاً:
  // const String kBaseUrl = 'http://10.0.2.2:8000/api';

  final dioClient = DioClient(baseUrl: kBaseUrl);

  runApp(
    MultiProvider(
      providers: [
        Provider<DioClient>.value(value: dioClient),
        Provider<AuthApi>(create: (_) => AuthApi(dioClient)),
        ChangeNotifierProvider(create: (_) => CasesController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cetrl',
        colorSchemeSeed: const Color(0xFF0A2A6C),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cetrl',
        colorSchemeSeed: const Color(0xFF0A2A6C),
        brightness: Brightness.dark,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),
      builder: (context, child) =>
          ExitGuard(child: child ?? const SizedBox.shrink()),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/cases': (context) => const CasesListScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          String phone = '';
          String? devOtp;

          final args = settings.arguments;
          if (args is String) {
            phone = args;
          } else if (args is Map) {
            phone = args['phone']?.toString() ?? '';
            devOtp = args['devOtp']?.toString();
          }

          return MaterialPageRoute(
            builder: (_) => OTPScreen(phone: phone, devOtp: devOtp),
          );
        }
        return null;
      },
    );
  }
}

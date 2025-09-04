import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// مزوّداتك/الكنترولرز
import 'controllers/cases_controller.dart';

// الشاشات
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cases_list_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_screen.dart'; // ⬅️ جديد

// الحارس (إن وجد)
import 'widgets/exit_guard.dart';

// API/Dio
import 'api/dio_client.dart';
import 'api/auth_api.dart';

void main() {
  // أثناء التطوير على محاكي أندرويد:
  const String kBaseUrl = 'http://10.0.2.2:8000/api';
  // مثال للإنتاج:
  // const String kBaseUrl = 'https://abshir-api.justfortesting.ovh/api';

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

      // ثيم
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

      // العربية
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),

      // لفّ الشاشات بحارس الخروج إن رغبت
      builder: (context, child) =>
          ExitGuard(child: child ?? const SizedBox.shrink()),

      // شاشة البداية
      home: const SplashScreen(),

      // مسارات ثابتة
      routes: {
        '/home': (context) => const HomeScreen(),
        '/cases': (context) => const CasesListScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/settings': (context) => const SettingsScreen(), // ⬅️ جديد
      },

      // مسارات ديناميكية
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          String phone = '';
          String? devOtp;

          final args = settings.arguments;
          if (args is String) {
            // دعم الأسلوب القديم: تمرير رقم فقط
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

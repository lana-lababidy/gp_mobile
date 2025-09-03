// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/cases_controller.dart';

// الشاشات
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cases_list_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/personal_info_screen.dart';

// الحارس وحوار التأكيد
import 'widgets/exit_guard.dart';

// ------- API (Dio) -------
import 'api/dio_client.dart';
import 'api/auth_api.dart';
import 'api/api_config.dart'; // ✅ مصدر الإعدادات الوحيد

void main() {
  // ✅ استخدم نفس الـ baseUrl الموحّد من ApiConfig
  final dioClient = DioClient(baseUrl: ApiConfig.baseUrl);

  runApp(
    MultiProvider(
      providers: [
        // مزوّدات الـ API
        Provider<DioClient>.value(value: dioClient),
        Provider<AuthApi>(create: (_) => AuthApi(dioClient)),

        // مزوّداتك الحالية
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

      // الثيم العام (فاتح + داكن)
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

      // دعم العربية وواجهة RTL
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: const Locale('ar'),

      // لفّ كل الشاشات بحارس الخروج
      builder: (context, child) => ExitGuard(
        child: child ?? const SizedBox.shrink(),
      ),

      // البداية: Splash
      home: const SplashScreen(),

      // مسارات ثابتة
      routes: {
        '/home': (context) => const HomeScreen(),
        '/cases': (context) => const CasesListScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
      },

      // مسار ديناميكي لتمرير رقم الهاتف إلى شاشة OTP
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final phone = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (_) => OTPScreen(phone: phone),
          );
        }
        return null;
      },
    );
  }
}

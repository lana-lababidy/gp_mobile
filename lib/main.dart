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

void main() {
  runApp(
    MultiProvider(
      providers: [
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

      // الثيم العام
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorSchemeSeed: const Color(0xFF0A2A6C),
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

      // ابدأ بـ SplashScreen
      home: const SplashScreen(),

      // مسارات التطبيق
      routes: {
        '/home': (context) => const HomeScreen(), // الرئيسية مع التبويبات
        '/cases': (context) =>
            const CasesListScreen(), // قائمة الحالات (مباشرة)
        '/phone': (context) => PhoneScreen(), // شاشة الهاتف
        '/otp': (context) => const OtpScreen(), // شاشة OTP
        '/personal-info': (context) =>
            const PersonalInfoPage(), // معلومات شخصية
      },
    );
  }
}

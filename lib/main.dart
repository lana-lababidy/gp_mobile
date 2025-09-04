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

// الحارس
import 'widgets/exit_guard.dart';

// API (Dio)
import 'api/dio_client.dart';
import 'api/auth_api.dart';

void main() {
  // ملاحظة: إذا بدك تختبر محلي على محاكي أندرويد استخدم 10.0.2.2
  // const String kBaseUrl = 'http://10.0.2.2:8000/api';

  // لتطابق Postman (الموصى به حالياً):
  const String kBaseUrl = 'https://abshir-api.justfortesting.ovh/api';

  // نجهّز DioClient مرة واحدة
  final dioClient = DioClient(baseUrl: kBaseUrl);

  runApp(
    MultiProvider(
      providers: [
        // مزوّدات الـ API
        Provider<DioClient>.value(value: dioClient),
        Provider<AuthApi>(create: (_) => AuthApi(dioClient)),

        // مزوّدات الحالة
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

      // الثيم
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

      // اللغة والـ RTL
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),

      // حارس الخروج
      builder: (context, child) => ExitGuard(
        child: child ?? const SizedBox.shrink(),
      ),

      // البداية
      home: const SplashScreen(),

      // مسارات ثابتة
      routes: {
        '/home': (_) => const HomeScreen(),
        '/cases': (_) => const CasesListScreen(),
        '/phone': (_) => const PhoneScreen(),
        '/personal-info': (_) => const PersonalInfoScreen(),
      },

      // مسار OTP مع تمرير رقم الهاتف
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          String phone = '';
          final args = settings.arguments;
          if (args is String) {
            phone = args;
          } else if (args is Map) {
            phone = args['phone']?.toString() ?? '';
          }
          return MaterialPageRoute(
            builder: (_) => OTPScreen(phone: phone),
          );
        }
        return null;
      },
    );
  }
}

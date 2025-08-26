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
import 'screens/api_test_screen.dart'; // ✅ شاشة الاختبار

// الحارس وحوار التأكيد
import 'widgets/exit_guard.dart';

// ------- API -------
import 'api/dio_client.dart';
import 'api/auth_api.dart';

void main() {
  // Base URL للمحاكي أندرويد (يفتح على localhost جهازك)
  const String kBaseUrl = 'http://10.0.2.2:8000/api';

  // نجهّز DioClient مرة وحدة للتطبيق كله
  final dioClient = DioClient(baseUrl: kBaseUrl);

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

      // لفّ كل الشاشات بحارس الخروج
      builder: (context, child) => ExitGuard(
        child: child ?? const SizedBox.shrink(),
      ),

      // ✅ مؤقتًا نبدأ باختبار API
      home: ApiTestScreen(),

      // مسارات التطبيق
      routes: {
        '/home': (context) => HomeScreen(), // الرئيسية مع التبويبات
        '/cases': (context) => CasesListScreen(), // قائمة الحالات
        '/phone': (context) => PhoneScreen(), // شاشة الهاتف
        '/otp': (context) => OtpScreen(), // شاشة OTP
        '/personal-info': (context) => PersonalInfoPage(), // معلومات شخصية
        '/apitest': (context) => ApiTestScreen(), // ✅ شاشة اختبار الاتصال
      },
    );
  }
}

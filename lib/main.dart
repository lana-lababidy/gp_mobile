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
import 'screens/otp_screen.dart'; // صف: OTPScreen (مع وسيط phone)
import 'screens/personal_info_screen.dart'; // صف: PersonalInfoScreen

// الحارس وحوار التأكيد
import 'widgets/exit_guard.dart';

// ------- API (Dio) -------
import 'api/dio_client.dart';
import 'api/auth_api.dart';

void main() {
  // ملاحظة: أثناء التطوير على محاكي أندرويد استخدم 10.0.2.2 بدل localhost.
  // وعند النشر استخدم عنوان خادمكم HTTPS.
  const String kBaseUrl = 'http://10.0.2.2:8000/api';
  // مثال للإنتاج:
  // const String kBaseUrl = 'https://abshir-api.justfortesting.ovh/api';

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
      // (اختياري) ثبّت العربية كلغة افتراضية
      locale: const Locale('ar'),

      // لفّ كل الشاشات بحارس الخروج
      builder: (context, child) => ExitGuard(
        child: child ?? const SizedBox.shrink(),
      ),

      // البداية: Splash (ومنها تنتقل لاحقًا للواجهات)
      home: const SplashScreen(),

      // مسارات التطبيق الثابتة (بدون باراميترات)
      routes: {
        '/home': (context) => const HomeScreen(), // الرئيسية
        '/cases': (context) => const CasesListScreen(), // قائمة الحالات
        '/phone': (context) => const PhoneScreen(), // شاشة الهاتف
        '/personal-info': (context) =>
            const PersonalInfoScreen(), // المعلومات الشخصية
        // ملاحظة: لا نضع '/otp' هنا لأن OTPScreen تحتاج phone كوسيط
      },

      // مسارات مولّدة ديناميكيًا (لدعم '/otp' مع تمرير رقم الهاتف)
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final phone = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (_) => OTPScreen(phoneNumber: phone),
          );
        }
        return null;
      },
    );
  }
}

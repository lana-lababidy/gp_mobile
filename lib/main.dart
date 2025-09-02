// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// الكنترولرز
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

      // دعم اللغة العربية
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SY'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ar', 'SY'),

      // الثيم العام
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        primarySwatch: Colors.blue,
      ),

      // الراوتات العادية
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/cases': (context) => const CasesListScreen(),
      },

      // الراوتات اللي بتاخد arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final phone = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (_) => OTPScreen(phoneNumber: phone), // ✅ التمرير الصح
          );
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/phone_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/cases_list_screen.dart'; // شاشة قائمة الحالات
import 'controllers/cases_controller.dart'; // الكنترولر

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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorSchemeSeed: const Color(0xFF0B57D0),
      ),

      // دعم العربية و الـ RTL (اختياري لكنه مفضل)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],

      initialRoute: '/',
      routes: {
        '/': (context) => PhoneScreen(),
        '/otp': (context) => OtpScreen(),
        '/personal-info': (context) => PersonalInfoPage(),
        '/cases': (context) => const CasesListScreen(), // قائمة الحالات
      },
    );
  }
}

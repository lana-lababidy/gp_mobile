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

// API
import 'api/dio_client.dart';
import 'api/auth_api.dart';

void main() {
  // للمطابقة مع Postman:
  const String kBaseUrl = 'https://abshir-api.justfortesting.ovh/api';
  // للمحاكي المحلي (عند الحاجة):
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
        '/home': (_) => const HomeScreen(),
        '/cases': (_) => const CasesListScreen(),
        '/phone': (_) => const PhoneScreen(),
        '/personal-info': (_) => const PersonalInfoScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          String phone = '';
          final args = settings.arguments;
          if (args is String) {
            phone = args;
          } else if (args is Map) {
            phone = args['phone']?.toString() ?? '';
          }
          return MaterialPageRoute(builder: (_) => OTPScreen(phone: phone));
        }
        return null;
      },
    );
  }
}

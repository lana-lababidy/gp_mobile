import 'package:flutter/material.dart';
import 'screens/phone_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/personal_info_screen.dart'; // تأكد إن الملف اسمه personal_info_screen.dart ويحوي PersonalInfoPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      initialRoute: '/',
      routes: {
        '/': (context) => PhoneScreen(),
        '/otp': (context) => OtpScreen(),
        '/personal-info': (context) => PersonalInfoPage(), // إزالة const هنا
      },
    );
  }
}

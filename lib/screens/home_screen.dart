import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // هون رح نعرض SnackBar أول ما يفتح HomeScreen
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تسجيل معلوماتك بنجاح 👌"),
          duration: Duration(seconds: 3),
          backgroundColor: Color(0xFF0A2A6C),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("الصفحة الرئيسية"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A2A6C),
      ),
      body: const Center(
        child: Text(
          "مرحباً بك في الصفحة الرئيسية 🎉",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

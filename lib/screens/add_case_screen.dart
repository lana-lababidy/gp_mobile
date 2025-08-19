// lib/screens/add_case_screen.dart
import 'package:flutter/material.dart';

class AddCaseScreen extends StatelessWidget {
  const AddCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Registration"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A2A6C),
      ),
      body: const Center(
        child: Text(
          "Start adding your case details here",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

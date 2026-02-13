import 'package:flutter/material.dart';

class VerificationInfoScreen extends StatelessWidget {
  const VerificationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التحقّق من الصحة'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'هون رح نعرض خطوات/مستندات التحقّق، أو شارة التحقق، أو روابط الجهات الموثّقة. '
            'منرجع نضبّطها بالتفصيل لاحقًا.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// lib/screens/otp_screen.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز التحقق')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.verifyOtp(
        mobileNumber: widget.phoneNumber,
        otp: otp,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التحقق بنجاح ✅')),
      );

      Navigator.pushReplacementNamed(context, '/personal-info');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'أدخل رمز التحقق المرسل إلى ${widget.phoneNumber}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'أدخل الرمز',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('تحقق'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

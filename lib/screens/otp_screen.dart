// lib/screens/otp_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber; // بنمرّر رقم الموبايل من PhoneScreen

  const OTPScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  static const int _resendSeconds = 60;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _secondsLeft = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnack('رجاءً أدخل رمز التحقق.');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      // ⚠️ إذا الباك إند بدو أسماء مفاتيح مختلفة غيّرها هون.
      final res = await http.post(
        Uri.parse(ApiConstants.checkOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": widget.phoneNumber,
          "code": code,
        }),
      );

      // نحاول نفك JSON (إن وجد) لنقرأ الرسالة
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>?;
      } catch (_) {
        data = null;
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _showSnack(data?['message']?.toString() ?? 'تم التحقق بنجاح ✅');
        // بعد النجاح روح عالواجهة المناسبة (عدّل المسار حسب مشروعك)
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/personal-info');
      } else {
        final err = data?['message']?.toString() ??
            'فشل التحقق. تأكد من الرمز وحاول مرة أخرى.';
        _showSnack(err);
      }
    } catch (e) {
      _showSnack('مشكلة اتصال: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    if (_secondsLeft > 0) return;

    setState(() => _isResending = true);
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone": widget.phoneNumber}),
      );

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>?;
      } catch (_) {
        data = null;
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _showSnack(data?['message']?.toString() ?? 'تم إرسال رمز جديد.');
        _startResendTimer();
      } else {
        final err = data?['message']?.toString() ??
            'تعذّر إرسال الرمز الآن. حاول لاحقاً.';
        _showSnack(err);
      }
    } catch (e) {
      _showSnack('مشكلة اتصال: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_isResending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من الرمز'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل رمز التحقق المرسل إلى:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.phoneNumber,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // حقل الرمز
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6, // عدّل إذا الرمز بطول مختلف
              decoration: const InputDecoration(
                hintText: 'أدخل الرمز',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // زر التحقق
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyCode,
              child: _isVerifying
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Text('تحقق'),
            ),

            const SizedBox(height: 12),

            // إعادة إرسال
            TextButton(
              onPressed: canResend ? _resendCode : null,
              child: _isResending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      canResend
                          ? 'إعادة إرسال الرمز'
                          : 'يمكنك إعادة الإرسال بعد $_secondsLeft ثانية',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

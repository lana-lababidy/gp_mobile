// lib/screens/otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'personal_info_screen.dart'; // الوجهة القادمة بعد التحقق الناجح

class OTPScreen extends StatefulWidget {
  final String phone;
  const OTPScreen({super.key, required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  // عدّاد لإعادة الإرسال
  static const int _resendSeconds = 60;
  int _left = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        setState(() => _left = 0);
      } else {
        setState(() => _left -= 1);
      }
    });
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ApiService.verifyOtp(
        phone: widget.phone,
        code: _codeCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
      );
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_left > 0) return;
    try {
      setState(() => _loading = true);
      await ApiService.sendOtp(phone: widget.phone);
      _showSnack('تم إرسال رمز جديد');
      _startTimer();
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textDirection: TextDirection.rtl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أدخل رمز التحقق')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('تم إرسال الرمز إلى: ${widget.phone}'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'رمز مكوّن من 6 أرقام',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل الرمز';
                    if (!RegExp(r'^\d{4,8}$').hasMatch(v.trim()))
                      return 'رمز غير صالح';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verify,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('تأكيد'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: (_left == 0 && !_loading) ? _resend : null,
                  child: Text(
                    _left == 0
                        ? 'إعادة إرسال الرمز'
                        : 'يمكن إعادة الإرسال خلال $_left ثانية',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

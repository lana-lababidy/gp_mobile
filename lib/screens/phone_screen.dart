// lib/screens/phone_screen.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _normalizePhone(_phoneCtrl.text.trim());
    setState(() => _loading = true);

    try {
      await ApiService.sendOtp(phone: phone);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(phone: phone),
        ),
      );
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _normalizePhone(String v) {
    // تنظيف مبسّط: إزالة المسافات والرموز
    final cleaned = v.replaceAll(RegExp(r'\s+|-'), '');
    return cleaned;
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
        appBar: AppBar(title: const Text('تأكيد رقم الهاتف')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: 'مثال: +9639XXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الهاتف';
                    final x = v.replaceAll(RegExp(r'\s+|-'), '');
                    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(x)) {
                      return 'رجاءً أدخل رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('إرسال الرمز'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

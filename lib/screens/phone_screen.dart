// lib/screens/phone_screen.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'personal_info_screen.dart';

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

  // +9639XXXXXXXX → 09XXXXXXXX (سوريا)
  String toApiPhone(String input) {
    final v = input.replaceAll(RegExp(r'\s+|-'), '');
    if (v.startsWith('+963')) {
      final rest = v.substring(4);
      return '0$rest';
    }
    return v;
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = toApiPhone(_phoneCtrl.text.trim());
    setState(() => _loading = true);

    try {
      final res = await ApiService.sendOtp(phone: phone);

      // لو السيرفر رجّع token مباشرة (مثل نتيجة لانا) → ندخل فورًا
      if (res.token != null && res.token!.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح',
                  textDirection: TextDirection.rtl)),
        );
        // TODO: احفظ الـ token لو حابب (flutter_secure_storage)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
        );
        return;
      }

      // وإلا: تابع إلى شاشة OTP (بحال لاحقًا فعّلنا verify endpoint)
      if (res.devCode != null && res.devCode!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('devCode: ${res.devCode}',
                  textDirection: TextDirection.rtl)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('تم إرسال الرمز', textDirection: TextDirection.rtl)),
        );
      }

      if (!mounted) return;
      Navigator.pushNamed(context, '/otp', arguments: phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString(), textDirection: TextDirection.rtl)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: 'مثال: +9639XXXXXXXX أو 09XXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الهاتف';
                    final x = v.replaceAll(RegExp(r'\s+|-'), '');
                    final validSyria = RegExp(r'^(\+9639\d{8}|09\d{8})$');
                    if (!validSyria.hasMatch(x)) return 'رجاءً أدخل رقم صالح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _send,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2))
                        : const Text('إرسال'),
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

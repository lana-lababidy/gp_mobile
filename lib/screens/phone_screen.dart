// lib/screens/phone_screen.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';

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

  // تحويل الرقم لصيغة الـ API (سوريا): +9639XXXXXXXX → 09XXXXXXXX
  String toApiPhone(String input) {
    final v = input.replaceAll(RegExp(r'\s+|-'), '');
    if (v.startsWith('+963')) {
      final rest = v.substring(4);
      return '0$rest';
    }
    return v;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = toApiPhone(_phoneCtrl.text.trim());
    setState(() => _loading = true);

    try {
      final res = await ApiService.sendOtp(phone: phone);

      // عرض devCode للتجربة (إن وُجد)
      if (res.devCode != null && res.devCode!.isNotEmpty) {
        // ملاحظة: هذا فقط للـ DEV
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('devCode: ${res.devCode}',
                textDirection: TextDirection.rtl),
          ),
        );
      }

      if (!mounted) return;
      // انتقل إلى صفحة OTP بالرقم كـ argument
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
                    final validSyria =
                        RegExp(r'^(\+9639\d{8}|09\d{8})$'); // سوريا فقط الآن
                    if (!validSyria.hasMatch(x)) return 'رجاءً أدخل رقم صالح';
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

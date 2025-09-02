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

  // 1) تحويل الأرقام العربية/الفارسية إلى إنجليزية
  String _toEnDigits(String s) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const en = '0123456789';
    final buf = StringBuffer();
    for (final ch in s.runes) {
      final c = String.fromCharCode(ch);
      final iAr = ar.indexOf(c);
      if (iAr != -1) {
        buf.write(en[iAr]);
        continue;
      }
      final iFa = fa.indexOf(c);
      if (iFa != -1) {
        buf.write(en[iFa]);
        continue;
      }
      buf.write(c);
    }
    return buf.toString();
  }

  // 2) تنظيف الرقم من المسافات/الشرطات/الرموز غير المسموحة
  String _cleanPhone(String input) {
    var v = _toEnDigits(input).trim();
    // احذف كل شيء غير الأرقام أو +
    v = v.replaceAll(RegExp(r'[^\d\+]+'), '');
    // اسمح بـ + فقط إذا كانت في أول السلسلة
    if (v.length > 1) v = v[0] + v.substring(1).replaceAll('+', '');
    return v;
  }

  // 3) التطبيع لصيغة الـ API: +9639XXXXXXXX -> 09XXXXXXXX (سوريا)
  String normalizePhone(String input) {
    final v = _cleanPhone(input);
    if (v.startsWith('+963')) {
      final rest = v.substring(4); // متوقع 9XXXXXXXX
      return '0$rest';
    }
    // اترك 09XXXXXXXX كما هو
    return v;
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    // سكّر الكيبورد
    FocusScope.of(context).unfocus();

    final phone = normalizePhone(_phoneCtrl.text);
    setState(() => _loading = true);

    try {
      await ApiService.sendOtp(mobileNumber: phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال الرمز', textDirection: TextDirection.rtl),
        ),
      );

      // انتقال لشاشة OTP وتمرير الرقم
      Navigator.pushNamed(context, '/otp', arguments: phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString()), behavior: SnackBarBehavior.floating),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: 'مثال: +9639XXXXXXXX أو 09XXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الهاتف';
                    final x = _cleanPhone(v);
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

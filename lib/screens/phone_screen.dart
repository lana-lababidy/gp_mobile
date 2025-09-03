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
  bool _validNow = false; // لتمكين/تعطيل زر الإرسال

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.dispose();
    super.dispose();
  }

  // تحويل الأرقام العربية/الفارسية إلى إنجليزية
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

  // تنظيف الإدخال من المسافات/الشرطات/الرموز غير المسموحة (+ فقط أول السطر)
  String _cleanPhone(String input) {
    var v = _toEnDigits(input).trim();
    v = v.replaceAll(RegExp(r'[^\d\+]+'), '');
    if (v.length > 1) v = v[0] + v.substring(1).replaceAll('+', '');
    return v;
  }

  // تطبيع سوريا: +9639XXXXXXXX → 09XXXXXXXX (نحافظ على 09 كما هو)
  String normalizePhone(String input) {
    final v = _cleanPhone(input);
    if (v.startsWith('+963')) {
      final rest = v.substring(4);
      return '0$rest';
    }
    return v;
  }

  bool _isValidSyPhone(String input) {
    final x = _cleanPhone(input);
    final re = RegExp(r'^(\+9639\d{8}|09\d{8})$');
    return re.hasMatch(x);
  }

  void _onPhoneChanged() {
    final ok = _isValidSyPhone(_phoneCtrl.text);
    if (ok != _validNow) setState(() => _validNow = ok);
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final phone = normalizePhone(_phoneCtrl.text);
    setState(() => _loading = true);

    try {
      await ApiService.sendOtp(mobileNumber: phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم إرسال الرمز', textDirection: TextDirection.rtl)),
      );
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
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تأكيد رقم الهاتف')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // تدقيق فوري
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.sms_outlined, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'أدخل رقمك لتصلك رسالة رمز التحقق (OTP). نقبل الصيغتين: 09XXXXXXXX أو +9639XXXXXXXX.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // حقل الرقم
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                      _validNow && !_loading ? _send() : null,
                  textDirection: TextDirection.ltr, // لتفادي لخبطة RTL
                  maxLength: 14, // يكفي للصيغة الدولية
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '+9639XXXXXXXX أو 09XXXXXXXX',
                    counterText: '',
                    prefixIcon: const Icon(Icons.phone_iphone),
                    suffixIcon: _phoneCtrl.text.isNotEmpty
                        ? Icon(
                            _validNow
                                ? Icons.check_circle
                                : Icons.error_outline,
                            size: 20,
                            color: _validNow
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الهاتف';
                    return _isValidSyPhone(v) ? null : 'رجاءً أدخل رقم صالح';
                  },
                ),

                const SizedBox(height: 8),
                Text(
                  'قد تصلك الرسالة عبر واتساب أو SMS حسب إعدادات السيرفر.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // زر الإرسال
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: (_validNow && !_loading) ? _send : null,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('إرسال الرمز'),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'بالنقر على "إرسال الرمز" فأنت توافق على شروط الاستخدام وسياسة الخصوصية.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

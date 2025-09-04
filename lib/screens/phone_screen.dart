// lib/screens/phone_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  // للعرض فقط – ما منستخدمه بالإرسال (حتى ما نغيّر منطق الـ API)
  String _countryCode = '+963';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // فورماتر بسيط لعرض الرقم بشكل "999 999 999" أثناء الكتابة
  String _formatGrouped(String digits) {
    // خُد أرقام فقط
    final only = digits.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < only.length; i++) {
      buf.write(only[i]);
      if (i == 2 || i == 5) buf.write(' ');
    }
    return buf.toString();
  }

  Future<void> _send() async {
    // حوّل الإدخال لأرقام فقط
    var digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    // الـ API بدها الشكل المحلي مع صفر بالبداية (مثل 0968xxxxxx)
    if (!digits.startsWith('0')) digits = '0$digits';

    if (digits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رجاءً أدخل رقم هاتف صحيح (10 أرقام)')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // 1) توليد/إرسال كود OTP (لا تغيير على الـ API)
      final res =
          await context.read<AuthApi>().generateOtpMobile(phone: digits);

      // 2) التقاط كود التطوير إن رجع من السيرفر (data = 4 أرقام)
      String? devOtp;
      final v = res['data'] ?? res['otp'] ?? res['code'];
      if (v != null) devOtp = v.toString();

      if (!mounted) return;

      // 3) الانتقال لشاشة OTP وتمرير الرقم (والـ devOtp للتجربة فقط)
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'phone': digits, 'devOtp': devOtp},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A2A6C); // أزرق كحلي
    const accent = Color(0xFF23A8F5); // أزرق فاتح للزر

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const SizedBox.shrink(),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // العنوان
                    Text(
                      'أهلاً بك',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل رقم الموبايل للحصول على رمز تأكيد',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 28),

                    // عنوان الحقل
                    Text(
                      'رقم الهاتف',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // سطر الإدخال: كود البلد (للعرض) + حقل الرقم
                    Row(
                      children: [
                        // قائمة كود البلد (للشكل فقط)
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _countryCode,
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                              items: const [
                                DropdownMenuItem(
                                  value: '+963',
                                  child: Text('🇸🇾  +963'),
                                ),
                              ],
                              onChanged: (v) {
                                // للعرض فقط – ما منستخدمه بالإرسال
                                if (v != null) setState(() => _countryCode = v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // حقل الرقم
                        Expanded(
                          child: StatefulBuilder(
                            builder: (context, setS) {
                              return TextField(
                                controller: _controller,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onChanged: (val) {
                                  // حافظ على تنسيق "999 999 999"
                                  final formatted = _formatGrouped(val);
                                  if (formatted != val) {
                                    final sel = formatted.length;
                                    _controller
                                      ..text = formatted
                                      ..selection =
                                          TextSelection.collapsed(offset: sel);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'مثال  999 999 999',
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.06),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Colors.black26),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // زر الإرسال
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('إرسال رمز'),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

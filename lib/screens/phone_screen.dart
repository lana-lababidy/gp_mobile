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
  final _focus = FocusNode();

  bool _loading = false;
  String? _errorText;

  // للعرض فقط – ما بيتدخل بالإرسال
  static const String _countryCode = '+963';

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  // تنسيق "999 999 999"
  String _formatGrouped(String digits) {
    final only = digits.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < only.length; i++) {
      buf.write(only[i]);
      if (i == 2 || i == 5) buf.write(' ');
    }
    return buf.toString();
  }

  void _onChanged(String val) {
    final formatted = _formatGrouped(val);
    if (formatted != val) {
      final pos = formatted.length;
      _controller
        ..text = formatted
        ..selection = TextSelection.collapsed(offset: pos);
    }
    _validate(showErrors: false);
  }

  bool _validate({bool showErrors = true}) {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    String? err;
    if (digits.isEmpty) {
      err = 'رجاءً أدخل رقم الهاتف';
    } else if (digits.length != 9) {
      err = 'أدخل 9 أرقام مثل: 999 999 999';
    }
    if (showErrors) setState(() => _errorText = err);
    return err == null;
  }

  Future<void> _send() async {
    if (!_validate()) return;

    // نحول الإدخال لأرقام ونضيف صفر بالبداية (مثل 0968xxxxxx)
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    final phoneToSend = '0$digits';

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final res =
          await context.read<AuthApi>().generateOtpMobile(phone: phoneToSend);

      // التقط كود التطوير إن وُجد (data = 4 أرقام)
      String? devOtp;
      final v = res['data'] ?? res['otp'] ?? res['code'];
      if (v != null) devOtp = v.toString();

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'phone': phoneToSend, 'devOtp': devOtp},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _gradientButton(
      {required String label, required VoidCallback? onTap}) {
    const accent = Color(0xFF23A8F5);
    const accent2 = Color(0xFF1B78EA);
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent, accent2],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(35, 168, 245, 0.25),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: _loading ? null : onTap,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A2A6C);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const SizedBox.shrink(),
        ),
        body: Stack(
          children: [
            // 🔵 خلفية أزرق خفيف (Gradient لطيف)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEFF6FF), // أزرق فاتح جداً
                    Color(0xFFF7FAFF), // أبيض مزرق
                  ],
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight - 32),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 6),

                          // 👋 إشارة ترحيب بدل القفل
                          Center(
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFF0A2A6C).withOpacity(0.06),
                              ),
                              child: const Center(
                                child:
                                    Text('👋', style: TextStyle(fontSize: 26)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // العنوان
                          Text(
                            'أهلاً بك',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أدخل رقم الموبايل للحصول على رمز تأكيد',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),

                          const SizedBox(height: 28),

                          // عنوان الحقل
                          Text(
                            'رقم الهاتف',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),

                          // ✅ الحقل LTR ليمنع الكتابة بالمقلوب
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.left,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                              onChanged: _onChanged,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: '999 999 999',
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0, minHeight: 0),
                                // شارة كود البلد تبقى بداية الحقل (يسار بوضع LTR)
                                prefixIcon: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 12, end: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F5F8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFE6E8EC)),
                                    ),
                                    child: const Text('🇸🇾  $_countryCode',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFD),
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
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCDD7E1)),
                                ),
                                errorText: _errorText,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),
                          Text(
                            'سيتم إرسال رمز مؤلف من 4 خانات.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.black45),
                          ),

                          const Spacer(),
                          const SizedBox(height: 12),

                          // زر Gradient
                          _gradientButton(label: 'إرسال رمز', onTap: _send),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

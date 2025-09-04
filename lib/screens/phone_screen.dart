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

  // للعرض فقط – لا نستخدمه في الإرسال
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

    // نرسل للـ API بصيغة محلية تبدأ بصفر (بدون أي تعديل على منطقك)
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

  Widget _primaryGradientButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    const c1 = Color(0xFF2FA7F6);
    const c2 = Color(0xFF1D7BEA);
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [c1, c2],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(33, 122, 234, 0.25),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: _loading ? null : onTap,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
            // خلفية تدرّج أزرق لطيف
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE9F2FF), // أزرق فاتح
                    Color(0xFFF7FAFF), // أبيض مزرق
                  ],
                ),
              ),
            ),
            // لمسات زخرفية خفيفة
            Positioned(
              top: -40,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1D7BEA).withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2FA7F6).withOpacity(0.06),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight - 36),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // أيقونة ترحيب 👋
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFF0A2A6C).withOpacity(0.07),
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

                          const SizedBox(height: 26),

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

                          // بطاقة زجاجية للحقل
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.9)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(10, 42, 108, 0.06),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              textDirection:
                                  TextDirection.rtl, // نخلي الشارة يمين
                              children: [
                                // شارة العلم + الكود (يمين)
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFF1F4F8),
                                    border: Border.all(
                                        color: const Color(0xFFE6E8EC)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 🔰 علم سوريا الأخضر (Asset معFallback)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: Image.asset(
                                          'assets/flags/syria_green.png',
                                          width: 20,
                                          height: 14,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 20,
                                            height: 14,
                                            color:
                                                const Color(0xFF25A35A), // أخضر
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        _countryCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // الحقل نفسه LTR لمنع قلب الأرقام
                                Expanded(
                                  child: Directionality(
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
                                      decoration: const InputDecoration(
                                        hintText: '968 879 073',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),
                          Text(
                            _errorText ?? 'سيتم إرسال رمز مؤلف من 4 خانات.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _errorText == null
                                          ? Colors.black45
                                          : const Color(0xFFD32F2F),
                                    ),
                            textAlign: TextAlign.start,
                          ),

                          const Spacer(),
                          const SizedBox(height: 12),

                          _primaryGradientButton(
                            label: 'إرسال رمز',
                            onTap: _send,
                          ),

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

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

  static const String _countryCode = '+963'; // للعرض فقط

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  // تنسيق "999 999 999"
  String _formatGrouped(String input) {
    final only = input.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < only.length; i++) {
      buf.write(only[i]);
      if (i == 2 || i == 5) buf.write(' ');
    }
    return buf.toString();
  }

  void _onChanged(String v) {
    final f = _formatGrouped(v);
    if (f != v) {
      final pos = f.length;
      _controller
        ..text = f
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

    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    final phoneToSend = '0$digits'; // مثال: 0968XXXXXX (لا تعديل على الـ API)

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final res =
          await context.read<AuthApi>().generateOtpMobile(phone: phoneToSend);

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

  Widget _gradientButton(String label, VoidCallback? onTap) {
    const c1 = Color(0xFF2281F0);
    const c2 = Color(0xFF1C63E0);
    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [c1, c2],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(33, 122, 234, 0.22),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
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
                  : const Text(
                      'ارسال رمز',
                      style: TextStyle(
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
    const blueTitle = Color(0xFF2F6DDE);
    const bgTop = Color(0xFFF6F9FF);
    const bgBottom = Color(0xFFFFFFFF);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // خلفية فاتحة جداً
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgTop, bgBottom],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),

                    // العنوان والوصف
                    Text(
                      'أهلاً بك',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: blueTitle,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل رقم الموبايل للحصول على رمز تأكيد',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                            height: 1.4,
                          ),
                    ),

                    const SizedBox(height: 36),

                    // عنوان الحقل
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: Text(
                        'رقم الهاتف',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // كبسولة: علم + كود + سهم + حقل
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(16, 24, 40, 0.06),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          // ✅ علم سوريا "الأخضر" مرسوم بالكود (بدون أصول)
                          const FlagSyriaGreen(width: 36, height: 24),
                          const SizedBox(width: 8),

                          // كود البلد + سهم (عرض فقط)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F6FA),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFE6E8EC)),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  _countryCode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 18, color: Colors.black54),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),
                          const VerticalDivider(
                            width: 10,
                            thickness: 1,
                            color: Color(0xFFE8ECF2),
                          ),
                          const SizedBox(width: 8),

                          // الحقل LTR
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextField(
                                controller: _controller,
                                focusNode: _focus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                textAlign: TextAlign.left,
                                onChanged: _onChanged,
                                onSubmitted: (_) => _send(),
                                decoration: const InputDecoration(
                                  hintText: '999 999 999 مثال',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: Text(
                        _errorText ?? '',
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 12.5,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // زر ارسال
                    _gradientButton('ارسال رمز', _send),

                    const SizedBox(height: 18),

                    // فقرة الشروط
                    Text.rich(
                      TextSpan(
                        text: 'من خلال الاشتراك، فإنك توافق على ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black45),
                        children: const [
                          TextSpan(
                            text: 'الشروط وسياسة الخصوصية.',
                            style: TextStyle(
                              color: Color(0xFF1D63E0),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// علم سوريا الأخضر (مرسوم بالكود – بدون صور)
class FlagSyriaGreen extends StatelessWidget {
  final double width;
  final double height;
  const FlagSyriaGreen({super.key, this.width = 36, this.height = 24});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF25A35A);
    const white = Colors.white;
    const black = Colors.black;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(child: Container(color: green)),
          Expanded(
            child: Stack(
              children: [
                Container(color: white),
                // ثلاث نجوم حمراء وسط الشريط الأبيض
                LayoutBuilder(
                  builder: (context, c) {
                    final starSize = (c.maxHeight * 0.65).clamp(6.0, 12.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (_) =>
                            Icon(Icons.star, color: Colors.red, size: starSize),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(child: Container(color: black)),
        ],
      ),
    );
  }
}

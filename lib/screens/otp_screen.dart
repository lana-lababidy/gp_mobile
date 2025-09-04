// lib/screens/otp_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String? devOtp; // اختياري للتجربة (يظهر فقط خارج الـ Release)

  const OTPScreen({super.key, required this.phone, this.devOtp});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  static const int _otpLength = 4;

  final List<TextEditingController> _ctrls =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(_otpLength, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;

  static const int _cooldownDefault = 60;
  int _secondsLeft = _cooldownDefault;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();

    // لو وصل devOtp (خارج Release)، عبّي الخانات
    if (!kReleaseMode && (widget.devOtp ?? '').isNotEmpty) {
      _setOtp(widget.devOtp!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  // ----------- Helpers -----------

  void _startCooldown([int seconds = _cooldownDefault]) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() {});
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  void _setOtp(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < _otpLength; i++) {
      _ctrls[i].text = (i < digits.length) ? digits[i] : '';
    }
    // حرّك الفوكس لآخر خانة مملوءة
    final next = digits.length.clamp(0, _otpLength - 1);
    _nodes[next].requestFocus();
  }

  String _collectOtp() => _ctrls.map((c) => c.text).join();

  void _onBoxChanged(int i, String v) {
    // خذ رقم واحد فقط
    if (v.length > 1) {
      _ctrls[i].text = v.substring(v.length - 1);
    }
    // تحرّك تلقائيًا
    if (_ctrls[i].text.isNotEmpty && i < _otpLength - 1) {
      _nodes[i + 1].requestFocus();
    }
    setState(() {});
  }

  // Backspace ينتقل للخانة السابقة إذا كانت الحالية فاضية
  KeyEventResult _onBoxKey(int i, RawKeyEvent e) {
    if (e is RawKeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty &&
        i > 0) {
      _nodes[i - 1].requestFocus();
      _ctrls[i - 1].clear();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ----------- Actions -----------

  Future<void> _verify() async {
    final otp = _collectOtp();
    if (otp.length != _otpLength || !RegExp(r'^\d{4}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز مكوّن من 4 أرقام')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthApi>().continueWithMobile(
            phone: widget.phone,
            otp: otp,
          );

      if (!mounted) return;
      // نجاح → انتقل (نفس منطقك، بدون تغيير)
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;

    setState(() => _resending = true);
    try {
      final res =
          await context.read<AuthApi>().generateOtpMobile(phone: widget.phone);

      // لو رجع كود للتجربة، عبّيه (Debug فقط)
      final v = (res['data'] ?? res['otp'] ?? res['code'])?.toString();
      if (!kReleaseMode && (v ?? '').isNotEmpty) {
        _setOtp(v!);
      }

      // استخدم resend_after إن وُجد
      final s =
          (res['resend_after'] ?? res['data']?['resend_after'])?.toString();
      final seconds = int.tryParse(s ?? '') ?? _cooldownDefault;
      _startCooldown(seconds);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(res['message']?.toString() ?? 'تم إرسال رمز جديد')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  // زر متدرّج مطابق لواجهة الهاتف
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

  // صندوق PIN واحد
  Widget _pinBox(int i) {
    final bool filled = _ctrls[i].text.isNotEmpty;
    return RawKeyboardListener(
      focusNode: _nodes[i],
      onKey: (e) => _onBoxKey(i, e),
      child: SizedBox(
        width: 62,
        height: 62,
        child: TextField(
          controller: _ctrls[i],
          focusNode: _nodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction:
              i == _otpLength - 1 ? TextInputAction.done : TextInputAction.next,
          maxLength: 1,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            hintText: '•',
            hintStyle: TextStyle(
              color: Colors.black26,
              fontSize: filled ? 0 : 22,
              fontWeight: FontWeight.w700,
            ),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0E6F2)),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(16, 24, 40, 0.06),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _onBoxChanged(i, v),
          onSubmitted: (_) {
            if (i == _otpLength - 1) _verify();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blueTitle = Color(0xFF2F6DDE);
    const bgTop = Color(0xFFF6F9FF);
    const bgBottom = Color(0xFFFFFFFF);

    final maskedPhone = widget.phone.isNotEmpty
        ? widget.phone.replaceFirst(RegExp(r'^\d{6}'), '******')
        : '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // خلفية مطابقة لواجهة الهاتف
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

                    // عنوان
                    Text(
                      'أدخل رمز التحقق',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: blueTitle,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أرسلنا رمزًا إلى رقمك ${maskedPhone.isNotEmpty ? maskedPhone : ''}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                            height: 1.4,
                          ),
                    ),

                    const SizedBox(height: 28),

                    // صناديق PIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_otpLength, (i) => _pinBox(i)),
                    ),

                    const SizedBox(height: 18),

                    // إعادة الإرسال
                    Center(
                      child: _secondsLeft > 0
                          ? Text(
                              'يمكنك إعادة الإرسال بعد $_secondsLeft ثانية',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black45),
                            )
                          : TextButton(
                              onPressed: _resending ? null : _resend,
                              child: _resending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('إعادة إرسال الرمز'),
                            ),
                    ),

                    const SizedBox(height: 22),

                    // زر تأكيد
                    _gradientButton('تأكيد', _verify),

                    const SizedBox(height: 14),

                    // تغيير الرقم
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('تغيير الرقم'),
                      ),
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

// lib/screens/otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:provider/provider.dart';
import '../api/auth_api.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String? devOtp; // يُمرَّر من شاشة الهاتف (Debug فقط)
  const OTPScreen({super.key, required this.phone, this.devOtp});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpCtrl = TextEditingController();

  static const int _otpLength = 4; // السيرفر يرجّع 4 خانات
  bool _loading = false;
  bool _resending = false;

  static const int _cooldownDefault = 60;
  int _secondsLeft = _cooldownDefault;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();

    if (!kReleaseMode && (widget.devOtp ?? '').isNotEmpty) {
      _otpCtrl.text = widget.devOtp!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != _otpLength || !RegExp(r'^\d+$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('أدخل رمز مكوّن من $_otpLength أرقام')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await context.read<AuthApi>().continueWithMobile(
            phone: widget.phone,
            otp: otp,
          );

      if (!mounted) return;

      // ✅ بدون أي فحص نوع على res
      Map<String, dynamic>? data;
      final raw = res['data'];
      if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      }
      final name = data?['username']?.toString();
      if (name != null && name.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('أهلًا $name!')),
        );
      }

      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
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

      // كود التطوير (إن وُجد)
      final v = res['data'] ?? res['otp'] ?? res['code'];
      final dev = v?.toString();
      if (!kReleaseMode && (dev ?? '').isNotEmpty) {
        _otpCtrl.text = dev!;
      }

      // عدّاد الانتظار (resend_after إن وُجد)
      final s =
          (res['resend_after'] ?? res['data']?['resend_after'])?.toString();
      final seconds = int.tryParse(s ?? '') ?? _cooldownDefault;
      _startCooldown(seconds);

      if (!mounted) return;
      final message = res['message']?.toString() ?? 'تم إرسال رمز جديد';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showDevOtp = !kReleaseMode && (widget.devOtp ?? '').isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أدخل رمز التحقق'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'رجوع',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'أرسلنا رمز التحقق إلى:\n${widget.phone}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (showDevOtp) ...[
                const SizedBox(height: 8),
                Text(
                  'رمز الاختبار (Debug): ${widget.devOtp}',
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.green),
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _otpCtrl,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_otpLength),
                ],
                decoration: const InputDecoration(
                  labelText: 'رمز التحقق',
                  hintText: '____',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تأكيد'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _secondsLeft > 0
                    ? 'يمكنك إعادة الإرسال بعد $_secondsLeft ثانية'
                    : 'لم يصلك الرمز؟',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: (_secondsLeft > 0 || _resending) ? null : _resend,
                icon: _resending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('إعادة إرسال الرمز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

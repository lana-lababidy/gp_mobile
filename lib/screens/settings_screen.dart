import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loggingOut = false;

  Future<void> _confirmAndLogout() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text('نعم، سجّل الخروج'),
            ),
          ],
        ),
      ),
    );

    if (sure != true) return;

    setState(() => _loggingOut = true);
    try {
      await context.read<AuthApi>().logoutClient(); // نفس الـ API
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/phone', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Widget _dangerGradientButton({
    required String label,
    required VoidCallback? onTap,
    IconData? icon,
    bool loading = false,
  }) {
    const c1 = Color(0xFFFF4D4F); // أحمر فاتح
    const c2 = Color(0xFFD32F2F); // أحمر داكن
    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [c1, c2],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(211, 47, 47, 0.25),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.logout, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // وصف صغير
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'إدارة حسابك',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 10),

              // زر تسجيل الخروج (متدرّج أحمر)
              _dangerGradientButton(
                label: 'تسجيل الخروج',
                icon: Icons.logout,
                loading: _loggingOut,
                onTap: _confirmAndLogout,
              ),

              const SizedBox(height: 10),
              Text(
                'سيتم إنهاء الجلسة والعودة إلى شاشة تسجيل الدخول.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

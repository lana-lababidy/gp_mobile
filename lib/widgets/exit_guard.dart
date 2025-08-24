import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// زر متدرّج بسيط (مثل زر "البقاء")
class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const GradientButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF2086FF), Color(0xFF0A67FF)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// دالة تُظهر صندوق تأكيد الإغلاق
Future<bool> showExitConfirmDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'إغلاق التطبيق',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'هل أنت متأكد أنك تريد الخروج؟',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true), // خروج
                      child: const Text('الخروج',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    GradientButton(
                      text: 'البقاء',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// حارس عام: يمنع الخروج إلا بعد التأكيد.
/// - إذا الصفحة ليست جذرية (Navigator.canPop=true) يسمح بالرجوع عادي.
/// - إذا الصفحة جذرية، يظهر دIALOG التأكيد. عند الموافقة يغلق التطبيق.
class ExitGuard extends StatelessWidget {
  final Widget child;
  const ExitGuard({super.key, required this.child});

  Future<bool> _handlePop(BuildContext context) async {
    // إذا في صفحات تحت، اسمح بالرجوع عادي
    if (Navigator.of(context).canPop()) return true;

    final shouldExit = await showExitConfirmDialog(context);
    if (shouldExit) {
      // إغلاق التطبيق (Android). على iOS الأفضل ترك النظام يتحكم.
      SystemNavigator.pop();
    }
    // منع الـ pop الافتراضي لأننا عالجناه
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handlePop(context),
      child: child,
    );
  }
}

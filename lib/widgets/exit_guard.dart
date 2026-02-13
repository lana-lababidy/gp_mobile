import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// نفس دالة الديالوج اللي عملناها سابقاً
Future<bool> showExitConfirmDialog(BuildContext context) async {
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('إغلاق التطبيق',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('هل أنت متأكد أنك تريد الخروج؟',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('الخروج',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0A67FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('البقاء',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return res ?? false;
}

/// حارس يستخدم PopScope (أثبت من WillPopScope)
class ExitGuard extends StatelessWidget {
  final Widget child;
  const ExitGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // لازم ناخد سياق داخل الـ Route حتى نعرف إذا الصفحة قابلة للرجوع
    return Builder(
      builder: (innerCtx) {
        final routeCanPop = ModalRoute.of(innerCtx)?.canPop ?? false;

        return PopScope(
          // إذا في صفحات قبلها، خلّي النظام يرجع طبيعي
          canPop: routeCanPop,
          // إذا الصفحة جذرية (canPop=false) رح يناديلنا هالكولباك بدل ما يطلع
          onPopInvoked: (didPop) async {
            if (didPop) return; // رجع بالفعل (صفحة داخلية) — ما نعمل شي
            final shouldExit = await showExitConfirmDialog(innerCtx);
            if (shouldExit) SystemNavigator.pop();
          },
          child: child,
        );
      },
    );
  }
}

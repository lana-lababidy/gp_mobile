import 'dart:io';
import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CaseDetailsScreen extends StatelessWidget {
  const CaseDetailsScreen(
      {super.key, required this.caseModel, this.description});

  final CaseModel caseModel;
  final String? description; // اختياري، إن ما توفر بنعرض نص افتراضي

  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kProgress = Color(0xFF23A8F5);

  @override
  Widget build(BuildContext context) {
    final percent = (caseModel.progress * 100).clamp(0, 100).toStringAsFixed(0);
    final date = _formatDate(caseModel.createdAt);
    final remain =
        (caseModel.goal - caseModel.raised).clamp(0, double.infinity);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الحالة'),
          centerTitle: true,
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // الصورة الرئيسية
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _buildImage(caseModel.imageUrl),
            ),
            const SizedBox(height: 12),

            // العنوان وسط مثل البطاقة المرجعية
            Text(
              caseModel.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kNavy,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),

            // سطر معلومات: التاريخ + التصنيف
            Row(
              children: [
                Text(
                  _catLabel(caseModel.category),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // وصف
            Text(
              description ?? 'لا يوجد وصف إضافي لهذه الحالة حاليًا.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // نسبة التقدم + شريط التقدم
            Row(
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kProgress,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: caseModel.progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE8F5FF),
                      color: kProgress,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // أرقام مختصرة: الهدف - المحصّل - المتبقي
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _stat('الهدف', _fmt(caseModel.goal)),
                  _dot(),
                  _stat('المحصّل', _fmt(caseModel.raised)),
                  _dot(),
                  _stat('المتبقي', _fmt(remain)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // زر التبرع
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/pay',
                    arguments: _PaymentArgs(
                      caseId: caseModel.id,
                      title: caseModel.title,
                      remain: remain,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تبرّع'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // صورة علوية
  Widget _buildImage(String? pathOrUrl) {
    const double height = 220;
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_outlined, size: 48),
      );
    }
    final isHttp = pathOrUrl.startsWith('http');
    late final ImageProvider provider;
    if (isHttp) {
      provider = NetworkImage(pathOrUrl);
    } else {
      provider = FileImage(File(pathOrUrl));
    }
    return Image(
      image: provider,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, size: 48),
      ),
    );
  }

  String _catLabel(CaseCategory c) {
    switch (c) {
      case CaseCategory.money:
        return 'تبرع مالي';
      case CaseCategory.inKind:
        return 'تبرع عيني';
      case CaseCategory.physicalEffort:
        return 'تبرع جهدي';
      default:
        return 'غير مصنف';
    }
  }

  String _formatDate(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yy-$mm-$dd';
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
              color: Color(0xFF90CAF9), shape: BoxShape.circle),
        ),
      );

  Widget _stat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, color: kNavy)),
        Text(value),
      ],
    );
  }

  String _fmt(num n) {
    // تنسيق بسيط بدون كسور (عدد نقاط)
    return n.toStringAsFixed(0);
  }
}

// Arguments داخل Route الدفع
class _PaymentArgs {
  final String caseId;
  final String title;
  final double remain;
  _PaymentArgs(
      {required this.caseId, required this.title, required this.remain});
}

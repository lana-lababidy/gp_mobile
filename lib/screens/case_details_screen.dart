import 'dart:io';
import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CaseDetailsScreen extends StatelessWidget {
  const CaseDetailsScreen({super.key, required this.caseModel});

  final CaseModel caseModel;

  // ألوان موحّدة
  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kAccent = Color(0xFF23A8F5);

  @override
  Widget build(BuildContext context) {
    final double progress = caseModel.progress.clamp(0, 1);
    final String percent = (progress * 100).toStringAsFixed(0);
    final String date = _fmtDate(caseModel.createdAt);

    final String goalStr = _fmtThousands(caseModel.goal);
    final String raisedStr = _fmtThousands(caseModel.raised);

    final String? desc = (caseModel.description ?? '').trim().isEmpty
        ? null
        : caseModel.description!.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
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
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _mainImage(caseModel.imageUrl),
                  const SizedBox(height: 12),

                  // العنوان الداكن بنفس خط التطبيق
                  Text(
                    caseModel.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: kNavy,
                              height: 1.35,
                            ) ??
                        const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: kNavy,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _catLabel(caseModel.category),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // البروجريس بار مباشرة بعد العنوان
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE8F5FF),
                            color: kAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: kAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // الهدف + المحصّل (أرقام منسّقة)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        _stat('الهدف', goalStr),
                        _dot(),
                        _stat('المحصّل', raisedStr),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (desc != null) ...[
              const SizedBox(height: 16),
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'وصف الحالة',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: kNavy,
                                fontWeight: FontWeight.w800,
                              ) ??
                          const TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient:
                            const LinearGradient(colors: [kNavy, kAccent]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      desc,
                      textAlign: TextAlign.start,
                      style:
                          const TextStyle(color: Colors.black87, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // زر التبرّع
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final remain = (caseModel.goal - caseModel.raised)
                      .clamp(0.0, double.infinity);
                  Navigator.of(context).pushNamed(
                    '/pay',
                    arguments: {
                      'caseId': caseModel.id,
                      'title': caseModel.title,
                      'remain': remain,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kNavy, kAccent]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3323A8F5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'تبرّع',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
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

  // ——— عناصر مساعدة ———

  Widget _card(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05), // ✅ بدل withOpacity
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _mainImage(String? pathOrUrl) {
    const double h = 210;
    if ((pathOrUrl ?? '').isEmpty) {
      return _imagePlaceholder(h);
    }
    final isHttp = pathOrUrl!.startsWith('http');

    // ✅ Cast صحيح لنوع ImageProvider<Object>
    final ImageProvider<Object> provider = isHttp
        ? NetworkImage(pathOrUrl)
        : FileImage(File(pathOrUrl)) as ImageProvider<Object>;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image(
        image: provider,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(h),
      ),
    );
  }

  Widget _imagePlaceholder(double h) => Container(
        height: h,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 48, color: kNavy),
        ),
      );

  Widget _dot() => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
            color: Color(0xFF90CAF9), shape: BoxShape.circle),
      );

  Widget _stat(String label, String value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: kNavy,
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      );

  static String _catLabel(CaseCategory c) {
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

  String _fmtDate(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yy-$mm-$dd';
  }

  /// تنسيق آلاف بدون intl
  static String _fmtThousands(num n) {
    final raw = n.toStringAsFixed(0);
    final r = raw.split('').reversed.toList();
    final b = StringBuffer();
    for (int i = 0; i < r.length; i++) {
      if (i != 0 && i % 3 == 0) b.write(',');
      b.write(r[i]);
    }
    return b.toString().split('').reversed.join();
  }
}

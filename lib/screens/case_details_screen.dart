// lib/screens/case_details_screen.dart
import 'package:flutter/material.dart';

// الشاشات الجديدة (تأكد من وجودها)
import 'verification_info_screen.dart';
import 'donors_list_screen.dart';

class CaseDetailsScreen extends StatelessWidget {
  final dynamic caseModel;

  const CaseDetailsScreen({
    super.key,
    required this.caseModel,
  });

  // فورماتر بسيط للأرقام مع فواصل
  String _fmtNum(num n) {
    final s = n.toStringAsFixed(0);
    final reg = RegExp(r'(\d+)(\d{3})');
    String out = s;
    while (reg.hasMatch(out)) {
      out = out.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
    }
    return out;
  }

  double _progress(num raised, num goal) {
    if (goal <= 0) return 0;
    final p = (raised / goal).clamp(0, 1).toDouble();
    return p.isNaN ? 0 : p;
  }

  @override
  Widget build(BuildContext context) {
    final String title = caseModel?.title ?? 'عنوان الحالة';
    final String? imageUrl = caseModel?.imageUrl;
    final String createdAt =
        caseModel?.createdAt?.toString().split(' ').first ?? '';
    final num goal = (caseModel?.goal ?? 0);
    final num raised = (caseModel?.raised ?? 0);

    final double progress = _progress(raised, goal);
    final String goalStr = _fmtNum(goal);
    final String raisedStr = _fmtNum(raised);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E4C7E),
          foregroundColor: Colors.white,
          title: const Text('تفاصيل الحالة'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // بطاقة الحالة
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // صورة
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image,
                                      size: 48, color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // العنوان
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0E4C7E),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // وصف مختصر (Placeholder إذا ما عندك وصف بالموديل)
                    Text(
                      caseModel?.description ??
                          'وصف الحالة يظهر هنا… (يمكن ربطه لاحقًا مع واجهة إضافة حالة).',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // تاريخ وفئة (اختياري)
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          createdAt.isEmpty ? '—' : createdAt,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                        const Spacer(),
                        Icon(Icons.confirmation_num,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          caseModel?.category?.toString().split('.').last ??
                              'تبرّع',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // شريط التقدم
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF5CA4E0)),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // نسبة مئوية
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // الهدف والمحصل
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'المحصل: $raisedStr',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'الهدف: $goalStr',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // زر التبرع
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.black.withOpacity(0.15),
                    elevation: 4,
                  ),
                  onPressed: () {
                    // TODO: الانتقال إلى خطوة التبرّع/الدفع
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0xFF0E4C7E), Color(0xFF5CA4E0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'تبرّع',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // === مزيد من التفاصيل ===
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'مزيد من التفاصيل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _DetailsTile(
                      icon: Icons.verified,
                      label: 'التحقق من الصحّة',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VerificationInfoScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailsTile(
                      icon: Icons.group,
                      label: 'قائمة المتبرّعين',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DonorsListScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ويدجت البلاطة (Tile) للأزرار الثنائية
class _DetailsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DetailsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF5CA4E0),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            const SizedBox(width: 4),
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

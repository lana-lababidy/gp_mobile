// lib/models/case_model.dart

/// تصنيفات الحالات
enum CaseCategory {
  all, // الكل
  money, // تبرع مالي
  inKind, // تبرع عيني
  physicalEffort, // تبرع جهدي
}

/// نموذج الحالة
class CaseModel {
  final String id;
  final String title;
  final String? imageUrl; // مسار محلي أو رابط
  final DateTime createdAt;
  final CaseCategory category;
  final double goal; // المبلغ/النقاط المطلوبة
  final double raised; // المحصّل
  final String? description; // ✅ وصف الحالة (اختياري)

  const CaseModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.createdAt,
    required this.category,
    required this.goal,
    this.raised = 0.0,
    this.description, // ✅ جديد
  });

  /// نسبة الإنجاز بين 0 و 1
  double get progress {
    if (goal <= 0) return 0.0;
    final ratio = raised / goal;
    if (ratio < 0) return 0.0;
    if (ratio > 1) return 1.0;
    return ratio;
  }
}

// lib/models/case_model.dart
// النموذج الموحّد للحالات + أدوات تنسيق

import 'package:intl/intl.dart';

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
  final String? imageUrl; // مسار محلي مؤقت أو رابط لاحقًا
  final String description; // وصف الحالة
  final DateTime createdAt;
  final CaseCategory category;
  final double goal; // الهدف
  final double raised; // المحصل حتى الآن

  const CaseModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.category,
    required this.goal,
    this.raised = 0.0,
  });

  /// نسبة الإنجاز بين 0 و 1
  double get progress {
    if (goal <= 0) return 0.0;
    final p = raised / goal;
    if (p.isNaN || p.isInfinite) return 0.0;
    return p.clamp(0.0, 1.0);
  }

  /// تنسيقات جاهزة
  String get formattedDate => DateFormat('yy-MM-dd').format(createdAt);
  static final NumberFormat _numFmt = NumberFormat.decimalPattern('ar');
  String get formattedGoal => _numFmt.format(goal.round());
  String get formattedRaised => _numFmt.format(raised.round());
  String get formattedPercent => '${(progress * 100).toStringAsFixed(0)}%';

  /// نسخ مع تعديل
  CaseModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    CaseCategory? category,
    double? goal,
    double? raised,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      goal: goal ?? this.goal,
      raised: raised ?? this.raised,
    );
  }

  /// تحويلات (مثلاً للـ JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
      'goal': goal,
      'raised': raised,
    };
  }

  factory CaseModel.fromMap(Map<String, dynamic> map) {
    return CaseModel(
      id: map['id'] as String,
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String?,
      description: (map['description'] ?? '').toString(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      category: _categoryFrom(map['category']),
      goal: (map['goal'] is num) ? (map['goal'] as num).toDouble() : 0.0,
      raised: (map['raised'] is num) ? (map['raised'] as num).toDouble() : 0.0,
    );
  }

  static CaseCategory _categoryFrom(dynamic v) {
    final s = (v ?? '').toString();
    return CaseCategory.values.firstWhere(
      (e) => e.name == s,
      orElse: () => CaseCategory.all,
    );
  }
}

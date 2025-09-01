import 'package:intl/intl.dart';

enum CaseCategory { all, money, inKind, physicalEffort }

class CaseModel {
  final String id;
  final String title;
  final String description; // نص الوصف
  final CaseCategory category;

  final double goal; // المطلوب
  final double raised; // المحصّل

  final DateTime createdAt;

  final String? imageUrl; // صورة أساسية
  final String? beforeImageUrl; // صورة قبل التبرع (اختياري)
  final String? phone; // رقم للتواصل (اختياري)

  CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goal,
    required this.raised,
    required this.createdAt,
    this.imageUrl,
    this.beforeImageUrl,
    this.phone,
  });

  double get progress => goal <= 0 ? 0 : (raised / goal).clamp(0, 1);

  // تنسيقات جاهزة للعرض
  static final _nf = NumberFormat.decimalPattern('ar');
  static final _df = DateFormat('yy-MM-dd', 'ar');

  String get formattedGoal => _nf.format(goal);
  String get formattedRaised => _nf.format(raised);
  String get formattedDate => _df.format(createdAt);

  CaseModel copyWith({
    String? id,
    String? title,
    String? description,
    CaseCategory? category,
    double? goal,
    double? raised,
    DateTime? createdAt,
    String? imageUrl,
    String? beforeImageUrl,
    String? phone,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      goal: goal ?? this.goal,
      raised: raised ?? this.raised,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      phone: phone ?? this.phone,
    );
  }
}

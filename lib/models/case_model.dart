enum CaseCategory {
  all,
  critical,
  children,
  chronic,
  physicalEffort,
  inKind,
  money
}

class CaseModel {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;
  final CaseCategory category;
  final double goal;
  final double raised;

  const CaseModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.createdAt,
    required this.category,
    required this.goal,
    required this.raised,
  });

  double get progress => goal == 0 ? 0 : (raised / goal).clamp(0, 1);
}

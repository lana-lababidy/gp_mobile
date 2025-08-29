import 'dart:io';
import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CasesController extends ChangeNotifier {
  final List<CaseModel> _cases = [];
  String _query = '';
  CaseCategory _filter = CaseCategory.all;

  /// القائمة بعد تطبيق الفلترة والبحث وترتيب الأحدث أولاً
  List<CaseModel> get cases {
    Iterable<CaseModel> res = _cases;

    if (_filter != CaseCategory.all) {
      res = res.where((c) => c.category == _filter);
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      res = res.where((c) => c.title.toLowerCase().contains(q));
    }

    final list = res.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list;
  }

  CaseCategory get currentFilter => _filter;

  void setQuery(String q) {
    _query = q.trim();
    notifyListeners();
  }

  void setFilter(CaseCategory cat) {
    _filter = cat;
    notifyListeners();
  }

  /// إضافة حالة جديدة من قيم شاشة الإضافة
  Future<void> addCase({
    required String title,
    required CaseCategory category,
    required int targetPoints, // عدد النقاط المطلوب
    File? imageFile,
  }) async {
    final now = DateTime.now();

    final newCase = CaseModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      goal: targetPoints.toDouble(), // ✅ لازم double
      raised: 0.0, // ✅ الاسم الصحيح بدل collected
      createdAt: now,
      imageUrl: imageFile?.path, // ✅ الاسم الصحيح بدل imagePath
    );

    _cases.insert(0, newCase);
    notifyListeners();
  }

  /// إضافة نموذج جاهز (لو احتجته)
  void addCaseModel(CaseModel c) {
    _cases.add(c);
    notifyListeners();
  }
}

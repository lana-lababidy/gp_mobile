// lib/controllers/cases_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CasesController extends ChangeNotifier {
  final List<CaseModel> _cases = [];

  String _query = '';
  CaseCategory _filter = CaseCategory.all;

  /// القائمة بعد تطبيق الفلترة + البحث + ترتيب الأحدث أولاً
  List<CaseModel> get cases {
    Iterable<CaseModel> res = _cases;

    if (_filter != CaseCategory.all) {
      res = res.where((c) => c.category == _filter);
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase().trim();
      res = res.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q));
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

  /// إضافة حالة جديدة من شاشة "إضافة حالة"
  Future<void> addCase({
    required String title,
    required String description,
    required CaseCategory category,
    required int targetPoints,
    File? imageFile,
    File? beforeImageFile, // للتمديد لاحقًا
    String? phone, // للتمديد لاحقًا
  }) async {
    final now = DateTime.now();

    final newCase = CaseModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      createdAt: now,
      category: category,
      goal: targetPoints.toDouble(),
      raised: 0.0,
      imageUrl: imageFile?.path,
    );

    _cases.insert(0, newCase);
    notifyListeners();
  }

  void addCaseModel(CaseModel c) {
    _cases.insert(0, c);
    notifyListeners();
  }

  void updateRaised(String id, double delta) {
    final i = _cases.indexWhere((c) => c.id == id);
    if (i == -1) return;
    final old = _cases[i];
    final updated =
        old.copyWith(raised: (old.raised + delta).clamp(0, double.infinity));
    _cases[i] = updated;
    notifyListeners();
  }

  void removeCase(String id) {
    _cases.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  CaseModel? getById(String id) {
    try {
      return _cases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

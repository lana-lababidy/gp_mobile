import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CasesController extends ChangeNotifier {
  final List<CaseModel> _cases = [];
  String _query = '';
  CaseCategory _filter = CaseCategory.all;

  List<CaseModel> get cases {
    Iterable<CaseModel> res = _cases;
    if (_filter != CaseCategory.all)
      res = res.where((c) => c.category == _filter);
    if (_query.isNotEmpty) res = res.where((c) => c.title.contains(_query));
    return res.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  void addCase(CaseModel c) {
    _cases.add(c);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cases_controller.dart';
import '../models/case_model.dart';

class CasesListScreen extends StatelessWidget {
  const CasesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CasesController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة الحالات'), centerTitle: true),
        body: Column(
          children: [
            // بحث بسيط
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: c.setQuery,
                decoration: InputDecoration(
                  hintText: 'بحث',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            // فلاتر سريعة (شكلية)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: const [
                  _FilterChip(label: 'الكل', cat: CaseCategory.all),
                  _FilterChip(label: 'أمراض حرجة', cat: CaseCategory.critical),
                  _FilterChip(label: 'أطفال', cat: CaseCategory.children),
                  _FilterChip(label: 'أمراض مزمنة', cat: CaseCategory.chronic),
                  _FilterChip(
                      label: 'مجهود بدني', cat: CaseCategory.physicalEffort),
                  _FilterChip(label: 'تبرعات عينية', cat: CaseCategory.inKind),
                  _FilterChip(label: 'أموال', cat: CaseCategory.money),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // القائمة
            Expanded(
              child: c.cases.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: c.cases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = c.cases[i];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tileColor: Colors.white,
                          title: Text(item.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              '${(item.progress * 100).toStringAsFixed(0)}% • ${_catLabel(item.category)}'),
                        );
                      },
                    ),
            ),
          ],
        ),
        // رح نربط زر الإضافة بالشاشة add_case بالخطوة الجاية
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('رح نربطها مع شاشة الإضافة بالخطوة التالية')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('إضافة حالة'),
        ),
      ),
    );
  }

  static String _catLabel(CaseCategory c) {
    switch (c) {
      case CaseCategory.critical:
        return 'أمراض حرجة';
      case CaseCategory.children:
        return 'أطفال';
      case CaseCategory.chronic:
        return 'أمراض مزمنة';
      case CaseCategory.physicalEffort:
        return 'مجهود بدني';
      case CaseCategory.inKind:
        return 'تبرعات عينية';
      case CaseCategory.money:
        return 'أموال';
      default:
        return 'غير مصنّف';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final CaseCategory cat;
  const _FilterChip({required this.label, required this.cat, super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CasesController>();
    final selected = ctrl.currentFilter == cat;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => context.read<CasesController>().setFilter(cat),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inbox_outlined, size: 64),
          const SizedBox(height: 8),
          const Text('لا توجد حالات بعد'),
          Text('أضف أول حالة من الزر بالأسفل.',
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cases_controller.dart';
import '../models/case_model.dart';
import 'add_case_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final casesCtrl = context.watch<CasesController>();
    final cases = casesCtrl.cases; // مهم: watch ليتحدّث تلقائيًا

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ABSHIR'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة ترحيب بسيطة (اختيارية)
            _WelcomeCard(),
            const SizedBox(height: 12),

            // قائمة الحالات
            if (cases.isEmpty)
              const _EmptyState()
            else
              ...List.generate(cases.length, (i) {
                final c = cases[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CaseTile(c: c),
                );
              }),
          ],
        ),

        // زر إضافة حالة
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('إضافة حالة'),
          onPressed: () async {
            // نفتح شاشة الإضافة ونرجع منها بـ pop
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddCaseScreen()),
            );
            // ما منحتاج نعمل شي بعد الرجوع — الـ watch بيحدّث الواجهة تلقائيًا
          },
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: const [
            Text('👋'),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'أهلاً بك',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseTile extends StatelessWidget {
  final CaseModel c;
  const _CaseTile({required this.c});

  @override
  Widget build(BuildContext context) {
    final percent = (c.progress * 100).toStringAsFixed(0);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: _thumb(c.imageUrl),
        title: Text(
          c.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$percent% • ${_catLabel(c.category)}'),
        onTap: () {
          // لاحقًا: افتح تفاصيل الحالة
        },
      ),
    );
  }

  Widget _thumb(String? pathOrUrl) {
    final double size = 48;
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_outlined),
      );
    }

    // لو رابط http نستخدم NetworkImage، غير ذلك نفترضه مسار ملف محلي
    final isHttp = pathOrUrl.startsWith('http');
    final imageProvider = isHttp
        ? NetworkImage(pathOrUrl)
        : FileImage(File(pathOrUrl)) as ImageProvider;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: imageProvider,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }

  String _catLabel(CaseCategory c) {
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              const Text('لا توجد حالات بعد'),
              Text(
                'أضف أول حالة من زر الإضافة بالأسفل.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cases_controller.dart';
import '../models/case_model.dart';
import 'add_case_screen.dart';
import 'cases_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ترتيب مثل اللقطة: الإعدادات | إضافة | الحالات | الرئيسية
  int _currentIndex = 3;

  // ألوان مثل السابق
  static const Color kNavy = Color(0xFF0A2A6C);

  @override
  Widget build(BuildContext context) {
    final casesCtrl = context.watch<CasesController>();
    final cases = casesCtrl.cases;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('ABSHIR'),
          centerTitle: true,
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // الجسم: حسب التبويب الحالي
        body: _buildBody(context, cases),

        // ✅ شريط سفلي (بدون FAB)
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) async {
            // الترتيب: 0 settings, 1 add, 2 list, 3 home
            if (i == 1) {
              // فتح إضافة حالة ثم الرجوع
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddCaseScreen()),
              );
              // بعد الرجوع خليك على الرئيسية لحتى تشوف الحالة الجديدة
              setState(() => _currentIndex = 3);
            } else {
              setState(() => _currentIndex = i);
            }
          },
          selectedItemColor: kNavy,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'إضافة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_rows_outlined),
              label: 'الحالات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<CaseModel> cases) {
    switch (_currentIndex) {
      case 2:
        // شاشة قائمة الحالات
        return const CasesListScreen();

      case 3:
        // الرئيسية (الترحيب + آخر الحالات)
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WelcomeCard(),
            const SizedBox(height: 12),
            if (cases.isEmpty)
              const _EmptyState()
            else
              ...List.generate(
                cases.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CaseTile(c: cases[i]),
                ),
              ),
          ],
        );

      default:
        // تبويب الإعدادات
        return const Center(child: Text('الإعدادات'));
    }
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
    const double size = 48;

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

    final isHttp = pathOrUrl.startsWith('http');
    late final ImageProvider provider;

    if (isHttp) {
      provider = NetworkImage(pathOrUrl);
    } else {
      provider = FileImage(File(pathOrUrl));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: provider,
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
                'أضف أول حالة من تبويب "إضافة" في الشريط السفلي.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

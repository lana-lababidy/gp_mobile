import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cases_controller.dart';
import '../models/case_model.dart';

// الشاشات الأخرى
import 'cases_list_screen.dart';
import 'add_case_screen.dart';
import 'case_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ألوان موحّدة
  static const Color kNavy = Color(0xFF0A2A6C);

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CasesController>();
    final cases = c.cases;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: const Text('ABSHIR'),
          centerTitle: true,
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child:
                  Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          children: [
            // بطاقة ترحيب صغيرة
            _greetCard(),

            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'الحالات المثبتة',
                style: TextStyle(
                  color: kNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            if (cases.isEmpty)
              _emptyPinned()
            else
              ...cases.take(3).map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      child: _PinnedCaseCard(
                        item: e,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CaseDetailsScreen(caseModel: e),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
          ],
        ),

        // شريط سفلي
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kNavy,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          onTap: (i) {
            setState(() => _currentIndex = i);
            if (i == 0) {
              // الرئيسية
            } else if (i == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CasesListScreen()),
              );
            } else if (i == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCaseScreen()),
              );
            } else if (i == 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الإعدادات قادمة قريبًا')),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded), label: 'الحالات'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined), label: 'إضافة'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }

  Widget _greetCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text(
            'أهلًا بك ',
            style: TextStyle(
              color: Color(0xFF0A2A6C),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text('👋'),
        ],
      ),
    );
  }

  Widget _emptyPinned() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05), // ✅ بدل withOpacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Center(
        child: Text(
          'لا توجد حالات مثبتة بعد',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

/// بطاقة حالة مثبّتة قابلة للنقر
class _PinnedCaseCard extends StatelessWidget {
  const _PinnedCaseCard({required this.item, required this.onTap});

  final CaseModel item;
  final VoidCallback onTap;

  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kAccent = Color(0xFF23A8F5);

  @override
  Widget build(BuildContext context) {
    final String date = _fmtDate(item.createdAt);
    final String percent =
        (item.progress * 100).clamp(0, 100).toStringAsFixed(0);

    final bool isHttp = (item.imageUrl ?? '').startsWith('http');
    final ImageProvider? provider = item.imageUrl == null
        ? null
        : (isHttp
            ? NetworkImage(item.imageUrl!)
            : FileImage(File(item.imageUrl!)) as ImageProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06), // ✅
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصورة
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: provider == null
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              color: kNavy, size: 42),
                        ),
                      )
                    : Image(image: provider, fit: BoxFit.cover),
              ),
            ),

            // العنوان
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),

            // النسبة + الشريط
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE8F5FF),
                        color: kAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: kAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // التاريخ + سهم
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_left_rounded, color: kNavy),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yy-$mm-$dd';
  }
}

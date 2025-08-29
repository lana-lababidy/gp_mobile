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

  // ألوان ثابتة
  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kProgress = Color(0xFF23A8F5); // أزرق فاتح لشريط التقدم

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
        body: _buildBody(context, cases),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) async {
            // الترتيب: 0 settings, 1 add, 2 list, 3 home
            if (i == 1) {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddCaseScreen()),
              );
              setState(() => _currentIndex = 3); // ارجع للرئيسية بعد الإضافة
            } else {
              setState(() => _currentIndex = i);
            }
          },
          selectedItemColor: kNavy,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'الإعدادات'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined), label: 'إضافة'),
            BottomNavigationBarItem(
                icon: Icon(Icons.table_rows_outlined), label: 'الحالات'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<CaseModel> cases) {
    switch (_currentIndex) {
      case 2:
        return const CasesListScreen();

      case 3:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WelcomeCard(),
            const SizedBox(height: 16),

            // عنوان القسم مثل الصورة: "الحالات المثبتة"
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الحالات المثبتة',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: kNavy,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (cases.isEmpty)
              const _EmptyState()
            else
              ...cases.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PinnedCaseCard(caseModel: c),
                  )),
          ],
        );

      default:
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

/// بطاقة حالة على شكل الصورة المرجعية
class _PinnedCaseCard extends StatelessWidget {
  final CaseModel caseModel;
  const _PinnedCaseCard({required this.caseModel});

  static const Color kNavy = _HomeScreenState.kNavy;
  static const Color kProgress = _HomeScreenState.kProgress;

  @override
  Widget build(BuildContext context) {
    final percent = (caseModel.progress * 100).clamp(0, 100).toStringAsFixed(0);
    final date = _formatDate(caseModel.createdAt); // yy-MM-dd

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصورة
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: _buildImage(caseModel.imageUrl),
          ),

          // الشريط الأبيض مع النص بمحاذاة الوسط
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              caseModel.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kNavy,
                height: 1.35,
              ),
            ),
          ),

          // السطر: 100% يسار + شريط التقدم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kProgress,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: caseModel.progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8F5FF),
                      color: kProgress,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // التاريخ أسفل يمين
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // تنسيق التاريخ: yy-MM-dd
  String _formatDate(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yy-$mm-$dd';
  }

  // صورة بطاقة: رابط شبكة أو مسار محلي، مع Placeholder افتراضي
  Widget _buildImage(String? pathOrUrl) {
    const double height = 180;
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_outlined, size: 48),
      );
    }

    final isHttp = pathOrUrl.startsWith('http');
    late final ImageProvider provider;
    if (isHttp) {
      provider = NetworkImage(pathOrUrl);
    } else {
      provider = FileImage(File(pathOrUrl));
    }

    return Image(
      image: provider,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, size: 48),
      ),
    );
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

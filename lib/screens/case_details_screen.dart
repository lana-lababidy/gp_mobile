import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/case_model.dart';

class CaseDetailsScreen extends StatelessWidget {
  final CaseModel caseModel;
  const CaseDetailsScreen({super.key, required this.caseModel});

  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kAccent = Color(0xFF23A8F5);

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _categoryLabel(CaseCategory c) {
    switch (c) {
      case CaseCategory.money:
        return 'تبرع مالي';
      case CaseCategory.inKind:
        return 'تبرع عيني';
      case CaseCategory.physicalEffort:
        return 'تبرع جهدي';
      case CaseCategory.all:
        return 'الكل';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ حل مشكلة الـ num → double
    final progress = caseModel.progress.clamp(0, 1.0).toDouble();
    final percent = (progress * 100).toStringAsFixed(0);
    final phone = caseModel.phone?.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: const Text('تفاصيل الحالة'),
          centerTitle: true,
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 6))
                ],
                border: Border.all(color: const Color(0xFFE7E7E7)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (caseModel.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(caseModel.imageUrl!),
                        fit: BoxFit.cover,
                        height: 180,
                        width: double.infinity,
                      ),
                    ),
                  const SizedBox(height: 12),

                  Text(
                    caseModel.title,
                    style: const TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),

                  const SizedBox(height: 6),

                  // الوصف
                  if (caseModel.description.trim().isNotEmpty) ...[
                    Text(
                      caseModel.description,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF454545), height: 1.5),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // رقم التواصل
                  if (phone != null && phone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: kNavy, size: 18),
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: () => _call(phone),
                            child: Text(
                              phone,
                              style: const TextStyle(
                                  color: kNavy, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // التاريخ + التصنيف
                  Row(
                    children: [
                      Text(
                        caseModel.formattedDate,
                        style: const TextStyle(
                            color: Color(0xFF9AA0A6), fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        _categoryLabel(caseModel.category),
                        style: const TextStyle(
                            color: Color(0xFF9AA0A6), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // نسبة التقدم
                  Row(
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                            color: Color(0xFF6B7280), fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress, // ✅ صار double
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE9EEF5),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // الهدف والمحصل
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE3E8EF)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'المحصل: ${caseModel.formattedRaised}',
                            style: const TextStyle(
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'الهدف: ${caseModel.formattedGoal}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kNavy, kAccent]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x3323A8F5),
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'تبرع',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

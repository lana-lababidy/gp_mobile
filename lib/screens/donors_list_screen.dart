import 'package:flutter/material.dart';

class DonorsListScreen extends StatelessWidget {
  const DonorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // لاحقًا منربطها مع الـ backend أو الـ controller لعرض المتبرعين الحقيقيين
    final mockDonors = const [
      {'name': 'متبرّع مجهول', 'amount': 50000},
      {'name': 'أبو أحمد', 'amount': 25000},
      {'name': 'فريق أبشر', 'amount': 100000},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة المتبرّعين')),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mockDonors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = mockDonors[i];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(d['name'] as String),
                subtitle: Text('المبلغ: ${d['amount']}'),
                leading: const Icon(Icons.person),
              ),
            );
          },
        ),
      ),
    );
  }
}

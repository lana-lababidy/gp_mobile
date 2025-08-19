import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "كفو",
          style: TextStyle(
            color: Color(0xFF0A2A6C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      // المحتوى
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Banner / Slider
            Container(
              margin: const EdgeInsets.all(16),
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage(
                      "assets/images/operation.jpg"), // عدل الصورة هون
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                child: const Text(
                  "دعم عمليات جراحية متنوعة",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "الحالات المثبتة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2A6C),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Card لحالة مثبتة
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/images/hand.jpg", // صورة الحالة
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "طالبة طب بشرى تكافح من أجل الحياة... بحاجة ماسة لاستكمال علاجها من ورم خبيث",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  LinearProgressIndicator(
                    value: 0.59, // نسبة التقدم
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF0A2A6C),
                  ),
                  const SizedBox(height: 5),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "59%  |  2025-08-12",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ شريط تنقل سفلي
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF0A2A6C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "الرئيسية"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "حسابي"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: "تبرعاتي"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: "الإعدادات"),
        ],
      ),
    );
  }
}

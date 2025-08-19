import 'package:flutter/material.dart';
import 'add_case_screen.dart'; // استيراد شاشة إضافة حالة

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

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 مثال على كارد علوي
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage("assets/images/operation.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Text(
                "دعم عمليات جراحية متنوعة",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "الحالات المثبتة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2A6C),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 كارد لحالة مثلاً
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/images/hand.jpg",
                      height: 120,
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
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.59,
                          color: const Color(0xFF0A2A6C),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("59%"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 زر إضافة حالة
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCaseScreen()),
          );
        },
        backgroundColor: const Color(0xFF0A2A6C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

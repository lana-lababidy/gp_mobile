import 'package:flutter/material.dart';
import 'add_case_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ABSHIR",
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A2A6C),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 كرت ترحيب
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "أهلاً بك 👋",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2A6C),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // 🔹 قائمة الحالات
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: const ListTile(
                    leading: Icon(Icons.assignment, color: Color(0xFF0A2A6C)),
                    title: Text(
                      "مرحباً بك في أبشر",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      "هذه هي الحالة الأولى للتجربة",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 🔹 شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF0A2A6C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "إضافة"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
        currentIndex: 0, // افتراضياً على الرئيسية
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCaseScreen()),
            );
          }
        },
      ),

      // 🔹 زر إضافة حالة (Extended FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCaseScreen()),
          );
        },
        backgroundColor: const Color(0xFF0A2A6C),
        label: const Text("إضافة حالة"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

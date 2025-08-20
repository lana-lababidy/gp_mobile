import 'package:flutter/material.dart';
import 'add_case_screen.dart';
import 'cases_list_screen.dart'; // شاشة الحالات

class HomeScreen extends StatefulWidget {
  /// تبويب البداية (0 الرئيسية، 1 الحالات، 2 إضافة، 3 الإعدادات)
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // ابدأ من التبويب المطلوب
  }

  // صفحات التبويبات
  List<Widget> get _pages => [
        // الصفحة 0: الرئيسية
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

        // الصفحة 1: الحالات
        const CasesListScreen(),

        // الصفحة 2: إضافة حالة
        const AddCaseScreen(),

        // الصفحة 3: الإعدادات (مؤقتاً نص فقط)
        const Center(child: Text("الإعدادات")),
      ];

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
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0A2A6C),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "الحالات"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "إضافة"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}

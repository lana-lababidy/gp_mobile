import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? priority;
  DateTime? selectedDate;
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Case",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A2A6C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // العنوان
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // الوصف
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // اختيار التاريخ
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF0A2A6C)),
                      const SizedBox(width: 8),
                      Text(
                        selectedDate == null
                            ? "Select Date"
                            : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                        style: TextStyle(
                          color:
                              selectedDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // الأولوية
              DropdownButtonFormField<String>(
                value: priority,
                decoration: InputDecoration(
                  labelText: "Priority",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ["Low", "Medium", "High"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    priority = val;
                  });
                },
              ),
              const SizedBox(height: 15),

              // رفع صورة
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _image == null
                      ? const Center(
                          child: Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // زر الحفظ
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2A6C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // 🟢 عرض Snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "تم حفظ الحالة بنجاح ✅",
                          style: TextStyle(fontFamily: "Cairo", fontSize: 16),
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // 🔹 ترجع للشاشة الرئيسية بعد ثانية
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text(
                    "Save Case",
                    style: TextStyle(fontSize: 16, fontFamily: "Cairo"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

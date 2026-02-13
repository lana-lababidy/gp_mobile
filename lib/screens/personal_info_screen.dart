// lib/screens/personal_info_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// بما أن الملف داخل مجلد screens نستخدم استيراد نسبي
import 'home_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? gender;
  String? province; // المحافظة
  DateTime? birthDate;

  File? _image;

  // قائمة المحافظات
  final List<String> provinces = const [
    'إدلب',
    'الحسكة',
    'حلب',
    'حماة',
    'حمص',
    'دير الزور',
    'دمشق',
    'درعا',
    'السويداء',
  ];

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: إرسال/حفظ البيانات في الباك إند
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('تم الحفظ بنجاح', textDirection: TextDirection.rtl)),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('المعلومات الشخصية')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // الاسم الكامل
                  buildFieldWithLabel(
                    'الاسم الكامل',
                    buildTextField(
                      'الاسم الكامل',
                      controller: nameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // الاسم السري
                  buildFieldWithLabel(
                    'الاسم السري',
                    buildTextField(
                      'الاسم السري',
                      controller: passwordController,
                      obscure: true,
                      validator: (v) => (v == null || v.trim().length < 4)
                          ? 'أدخل اسمًا سريًا أقله 4 أحرف'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // البريد الإلكتروني
                  buildFieldWithLabel(
                    'البريد الإلكتروني',
                    buildTextField(
                      'البريد الإلكتروني',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'أدخل البريد الإلكتروني';
                        final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        return re.hasMatch(v.trim()) ? null : 'بريد غير صالح';
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // الجنس
                  buildFieldWithLabel(
                    'الجنس',
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: inputDecoration(),
                      hint: const Text('اختر الجنس',
                          textDirection: TextDirection.rtl),
                      items: const [
                        DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                        DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                      ],
                      onChanged: (val) => setState(() => gender = val),
                      validator: (v) => v == null ? 'اختر الجنس' : null,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // المحافظة
                  buildFieldWithLabel(
                    'المحافظة',
                    DropdownButtonFormField<String>(
                      value: province,
                      decoration: inputDecoration(),
                      hint: const Text('اختر المحافظة',
                          textDirection: TextDirection.rtl),
                      items: provinces
                          .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) => setState(() => province = val),
                      validator: (v) => v == null ? 'اختر المحافظة' : null,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // تاريخ الميلاد
                  buildFieldWithLabel(
                    'تاريخ الميلاد',
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: child!,
                          ),
                        );
                        if (picked != null) setState(() => birthDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Color(0xFF0A2A6C)),
                            const SizedBox(width: 8),
                            Text(
                              birthDate == null
                                  ? 'حدد التاريخ'
                                  : '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: birthDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // زر التأكيد (بتدرّج)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.black.withOpacity(0.2),
                        elevation: 4,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A2A6C), Color(0xFF007BFF)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('تأكيد',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ويدجت العنوان فوق الحقل
  Widget buildFieldWithLabel(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2A6C),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget buildTextField(
    String hint, {
    TextEditingController? controller,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      validator: validator,
      decoration: inputDecoration().copyWith(hintText: hint),
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

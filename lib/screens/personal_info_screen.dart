import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const PersonalInfoPage(),
      theme: ThemeData(
        fontFamily: 'Cairo',
      ),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? gender;
  String? country;
  String? city;
  DateTime? birthDate;

  File? _image;

  final Map<String, List<String>> countryCities = {
    'سوريا': ['دمشق'],
    'الأردن': ['عمان'],
    'لبنان': ['بيروت'],
    'المملكة المتحدة': ['لندن'],
    'الولايات المتحدة': ['واشنطن'],
    'الإمارات العربية المتحدة': ['أبو ظبي'],
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "المعلومات الشخصية",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2A6C),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey.shade600,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              // الاسم الكامل
              buildFieldWithLabel(
                "الاسم الكامل",
                buildTextField("الاسم الكامل", controller: nameController),
              ),
              const SizedBox(height: 15),

              // الاسم السري
              buildFieldWithLabel(
                "الاسم السري",
                buildTextField("الاسم السري",
                    controller: passwordController, obscure: true),
              ),
              const SizedBox(height: 15),

              // البريد الإلكتروني
              buildFieldWithLabel(
                "البريد الإلكتروني",
                buildTextField("البريد الإلكتروني",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress),
              ),
              const SizedBox(height: 15),

              // الجنس
              buildFieldWithLabel(
                "الجنس",
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: inputDecoration(),
                  hint: const Text("اختر الجنس",
                      textDirection: TextDirection.rtl),
                  items: ["ذكر", "أنثى"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, textDirection: TextDirection.rtl),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      gender = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),

              // البلد
              buildFieldWithLabel(
                "البلد",
                DropdownButtonFormField<String>(
                  value: country,
                  decoration: inputDecoration(),
                  hint: const Text("اختر البلد",
                      textDirection: TextDirection.rtl),
                  items: countryCities.keys
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, textDirection: TextDirection.rtl),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      country = val;
                      city = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),

              // المدينة
              buildFieldWithLabel(
                "المدينة",
                DropdownButtonFormField<String>(
                  value: city,
                  decoration: inputDecoration(),
                  hint: const Text("اختر المدينة",
                      textDirection: TextDirection.rtl),
                  items: country != null
                      ? countryCities[country]!
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, textDirection: TextDirection.rtl),
                            ),
                          )
                          .toList()
                      : [],
                  onChanged: (val) {
                    setState(() {
                      city = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),

              // تاريخ الميلاد
              buildFieldWithLabel(
                "تاريخ الميلاد",
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        birthDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 12,
                    ),
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
                              ? "حدد التاريخ"
                              : "${birthDate!.year}-${birthDate!.month}-${birthDate!.day}",
                          style: TextStyle(
                            color:
                                birthDate == null ? Colors.grey : Colors.black,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                  ).copyWith(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) => null),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    print("الاسم: ${nameController.text}");
                    print("البريد: ${emailController.text}");
                    print("الجنس: $gender");
                    print("البلد: $country");
                    print("المدينة: $city");
                    print("تاريخ الميلاد: $birthDate");
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A2A6C), Color(0xFF007BFF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "تأكيد",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 ويدجت العنوان فوق الحقل
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
        const SizedBox(height: 5),
        field,
      ],
    );
  }

  Widget buildTextField(
    String hint, {
    TextEditingController? controller,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
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

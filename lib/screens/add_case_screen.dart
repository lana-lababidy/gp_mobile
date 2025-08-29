import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/case_model.dart'; // يحتوي enum CaseCategory
import '../controllers/cases_controller.dart'; // هنستدعي addCase()

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  // الحقول
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _targetPointsCtrl = TextEditingController();

  CaseCategory? _category;
  File? _pickedImage;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetPointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => _pickedImage = File(x.path));
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await context.read<CasesController>().addCase(
            title: _titleCtrl.text.trim(),
            category: _category!, // تم التأكد بالـ validator
            targetPoints: int.parse(_targetPointsCtrl.text),
            imageFile: _pickedImage, // اختياري
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الحالة بنجاح')),
      );

      // رجوع إلى الشاشة الرئيسية وتحديثها
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة حالة'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // عنوان الحالة
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _dec('عنوان الحالة'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'أدخل عنوان الحالة'
                      : null,
                ),
                const SizedBox(height: 12),

                // إضافة صورة
                Text('إضافة صورة',
                    style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _pickedImage == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 36),
                                SizedBox(height: 6),
                                Text('اضغط لاختيار صورة من المعرض'),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // تصنيف الحالة
                DropdownButtonFormField<CaseCategory>(
                  value: _category,
                  decoration: _dec('تصنيف الحالة'),
                  hint: const Text('تصنيف الحالة'),
                  items: const [
                    DropdownMenuItem(
                      value: CaseCategory.money,
                      child: Text('تبرع مالي'),
                    ),
                    DropdownMenuItem(
                      value: CaseCategory.inKind,
                      child: Text('تبرع عيني'),
                    ),
                    DropdownMenuItem(
                      value: CaseCategory.physicalEffort,
                      child: Text('تبرع جهدي'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null ? 'اختر تصنيف الحالة' : null,
                ),
                const SizedBox(height: 12),

                // عدد النقاط المطلوب
                const Text(
                  'عدد النقاط المطلوب',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _targetPointsCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dec('اكتب العدد (مثلاً 10000)'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'أدخل عدد النقاط المطلوب';
                    }
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) {
                      return 'أدخل رقمًا صحيحًا أكبر من الصفر';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock),
                    label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ'),
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

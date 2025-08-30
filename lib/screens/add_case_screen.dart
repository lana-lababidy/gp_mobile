import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/case_model.dart';
import '../controllers/cases_controller.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  // الحقول
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController(); // وصف الحالة
  final TextEditingController _phoneCtrl =
      TextEditingController(); // هاتف للتواصل
  final TextEditingController _amountCtrl =
      TextEditingController(); // المبلغ المستهدف (منسق)

  CaseCategory? _category;
  File? _mainImage; // الصورة الأساسية
  File? _beforeImage; // صورة الحالة قبل التبرع

  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(void Function(File) setFile) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => setFile(File(x.path)));
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

    // حوّل 1,000,000 -> 1000000
    final raw = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final target = int.tryParse(raw) ?? 0;

    setState(() => _isSaving = true);
    try {
      await context.read<CasesController>().addCase(
            title: _titleCtrl.text.trim(),
            category: _category!,
            targetPoints: target,
            imageFile: _mainImage, // الصورة الأساسية
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الحالة بنجاح')),
      );

      // رجوع للرئيسية (موجودة مسبقًا وبتتحدّث عبر Provider)
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
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

                // وصف الحالة (متعدد الأسطر)
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: _dec('وصف الحالة'),
                ),
                const SizedBox(height: 12),

                // إضافة صورة (الصورة الأساسية)
                Text('إضافة صورة',
                    style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickImage((f) => _mainImage = f),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _mainImage == null
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
                              _mainImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // هاتف للتواصل
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))
                  ],
                  decoration: _dec('رقم هاتف للتواصل'),
                ),
                const SizedBox(height: 12),

                // تصنيف الحالة
                DropdownButtonFormField<CaseCategory>(
                  value: _category,
                  decoration: _dec('تصنيف الحالة'),
                  hint: const Text('تصنيف الحالة'),
                  items: const [
                    DropdownMenuItem(
                        value: CaseCategory.money, child: Text('تبرع مالي')),
                    DropdownMenuItem(
                        value: CaseCategory.inKind, child: Text('تبرع عيني')),
                    DropdownMenuItem(
                        value: CaseCategory.physicalEffort,
                        child: Text('تبرع جهدي')),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null ? 'اختر تصنيف الحالة' : null,
                ),
                const SizedBox(height: 12),

                // صورة الحالة قبل التبرع
                Text('صورة الحالة قبل التبرع',
                    style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _pickImage((f) => _beforeImage = f),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _beforeImage == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 36),
                                SizedBox(height: 6),
                                Text('اضغط لرفع صورة قبل التبرع'),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _beforeImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // المبلغ المستهدف (مع تنسيق آلاف + مثال 1,000,000)
                const Text(
                  'المبلغ المستهدف',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorFormatter()],
                  decoration: _dec('اكتب العدد (مثلاً 1,000,000)'),
                  validator: (v) {
                    final raw = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (raw.isEmpty) return 'أدخل المبلغ المستهدف';
                    final n = int.tryParse(raw);
                    if (n == null || n <= 0)
                      return 'أدخل رقمًا صحيحًا أكبر من الصفر';
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
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.lock),
                    label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ'),
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

/// مُنسِّق يُضيف فواصل آلاف أثناء الكتابة (1,234,567)
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // أبقِ فقط الأرقام
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final indexFromRight = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(','); // فاصل آلاف
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
      TextEditingController(); // المبلغ المستهدف (منسّق)

  CaseCategory? _category;
  File? _mainImage; // الصورة الأساسية
  File? _beforeImage; // صورة قبل التبرع

  bool _isSaving = false;

  // ألوان/ستايل موحّد مع التطبيق
  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kAccent = Color(0xFF23A8F5); // ✅ صار مستخدم
  static const Color kCardBg = Colors.white;
  static final Color kFieldBg = Colors.grey.shade100;
  static final Color kHint = Colors.grey.shade500;
  static final Color kLabel = Colors.grey.shade700;

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

  InputDecoration _dec(String hint, {IconData? icon}) => InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: kNavy) : null,
        hintText: hint,
        hintStyle: TextStyle(color: kHint),
        filled: true,
        fillColor: kFieldBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        // ✅ لون التركيز صار kAccent لانسجام أجمل مع التدرّج
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kAccent, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      );

  Widget _sectionTitle(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(.12), // ✅ لمسة لون تابعة للـ accent
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: kNavy),
            ),
          if (icon != null) const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // تحويل 1,000,000 -> 1000000
    final raw = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final target = int.tryParse(raw) ?? 0;

    setState(() => _isSaving = true);
    try {
      await context.read<CasesController>().addCase(
            title: _titleCtrl.text.trim(),
            category: _category!, // تم التحقق عبر validator
            targetPoints: target,
            imageFile: _mainImage, // الصورة الأساسية
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الحالة بنجاح')),
      );
      Navigator.pop(context); // رجوع للرئيسية
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
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              children: [
                // -------- عنوان + وصف --------
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('بيانات الحالة',
                        icon: Icons.description_outlined),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: _dec('عنوان الحالة', icon: Icons.title),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'أدخل عنوان الحالة'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration:
                          _dec('وصف الحالة', icon: Icons.notes_outlined),
                    ),
                  ],
                )),
                const SizedBox(height: 14),

                // -------- الصور --------
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('الصور', icon: Icons.photo_library_outlined),
                    // الصورة الأساسية
                    Text('الصورة الأساسية', style: TextStyle(color: kLabel)),
                    const SizedBox(height: 6),
                    _imagePickerBox(
                      file: _mainImage,
                      onPick: () => _pickImage((f) => _mainImage = f),
                      placeholder: 'اضغط لاختيار صورة من المعرض',
                    ),
                    const SizedBox(height: 12),
                    // صورة قبل التبرع
                    Text('صورة الحالة قبل التبرع',
                        style: TextStyle(color: kLabel)),
                    const SizedBox(height: 6),
                    _imagePickerBox(
                      file: _beforeImage,
                      onPick: () => _pickImage((f) => _beforeImage = f),
                      placeholder: 'اضغط لرفع صورة قبل التبرع',
                    ),
                  ],
                )),
                const SizedBox(height: 14),

                // -------- التواصل + التصنيف --------
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('التواصل والتصنيف',
                        icon: Icons.category_outlined),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))
                      ],
                      decoration:
                          _dec('رقم هاتف للتواصل', icon: Icons.phone_outlined),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CaseCategory>(
                      value: _category,
                      decoration:
                          _dec('تصنيف الحالة', icon: Icons.segment_outlined),
                      hint: const Text('تصنيف الحالة'),
                      items: const [
                        DropdownMenuItem(
                            value: CaseCategory.money,
                            child: Text('تبرع مالي')),
                        DropdownMenuItem(
                            value: CaseCategory.inKind,
                            child: Text('تبرع عيني')),
                        DropdownMenuItem(
                            value: CaseCategory.physicalEffort,
                            child: Text('تبرع جهدي')),
                      ],
                      onChanged: (v) => setState(() => _category = v),
                      validator: (v) => v == null ? 'اختر تصنيف الحالة' : null,
                    ),
                  ],
                )),
                const SizedBox(height: 14),

                // -------- المبلغ المستهدف --------
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('التمويل', icon: Icons.attach_money_rounded),
                    const Text(
                      'المبلغ المستهدف',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, color: kNavy),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorFormatter()],
                      decoration: _dec('اكتب العدد (مثلاً 1,000,000)',
                          icon: Icons.savings),
                      validator: (v) {
                        final raw = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                        if (raw.isEmpty) return 'أدخل المبلغ المستهدف';
                        final n = int.tryParse(raw);
                        if (n == null || n <= 0)
                          return 'أدخل رقمًا صحيحًا أكبر من الصفر';
                        return null;
                      },
                    ),
                  ],
                )),
                const SizedBox(height: 18),

                // زر الحفظ (✅ تدرّج kNavy → kAccent)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kNavy, kAccent],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'حفظ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

  Widget _imagePickerBox({
    required File? file,
    required VoidCallback onPick,
    required String placeholder,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: kFieldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: file == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 36, color: kNavy),
                    const SizedBox(height: 6),
                    Text(placeholder, style: TextStyle(color: kHint)),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}

/// منسّق آلاف أثناء الكتابة (1,234,567)
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final indexFromRight = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

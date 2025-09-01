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

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();

  CaseCategory? _category;
  File? _mainImage;
  File? _beforeImage;

  bool _isSaving = false;

  static const Color kNavy = Color(0xFF0A2A6C);
  static const Color kAccent = Color(0xFF23A8F5);
  static const Color kCardBg = Colors.white;

  static final Color kFieldBg = Colors.grey.shade100;
  static final Color kHint = Colors.grey.shade700;
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
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => setFile(File(x.path)));
  }

  InputDecoration _dec({
    required String label,
    required String hint,
    IconData? icon,
    String? helper,
  }) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kNavy, fontWeight: FontWeight.w600),
        prefixIcon: icon != null ? Icon(icon, color: kNavy) : null,
        hintText: hint,
        hintStyle: TextStyle(color: kHint),
        helperText: helper,
        helperStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: kFieldBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: kAccent, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      );

  Widget _sectionHeader(String text, {IconData? icon, Color? tint}) {
    final Color bubble = (tint ?? kAccent).withOpacity(0.12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bubble, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: kNavy),
            ),
          if (icon != null) const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: kNavy, fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(colors: [kNavy, tint ?? kAccent]),
          ),
        ),
      ],
    );
  }

  Widget _card(Widget child) => Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final target =
        int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    setState(() => _isSaving = true);
    try {
      await context.read<CasesController>().addCase(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            category: _category!,
            targetPoints: target,
            imageFile: _mainImage,
            beforeImageFile: _beforeImage,
            phone:
                _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الحالة بنجاح')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
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
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              children: [
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader('بيانات الحالة',
                        icon: Icons.description_outlined,
                        tint: const Color(0xFFFFA726)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: _dec(
                          label: 'عنوان الحالة',
                          hint: 'مثلاً: تجهيز صف للأطفال...',
                          icon: Icons.title),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'أدخل عنوان الحالة'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: _dec(
                          label: 'وصف الحالة',
                          hint: 'اكتب تفاصيل إضافية...',
                          icon: Icons.notes_outlined,
                          helper:
                              'سيظهر هذا النص تحت العنوان في تفاصيل الحالة'),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader('الصور',
                        icon: Icons.photo_library_outlined,
                        tint: const Color(0xFF7E57C2)),
                    const SizedBox(height: 12),
                    Text('الصورة الأساسية', style: TextStyle(color: kLabel)),
                    const SizedBox(height: 6),
                    _imagePickerBox(
                      file: _mainImage,
                      onPick: () => _pickImage((f) => _mainImage = f),
                      placeholder: 'اضغط لاختيار صورة من المعرض',
                    ),
                    const SizedBox(height: 14),
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
                const SizedBox(height: 16),
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader('التواصل والتصنيف',
                        icon: Icons.category_outlined,
                        tint: const Color(0xFF26A69A)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))
                      ],
                      decoration: _dec(
                          label: 'رقم هاتف للتواصل',
                          hint: '+963 9xx xxx xxx',
                          icon: Icons.phone_outlined),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CaseCategory>(
                      value: _category,
                      decoration: _dec(
                          label: 'تصنيف الحالة',
                          hint: 'اختر نوع التبرع',
                          icon: Icons.segment_outlined),
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
                const SizedBox(height: 16),
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader('التمويل',
                        icon: Icons.attach_money_rounded,
                        tint: const Color(0xFF2E7D32)),
                    const SizedBox(height: 12),
                    const Text('المبلغ المستهدف',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: kNavy)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorFormatter()],
                      decoration: _dec(
                        label: 'المبلغ المستهدف',
                        hint: 'مثلاً 1,000,000',
                        icon: Icons.savings,
                        helper: 'أدخل المبلغ المطلوب بدقة — مثال: 1,000,000',
                      ),
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
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [kNavy, kAccent]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x3323A8F5),
                              blurRadius: 10,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('حفظ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        decoration: BoxDecoration(
          color: kFieldBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: file == null
                      ? Center(
                          key: const ValueKey('placeholder'),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.add_photo_alternate_outlined,
                                size: 36, color: kNavy),
                            const SizedBox(height: 6),
                            Text(placeholder, style: TextStyle(color: kHint)),
                          ]),
                        )
                      : Image.file(file,
                          key: const ValueKey('image'),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity),
                ),
              ),
            ),
            if (file != null)
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onPick,
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final b = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final idxFromRight = digits.length - i;
      b.write(digits[i]);
      if (idxFromRight > 1 && idxFromRight % 3 == 1) b.write(',');
    }
    final s = b.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cases_controller.dart';
import '../models/case_model.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _goalCtrl = TextEditingController(text: '10000');
  final _raisedCtrl = TextEditingController(text: '0');
  CaseCategory _category = CaseCategory.money;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _imageUrlCtrl.dispose();
    _goalCtrl.dispose();
    _raisedCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final item = CaseModel(
      id: UniqueKey().toString(),
      title: _titleCtrl.text.trim(),
      imageUrl:
          _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
      createdAt: DateTime.now(),
      category: _category,
      goal: double.tryParse(_goalCtrl.text.trim()) ?? 0,
      raised: double.tryParse(_raisedCtrl.text.trim()) ?? 0,
    );

    context.read<CasesController>().addCase(item);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة الحالة بنجاح')),
    );

    Navigator.pop(context); // ارجع للقائمة — ستتحدث تلقائيًا
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إضافة حالة')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'عنوان الحالة'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration:
                    const InputDecoration(labelText: 'رابط الصورة (اختياري)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CaseCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                items: const [
                  DropdownMenuItem(
                      value: CaseCategory.money, child: Text('أموال')),
                  DropdownMenuItem(
                      value: CaseCategory.inKind, child: Text('تبرعات عينية')),
                  DropdownMenuItem(
                      value: CaseCategory.physicalEffort,
                      child: Text('مجهود بدني')),
                  DropdownMenuItem(
                      value: CaseCategory.critical, child: Text('أمراض حرجة')),
                  DropdownMenuItem(
                      value: CaseCategory.children, child: Text('أطفال')),
                  DropdownMenuItem(
                      value: CaseCategory.chronic, child: Text('أمراض مزمنة')),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goalCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'الهدف (مثلاً 10000)'),
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'أدخل رقم صحيح'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _raisedCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'المحصول حتى الآن'),
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'أدخل رقم صحيح'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

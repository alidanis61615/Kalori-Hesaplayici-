import 'package:flutter/material.dart';

class WeightEditor extends StatefulWidget {
  const WeightEditor({super.key});
  @override
  State<WeightEditor> createState() => _WeightEditorState();
}

class _WeightEditorState extends State<WeightEditor> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Kilo kaydı ekle'),
    content: Form(
      key: form,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Kilo (kg)'),
        validator: (v) {
          final kg = double.tryParse((v ?? '').replaceAll(',', '.'));
          return kg == null || !kg.isFinite || kg <= 0 || kg > 500
              ? '0–500 arasında geçerli bir kilo girin'
              : null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('İptal'),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(
              context,
              double.parse(controller.text.replaceAll(',', '.')),
            );
          }
        },
        child: const Text('Kaydet'),
      ),
    ],
  );
}

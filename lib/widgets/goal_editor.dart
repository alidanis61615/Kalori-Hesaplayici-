import 'package:flutter/material.dart';

import 'nutrition_widgets.dart';

class GoalEditor extends StatefulWidget {
  const GoalEditor({super.key, required this.values});
  final List<double> values;
  @override
  State<GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<GoalEditor> {
  final form = GlobalKey<FormState>();
  late final fields = widget.values
      .map((v) => TextEditingController(text: v.toStringAsFixed(0)))
      .toList();
  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Günlük hedefler'),
    content: Form(
      key: form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < fields.length; i++)
              numberField(
                fields[i],
                [
                  'Kalori (kcal)',
                  'Protein (g)',
                  'Karbonhidrat (g)',
                  'Yağ (g)',
                  'Su hedefi (ml)',
                ][i],
                positive: true,
              ),
          ],
        ),
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
              fields.map((f) => f.text.replaceAll(',', '.')).toList(),
            );
          }
        },
        child: const Text('Kaydet'),
      ),
    ],
  );
}

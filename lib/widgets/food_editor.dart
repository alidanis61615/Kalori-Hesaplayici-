import 'package:flutter/material.dart';

import '../models/food.dart';
import '../services/backup_codec.dart';
import 'nutrition_widgets.dart';

class FoodEditor extends StatefulWidget {
  const FoodEditor({super.key, required this.date, this.food});
  final String date;
  final Food? food;
  @override
  State<FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<FoodEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, grams, kcal, protein, carbs, fat;
  late String meal;
  @override
  void initState() {
    super.initState();
    final food = widget.food;
    name = TextEditingController(text: food?.name ?? '');
    grams = TextEditingController(text: food?.grams.toString() ?? '');
    kcal = TextEditingController(text: food?.kcal.toString() ?? '');
    protein = TextEditingController(text: food?.protein.toString() ?? '0');
    carbs = TextEditingController(text: food?.carbs.toString() ?? '0');
    fat = TextEditingController(text: food?.fat.toString() ?? '0');
    meal = food?.meal ?? BackupCodec.meals.first;
  }

  @override
  void dispose() {
    for (final controller in [name, grams, kcal, protein, carbs, fat]) {
      controller.dispose();
    }
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    double value(TextEditingController c) =>
        double.parse(c.text.replaceAll(',', '.'));
    Navigator.pop(
      context,
      Food(
        id: widget.food?.id,
        name: name.text.trim(),
        meal: meal,
        date: widget.food?.id == null ? widget.date : widget.food!.date,
        grams: value(grams),
        kcal: value(kcal),
        protein: value(protein),
        carbs: value(carbs),
        fat: value(fat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      8,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Form(
      key: form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.food == null ? 'Öğün ekle' : 'Öğünü düzenle',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text('Besin değerlerini 100 gram için gir.'),
            DropdownButtonFormField<String>(
              initialValue: meal,
              decoration: const InputDecoration(labelText: 'Öğün'),
              items: BackupCodec.meals
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => meal = v);
              },
            ),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Yiyecek adı'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Yiyecek adı gerekli' : null,
            ),
            numberField(grams, 'Porsiyon (gram)', positive: true),
            numberField(kcal, 'Kalori (kcal / 100 g)'),
            numberField(protein, 'Protein (g / 100 g)'),
            numberField(carbs, 'Karbonhidrat (g / 100 g)'),
            numberField(fat, 'Yağ (g / 100 g)'),
            const SizedBox(height: 16),
            FilledButton(onPressed: save, child: const Text('Kaydet')),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

Widget nutritionCard(Widget child) => Card(
  color: Colors.white,
  elevation: 0,
  margin: const EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
    side: const BorderSide(color: Color(0xFFE0E5E2)),
  ),
  child: Padding(padding: const EdgeInsets.all(16), child: child),
);
Widget nutritionMeter(String title, double value, double goal, String unit) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: const Color(0xFFE8EEEC),
        ),
      ],
    );
Widget numberField(
  TextEditingController c,
  String label, {
  bool positive = false,
}) => TextFormField(
  controller: c,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  decoration: InputDecoration(labelText: label),
  validator: (v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    return n == null || !n.isFinite || (positive ? n <= 0 : n < 0)
        ? 'Geçerli değer girin'
        : null;
  },
);

class NutritionCard extends StatelessWidget {
  const NutritionCard(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => nutritionCard(child);
}

class GoalMeter extends StatelessWidget {
  const GoalMeter(this.title, this.value, this.goal, this.unit, {super.key});
  final String title, unit;
  final double value, goal;
  @override
  Widget build(BuildContext context) =>
      nutritionMeter(title, value, goal, unit);
}

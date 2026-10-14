import 'package:flutter/material.dart';

import '../../controllers/nutrition_controller.dart';
import '../../controllers/nutrition_actions.dart';
import '../../widgets/nutrition_widgets.dart';
import '../../utils/date.dart';
import '../../nutrition_trends.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key, required this.data, required this.actions});
  final NutritionController data;
  final NutritionActions actions;
  @override
  Widget build(BuildContext context) {
    final today = data.today;
    final calories = data.calories,
        protein = data.protein,
        carbs = data.carbs,
        fat = data.fat;
    final foods = data.foods;
    final weights = data.weights;
    final selected = data.selected;
    final water = data.water;
    final target = data.target;
    final waterGoal = data.waterGoal;
    final meals = data.meals;
    return ListView(
      key: const PageStorageKey('reports_tab'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (data.error != null)
          NutritionCard(
            Text(data.error!, style: const TextStyle(color: Colors.red)),
          ),

        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seçili günün raporu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(day(selected)),
              const SizedBox(height: 12),
              Text('Toplam enerji: ${calories.toStringAsFixed(0)} kcal'),
              Text('Protein: ${protein.toStringAsFixed(1)} g'),
              Text('Karbonhidrat: ${carbs.toStringAsFixed(1)} g'),
              Text('Yağ: ${fat.toStringAsFixed(1)} g'),
              Text('Su: $water / ${waterGoal.toStringAsFixed(0)} ml'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: waterGoal > 0 ? (water / waterGoal).clamp(0.0, 1.0) : 0,
                minHeight: 9,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: const Color(0xFFE8EEEC),
              ),
              const SizedBox(height: 6),
              Text(
                waterGoal > water
                    ? '${(waterGoal - water).toStringAsFixed(0)} ml hedefe kaldı'
                    : waterGoal == water
                    ? 'Günlük su hedefi tamamlandı'
                    : '${(water - waterGoal).toStringAsFixed(0)} ml hedefin üzerinde',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Divider(height: 28),
              ...meals.map((m) {
                final group = today.where((f) => f.meal == m).toList();
                final sum = group.fold<double>(0, (a, f) => a + f.energy);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    '$m: ${group.length} kayıt · ${sum.toStringAsFixed(0)} kcal',
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text(
                'Bu rapor yalnızca manuel kaydedilen öğün ve su verilerini içerir.',
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            final records = foods.map(
              (f) => DailyNutrition(
                date: DateTime.parse(f.date),
                calories: f.energy,
                protein: f.p,
                carbs: f.c,
                fat: f.f,
              ),
            );
            final weekly = summarizeNutrition(records, end: selected, days: 7);
            final monthly = summarizeNutrition(
              records,
              end: selected,
              days: 30,
            );
            return NutritionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beslenme özeti',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Son 7 gün: ${weekly.recordedDays} kayıtlı gün'),
                  Text(
                    'Ortalama enerji: ${weekly.averageCalories.toStringAsFixed(0)} kcal',
                  ),
                  Text(
                    'Ortalama protein: ${weekly.averageProtein.toStringAsFixed(1)} g',
                  ),
                  const Divider(height: 24),
                  Text('Son 30 gün: ${monthly.recordedDays} kayıtlı gün'),
                  Text(
                    'Ortalama enerji: ${monthly.averageCalories.toStringAsFixed(0)} kcal',
                  ),
                  Text(
                    'Ortalama karbonhidrat: ${monthly.averageCarbs.toStringAsFixed(1)} g',
                  ),
                  Text(
                    'Ortalama yağ: ${monthly.averageFat.toStringAsFixed(1)} g',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ortalamalar yalnızca öğün kaydı bulunan günleri içerir.',
                  ),
                ],
              ),
            );
          },
        ),
        Builder(
          builder: (context) {
            final start = DateTime(
              selected.year,
              selected.month,
              selected.day,
            ).subtract(const Duration(days: 6));
            final totals = <String, double>{};
            for (final food in foods) {
              if (food.date.compareTo(day(start)) >= 0 &&
                  food.date.compareTo(day(selected)) <= 0) {
                totals.update(
                  food.date,
                  (value) => value + food.energy,
                  ifAbsent: () => food.energy,
                );
              }
            }
            final close = totals.values
                .where(
                  (v) => target > 0 && v >= target * 0.9 && v <= target * 1.1,
                )
                .length;
            return NutritionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hedefe yakın günler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$close / ${totals.length} kayıtlı gün',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Son 7 günde kalori hedefinin %90–110 aralığında kalan kayıtlı günler.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Eksik öğün kayıtları sonucu etkiler. Bu gösterge sağlık veya beslenme tavsiyesi değildir.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kilo ölçüm özeti',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (weights.isEmpty)
                const Text('Henüz kilo kaydı bulunmuyor.')
              else ...[
                Text(
                  'Son ölçüm: ${weights.first.kg.toStringAsFixed(1)} kg (${weights.first.date})',
                ),
                if (weights.length > 1)
                  Text(
                    'İlk kayda göre değişim: ${(weights.first.kg - weights.last.kg).toStringAsFixed(1)} kg',
                  ),
                Text('Toplam ölçüm: ${weights.length}'),
              ],
              const SizedBox(height: 8),
              const Text(
                'Bu değerler manuel kayıtlardır; tıbbi değerlendirme değildir.',
              ),
            ],
          ),
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Son 7 gün',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(7, (i) {
                final d = DateTime.now().subtract(Duration(days: 6 - i));
                final group = foods.where((f) => f.date == day(d)).toList();
                final total = group.fold<double>(0, (a, f) => a + f.energy);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    '${day(d)} · ${group.length} öğün · ${total.toStringAsFixed(0)} kcal',
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

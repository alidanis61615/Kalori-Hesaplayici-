import 'package:flutter/material.dart';

import '../../controllers/nutrition_controller.dart';
import '../../controllers/nutrition_actions.dart';
import '../../widgets/nutrition_widgets.dart';
import '../../utils/date.dart';
import '../../nutrition_trends.dart';
import '../../theme.dart';

class TrendsTab extends StatelessWidget {
  const TrendsTab({super.key, required this.data, required this.actions});
  final NutritionController data;
  final NutritionActions actions;
  @override
  Widget build(BuildContext context) {
    final foods = data.foods;
    final weights = data.weights;
    final waterDays = data.waterDays;
    final selected = data.selected;
    final trendDays = data.trendDays;
    final target = data.target;
    final waterGoal = data.waterGoal;
    return ListView(
      key: const PageStorageKey('trends_tab'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (data.error != null)
          NutritionCard(
            Text(data.error!, style: const TextStyle(color: Colors.red)),
          ),

        const Text(
          'Değişimi birlikte takip et',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text('Kaydettiğin beslenme düzeni ve günlük ortalamalar.'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [7, 30, 90]
              .map(
                (n) => ChoiceChip(
                  label: Text('$n gün'),
                  selected: trendDays == n,
                  onSelected: (_) => data.setTrendDays(n),
                ),
              )
              .toList(),
        ),
        Builder(
          builder: (context) {
            final entries = foods.map(
              (f) => DailyNutrition(
                date: DateTime.parse(f.date),
                calories: f.energy,
                protein: f.p,
                carbs: f.c,
                fat: f.f,
              ),
            );
            final summary = summarizeNutrition(
              entries,
              end: DateTime.now(),
              days: trendDays,
            );
            return NutritionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beslenme trendi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('${summary.recordedDays}/$trendDays gün kayıtlı'),
                  const SizedBox(height: 16),
                  if (summary.recordedDays == 0)
                    const Text(
                      'Bu dönemde kayıt yok. Öğün ekledikçe ortalamaların burada görünür.',
                    )
                  else ...[
                    Text(
                      'Kayıtlı gün ortalaması: ${summary.averageCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Protein: ${summary.averageProtein.toStringAsFixed(1)} g',
                    ),
                    Text(
                      'Karbonhidrat: ${summary.averageCarbs.toStringAsFixed(1)} g',
                    ),
                    Text('Yağ: ${summary.averageFat.toStringAsFixed(1)} g'),
                    const SizedBox(height: 12),
                    GoalMeter(
                      'Ortalama enerji',
                      summary.averageCalories,
                      target,
                      'kcal',
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Ortalamalar yalnızca öğün kaydı olan günlerden hesaplanır. Eksik kayıtlar gerçek tüketimi yansıtmayabilir.',
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
                'Son 7 gün su tüketimi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Her sütun o gün kaydettiğin toplam su miktarını gösterir.',
              ),
              Builder(
                builder: (context) {
                  final values = List.generate(
                    7,
                    (i) =>
                        waterDays[day(
                          DateTime.now().subtract(Duration(days: 6 - i)),
                        )] ??
                        0,
                  );
                  final total = values.fold<int>(0, (sum, ml) => sum + ml);
                  final recorded = values.where((ml) => ml > 0).length;
                  final reached = waterGoal > 0
                      ? values.where((ml) => ml >= waterGoal).length
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam: $total ml · Kayıtlı gün: $recorded/7',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Günlük ortalama: ${(total / 7).toStringAsFixed(0)} ml · Hedefe ulaşan gün: $reached/7',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final date = DateTime.now().subtract(Duration(days: 6 - i));
                    final key = day(date);
                    final ml = waterDays[key] ?? 0;
                    final factor = waterGoal > 0
                        ? (ml / waterGoal).clamp(0.0, 1.0)
                        : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$ml ml',
                              style: const TextStyle(fontSize: 10),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 110,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: factor,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              key.substring(5),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sütun yüksekliği günlük ${waterGoal.toStringAsFixed(0)} ml hedefine göre ölçeklenir. Hedefin üzerindeki miktarlar da sayı olarak gösterilir.',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        if (weights.length >= 2)
          NutritionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kilo değişim grafiği',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Son 10 ölçüm · soldan sağa eski → yeni'),
                const SizedBox(height: 14),
                SizedBox(
                  height: 160,
                  child: Builder(
                    builder: (context) {
                      final points = weights
                          .take(10)
                          .toList()
                          .reversed
                          .toList();
                      final minKg = points
                          .map((w) => w.kg)
                          .reduce((a, b) => a < b ? a : b);
                      final maxKg = points
                          .map((w) => w.kg)
                          .reduce((a, b) => a > b ? a : b);
                      final range = (maxKg - minKg).abs() < 0.1
                          ? 1.0
                          : maxKg - minKg;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: points.map((w) {
                          final height = ((w.kg - minKg) / range * 0.7 + 0.2)
                              .clamp(0.0, 1.0);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    w.kg.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 110,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: height,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: green,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    w.date.substring(5),
                                    style: const TextStyle(fontSize: 9),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Çubuklar en düşük ve en yüksek ölçüm arasında ölçeklenir.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kilo kayıtları',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kilo ekle',
                    onPressed: actions.addWeightRecord,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              if (weights.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Henüz kilo ölçümü yok. İlk ölçümünü ekle.'),
                )
              else ...[
                Text('Son ölçüm: ${weights.first.kg.toStringAsFixed(1)} kg'),
                if (weights.length >= 2)
                  Text(
                    'Önceki ölçüme göre: ${(weights.first.kg - weights[1].kg).toStringAsFixed(1)} kg',
                  ),
                const SizedBox(height: 8),
                ...weights
                    .take(5)
                    .map(
                      (w) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${w.kg.toStringAsFixed(1)} kg'),
                        subtitle: Text(w.date),
                        trailing: IconButton(
                          tooltip: 'Kaydı sil',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Kilo kaydını sil?'),
                                content: Text(
                                  '${w.date} tarihli ölçüm silinecek.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Vazgeç'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              try {
                                await data.store.deleteWeight(w.id);
                                await data.reload();
                              } catch (e) {
                                actions.reportError(e);
                              }
                            }
                          },
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Haftalık kalori grafiği',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Son 7 gün · kaydedilen öğünler'),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final d = DateTime.now().subtract(Duration(days: 6 - i));
                    final entries = foods
                        .where((f) => f.date == day(d))
                        .toList();
                    final value = entries.fold<double>(
                      0,
                      (sum, f) => sum + f.energy,
                    );
                    final scale = target > 0 ? target : 1.0;
                    final fraction = (value / scale).clamp(0.0, 1.0);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              value.toStringAsFixed(0),
                              maxLines: 1,
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 112,
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: fraction,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: value > target
                                        ? Colors.deepOrange
                                        : green,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${d.day}/${d.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Çubuklar günlük hedefe göre ölçeklenir; hedefi aşan değerler tam yükseklikte görünür.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const Text(
          'Son 7 günün kalori kayıtları',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...List.generate(7, (i) {
          final d = DateTime.now().subtract(Duration(days: 6 - i)),
              group = foods.where((f) => f.date == day(d)).toList(),
              total = group.fold<double>(0, (s, f) => s + f.energy);
          return NutritionCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day(d)),
                const SizedBox(height: 8),
                GoalMeter('Kalori', total, target, 'kcal'),
                const SizedBox(height: 6),
                Text(
                  group.isEmpty
                      ? 'Kayıt yok'
                      : total > target
                      ? 'Hedefin üzerinde'
                      : 'Hedefin altında',
                  style: const TextStyle(color: green),
                ),
              ],
            ),
          );
        }),
        const Text('Grafikler yalnızca kaydedilen öğünleri yansıtır.'),
      ],
    );
  }
}

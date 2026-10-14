import 'package:flutter/material.dart';

import '../../controllers/nutrition_controller.dart';
import '../../controllers/nutrition_actions.dart';
import '../../widgets/nutrition_widgets.dart';
import '../../utils/date.dart';
import '../../theme.dart';

class TodayTab extends StatelessWidget {
  const TodayTab({super.key, required this.data, required this.actions});
  final NutritionController data;
  final NutritionActions actions;
  @override
  Widget build(BuildContext context) {
    final selected = data.selected;
    final water = data.water;
    final target = data.target;
    final pt = data.pt;
    final ct = data.ct;
    final ft = data.ft;
    final waterGoal = data.waterGoal;
    final filter = data.filter;
    final meals = data.meals;
    final today = data.today;
    final calories = data.calories,
        protein = data.protein,
        carbs = data.carbs,
        fat = data.fat;
    return ListView(
      key: const PageStorageKey('today_tab'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (data.error != null)
          NutritionCard(
            Text(data.error!, style: const TextStyle(color: Colors.red)),
          ),

        const Text('Küçük adımlar, düzenli ilerleme.'),
        const SizedBox(height: 16),
        NutritionCard(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  await data.changeDay(-1);
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(day(selected), style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed: () async {
                  await data.changeDay(1);
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Günlük enerji',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Text(
                '${calories.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                target > calories
                    ? '${(target - calories).toStringAsFixed(0)} kcal hedefe kaldı'
                    : '${(calories - target).toStringAsFixed(0)} kcal hedefin üzerinde',
                style: TextStyle(
                  color: calories > target ? Colors.deepOrange : green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GoalMeter('Kalori', calories, target, 'kcal'),
              const Divider(height: 22),
              GoalMeter('Protein', protein, pt, 'g'),
              const SizedBox(height: 12),
              GoalMeter('Karbonhidrat', carbs, ct, 'g'),
              const SizedBox(height: 12),
              GoalMeter('Yağ', fat, ft, 'g'),
            ],
          ),
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Günün öğünleri',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${today.length} kayıt · ${calories.toStringAsFixed(0)} kcal',
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tümü', ...meals]
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(m),
                            selected: filter == m,
                            onSelected: (_) => data.setFilter(m),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (today
                  .where((f) => filter == 'Tümü' || f.meal == filter)
                  .isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Bu öğün için henüz kayıt yok.'),
                ),
              ...today
                  .where((f) => filter == 'Tümü' || f.meal == filter)
                  .map(
                    (f) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(f.name),
                      subtitle: Text(
                        '${f.meal} · ${f.grams.toStringAsFixed(0)} g · ${f.energy.toStringAsFixed(0)} kcal',
                      ),
                      onTap: () => actions.addFood(f),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Öğün işlemleri',
                        onSelected: (action) async {
                          if (action == 'edit') {
                            await actions.addFood(f);
                          } else if (action == 'favorite') {
                            try {
                              await data.store.saveFavorite(f);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Favorilere eklendi'),
                                  ),
                                );
                              }
                            } catch (e) {
                              actions.reportError(e);
                            }
                          } else {
                            if (!context.mounted) return;
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Öğün silinsin mi?'),
                                content: Text('${f.name} kaydı silinecek.'),
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
                            if (confirmed == true) {
                              try {
                                await data.run(() => data.store.delete(f.id!));
                              } catch (e) {
                                actions.reportError(e);
                              }
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                          PopupMenuItem(
                            value: 'favorite',
                            child: Text('Favorilere ekle'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Sil')),
                        ],
                      ),
                    ),
                  ),
              FilledButton.icon(
                onPressed: () => actions.addFood(),
                icon: const Icon(Icons.add),
                label: const Text('Besin ekle'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: actions.searchCatalog,
                icon: const Icon(Icons.search),
                label: const Text('Hazır besin ara'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: actions.savedFoods,
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Favorilerden ekle'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: actions.copyMealsToTomorrow,
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Öğünleri yarına kopyala'),
              ),
            ],
          ),
        ),
        NutritionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Su takibi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GoalMeter('Günlük su', water.toDouble(), waterGoal, 'ml'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...([100, 250, 500].map(
                    (ml) => OutlinedButton(
                      onPressed: () async {
                        try {
                          await data.run(
                            () => data.store.addWater(day(selected), ml),
                          );
                        } catch (e) {
                          actions.reportError(e);
                        }
                      },
                      child: Text('+$ml ml'),
                    ),
                  )),
                  OutlinedButton.icon(
                    onPressed: water == 0
                        ? null
                        : () async {
                            try {
                              await data.run(
                                () =>
                                    data.store.removeWater(day(selected), 100),
                              );
                            } catch (e) {
                              actions.reportError(e);
                            }
                          },
                    icon: const Icon(Icons.remove),
                    label: const Text('100 ml geri al'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

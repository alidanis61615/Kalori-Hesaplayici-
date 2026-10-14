import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/nutrition_controller.dart';
import '../controllers/nutrition_actions.dart';
import '../models/food.dart';
import '../services/store.dart';
import '../utils/date.dart';
import '../widgets/food_editor.dart';
import '../widgets/goal_editor.dart';
import '../widgets/weight_editor.dart';
import '../widgets/catalog_sheet.dart';
import 'tabs/today_tab.dart';
import 'tabs/trends_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/profile_tab.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.controller, this.store});
  final NutritionController? controller;
  final Store? store;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final NutritionController data;
  late final NutritionActions actions;
  DateTime get selected => data.selected;
  List<Food> get foods => data.foods;
  Future<void> reload() => data.reload();
  @override
  void initState() {
    super.initState();
    data =
        widget.controller ??
        NutritionController(store: widget.store ?? Store.instance);
    actions = NutritionActions(
      addFood: addFood,
      searchCatalog: searchCatalog,
      savedFoods: savedFoods,
      copyMealsToTomorrow: copyMealsToTomorrow,
      addWeightRecord: addWeightRecord,
      editGoals: editGoals,
      exportBackup: exportBackup,
      restoreBackup: restoreBackup,
      reportError: fail,
    );
    if (!data.loaded) {
      data.reload();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      data.dispose();
    }
    super.dispose();
  }

  void fail(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşlem tamamlanamadı. Lütfen yeniden deneyin.'),
        ),
      );
    }
  }

  Future<void> addFood([Food? existing]) async {
    final food = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FoodEditor(date: day(selected), food: existing),
    );
    if (food == null || !mounted) return;
    try {
      await data.run(
        () => food.id == null ? data.store.add(food) : data.store.update(food),
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<void> searchCatalog() async {
    final food = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const CatalogSheet(),
    );
    if (food != null && mounted) {
      await addFood(food);
    }
  }

  Future<void> addFromSaved(Food food) async {
    try {
      await data.store.add(
        Food(
          name: food.name,
          meal: 'Kahvaltı',
          date: day(selected),
          grams: food.grams,
          kcal: food.kcal,
          protein: food.protein,
          carbs: food.carbs,
          fat: food.fat,
        ),
      );
      await reload();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${food.name} eklendi')));
      }
    } catch (e) {
      fail(e);
    }
  }

  Future<void> savedFoods() async {
    final saved = await data.store.favorites();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favori besinler',
                style: Theme.of(sheet).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (saved.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Henüz favori yok. Önce bir öğün kaydet, ardından kalp simgesine dokun.',
                  ),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: saved
                      .map(
                        (f) => ListTile(
                          title: Text(f.name),
                          subtitle: Text(
                            '${f.grams.toStringAsFixed(0)} g · ${f.energy.toStringAsFixed(0)} kcal',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              try {
                                await data.store.removeFavorite(f.id!);
                                if (sheet.mounted) Navigator.pop(sheet);
                                await savedFoods();
                              } catch (e) {
                                fail(e);
                              }
                            },
                          ),
                          onTap: () async {
                            Navigator.pop(sheet);
                            await addFromSaved(f);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> copyMealsToTomorrow() async {
    final current = foods.where((f) => f.date == day(selected)).toList();
    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bu güne öğün eklemelisin.')),
      );
      return;
    }
    final tomorrow = day(selected.add(const Duration(days: 1)));
    final existing = foods.where((f) => f.date == tomorrow).toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yarının öğün planı'),
        content: Text(
          '${current.length} öğün $tomorrow tarihine plan olarak kopyalanacak. ${existing.isNotEmpty ? "Yarın için mevcut ${existing.length} kayıt korunacak." : ""} Planlanan öğünler, tüketildi olarak değil günlük kayıt olarak sayılır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kopyala'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      for (final f in current) {
        await data.store.add(
          Food(
            name: f.name,
            meal: f.meal,
            date: tomorrow,
            grams: f.grams,
            kcal: f.kcal,
            protein: f.protein,
            carbs: f.carbs,
            fat: f.fat,
          ),
        );
      }
      await reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${current.length} öğün yarına kopyalandı.')),
        );
      }
    } catch (e) {
      fail(e);
    }
  }

  Future<void> addWeightRecord() async {
    final kg = await showDialog<double>(
      context: context,
      builder: (_) => const WeightEditor(),
    );
    if (kg == null || !mounted) return;
    try {
      await data.run(() => data.store.addWeight(day(selected), kg));
    } catch (error) {
      fail(error);
    }
  }

  Future<void> editGoals() async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => GoalEditor(
        values: [data.target, data.pt, data.ct, data.ft, data.waterGoal],
      ),
    );
    if (values == null || !mounted) return;
    try {
      await data.run(() async {
        for (var i = 0; i < values.length; i++) {
          await data.store.setSetting(
            NutritionController.settingKeys[i],
            values[i],
          );
        }
      });
    } catch (error) {
      fail(error);
    }
  }

  Future<void> exportBackup() async {
    try {
      final backup = await data.store.exportBackup();
      await Clipboard.setData(ClipboardData(text: backup));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yedek panoya kopyalandı. Güvenli bir yere yapıştırıp kaydet.',
            ),
          ),
        );
      }
    } catch (error) {
      fail(error);
    }
  }

  Future<void> restoreBackup() async {
    try {
      final clipboard = await Clipboard.getData('text/plain');
      final raw = clipboard?.text;
      if (raw == null || raw.isEmpty) {
        throw const FormatException('Panoda yedek bulunamadı');
      }
      final backup = await data.store.validateBackup(raw);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Yedeği geri yükle?'),
          content: Text(
            'Yedekte ${backup['food_entries']!.length} besin kaydı var. Mevcut besin, su, kilo, favori ve hedef kayıtların yedekteki kayıtlarla değiştirilecek. Önce mevcut verilerini yedekle.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Verileri değiştir'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await data.run(() => data.store.restoreBackup(backup));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Yedek geri yüklendi.')));
      }
    } catch (error) {
      fail(error);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: data,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalori Takip',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              ['Gün özeti', 'Trendler', 'Ekle', 'Raporlar', 'Profil'][data.tab],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (data.tab == 0)
            IconButton(
              tooltip: 'Bugüne dön',
              icon: const Icon(Icons.today_outlined),
              onPressed: () {
                data.selected = DateTime.now();
                data.reload();
              },
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: data.tab,
        onDestinationSelected: (index) {
          if (index == 2) {
            addFood();
          } else {
            data.setTab(index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Bugün',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Trendler',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Ekle',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: 'Raporlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
      body: SafeArea(
        child: switch (data.tab) {
          1 => TrendsTab(data: data, actions: actions),
          3 => ReportsTab(data: data, actions: actions),
          4 => ProfileTab(data: data, actions: actions),
          _ => TodayTab(data: data, actions: actions),
        },
      ),
    ),
  );
}

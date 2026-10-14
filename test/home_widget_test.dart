import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalori_hesaplayici/controllers/nutrition_controller.dart';
import 'package:kalori_hesaplayici/models/food.dart';
import 'package:kalori_hesaplayici/models/weight_record.dart';
import 'package:kalori_hesaplayici/screens/home.dart';
import 'package:kalori_hesaplayici/services/store.dart';
import 'package:kalori_hesaplayici/utils/date.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);
Future<void> reveal(WidgetTester tester, Finder target) async {
  if (target.evaluate().isNotEmpty) {
    await tester.ensureVisible(target);
  } else {
    await tester.scrollUntilVisible(
      target,
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.pumpAndSettle();
}

// Widget tests isolate UI behavior; store_backup_test.dart and Android integration
// tests verify the production SQLite implementation independently.
class MemoryStore extends Store {
  final entries = <Food>[];
  final waterByDay = <String, int>{};
  final settings = <String, String>{};
  int nextId = 1;
  @override
  Future<List<Food>> foods() async => List.of(entries);
  @override
  Future<void> add(Food food) async {
    entries.add(Food.fromMap({...food.toMap(), 'id': nextId++}));
  }

  @override
  Future<void> update(Food food) async {
    entries[entries.indexWhere((row) => row.id == food.id)] = food;
  }

  @override
  Future<void> delete(int id) async {
    entries.removeWhere((row) => row.id == id);
  }

  @override
  Future<int> water(String date) async => waterByDay[date] ?? 0;
  @override
  Future<Map<String, int>> waterHistory() async => Map.of(waterByDay);
  @override
  Future<void> addWater(String date, int amount) async {
    waterByDay[date] = (waterByDay[date] ?? 0) + amount;
  }

  @override
  Future<void> removeWater(String date, int amount) async {
    waterByDay[date] = ((waterByDay[date] ?? 0) - amount).clamp(0, 1000000);
  }

  @override
  Future<List<WeightRecord>> weights() async => [];
  @override
  Future<String?> getSetting(String key) async => settings[key];
  @override
  Future<void> setSetting(String key, String value) async {
    settings[key] = value;
  }
}

void main() {
  late Store store;
  late NutritionController data;
  setUp(() {
    store = MemoryStore();
    data = NutritionController(store: store);
  });
  tearDown(() async {
    data.dispose();
    await store.close();
  });
  Future<void> load(WidgetTester tester) async {
    await tester.runAsync(data.reload);
    await tester.pumpWidget(MaterialApp(home: Home(controller: data)));
    await tester.pumpAndSettle();
  }

  Future<void> persisted(WidgetTester tester) async {
    await data.pending;
    await tester.pumpAndSettle();
  }

  testWidgets('Boş ve geçersiz besin formu SQLite kaydını değiştirmez', (
    tester,
  ) async {
    await load(tester);
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Kaydet'));
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Yiyecek adı gerekli'), findsOneWidget);
    expect(data.foods, isEmpty);
  });
  testWidgets('Formdan besin eklenir ve yeniden açılan ekran kaydı gösterir', (
    tester,
  ) async {
    await load(tester);
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Yiyecek adı'), 'Demo yoğurt');
    await tester.enterText(field('Porsiyon (gram)'), '150');
    await tester.enterText(field('Kalori (kcal / 100 g)'), '60,5');
    await reveal(tester, find.text('Kaydet'));
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    await persisted(tester);
    expect(data.foods.single.name, 'Demo yoğurt');
    expect(data.calories, 90.75);
    await tester.pumpWidget(const SizedBox.shrink());
    final reopened = NutritionController(store: store);
    await tester.runAsync(reopened.reload);
    await tester.pumpWidget(MaterialApp(home: Home(controller: reopened)));
    await tester.pumpAndSettle();
    expect(reopened.foods.single.name, 'Demo yoğurt');
    reopened.dispose();
  });
  testWidgets(
    'Su ekleme veritabanına yansır, seçilen gün değişince miktar ayrılır',
    (tester) async {
      await load(tester);
      await reveal(tester, find.text('+250 ml'));
      await tester.tap(find.text('+250 ml'));
      await tester.pumpAndSettle();
      await persisted(tester);
      expect(data.water, 250);
      await tester.runAsync(() => data.changeDay(-1));
      await tester.pumpAndSettle();
      expect(data.water, 0);
      await tester.runAsync(() => data.changeDay(1));
      await tester.pumpAndSettle();
      expect(data.water, 250);
    },
  );
  testWidgets(
    'Öğün filtresi toplam kaloriyi koruyarak ilgili besini gösterir',
    (tester) async {
      await tester.runAsync(() async {
        for (final meal in ['Kahvaltı', 'Akşam']) {
          await store.add(
            Food(
              name: meal,
              meal: meal,
              date: day(data.selected),
              grams: 100,
              kcal: 100,
              protein: 1,
              carbs: 1,
              fat: 1,
            ),
          );
        }
      });
      await load(tester);
      await reveal(tester, find.widgetWithText(ChoiceChip, 'Akşam'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Akşam'));
      await tester.pumpAndSettle();
      expect(data.filter, 'Akşam');
      expect(data.calories, 200);
      expect(find.widgetWithText(ListTile, 'Akşam'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Kahvaltı'), findsNothing);
    },
  );
  testWidgets('Profilde hedef düzenleme pozitif hedefi kaydeder', (
    tester,
  ) async {
    await load(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hedefleri düzenle'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Kalori (kcal)'), '2400');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    await persisted(tester);
    expect(data.target, 2400);
    expect(await tester.runAsync(() => store.getSetting('calories')), '2400');
  });
}

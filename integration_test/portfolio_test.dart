import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kalori_hesaplayici/app.dart';
import 'package:kalori_hesaplayici/controllers/nutrition_controller.dart';
import 'package:kalori_hesaplayici/models/food.dart';
import 'package:kalori_hesaplayici/services/store.dart';
import 'package:kalori_hesaplayici/utils/date.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: filled screens, water, backup and database reopening', (
    tester,
  ) async {
    final store = Store.instance;
    // This workflow starts a fresh disposable emulator. All records are fictional demo data.
    expect(await store.foods(), isEmpty);
    for (var i = 0; i < 7; i++) {
      final date = day(DateTime.now().subtract(Duration(days: i)));
      for (final item in [
        (name: 'Yulaf ve yoğurt', meal: 'Kahvaltı', kcal: 350.0),
        (name: 'Tavuklu pilav', meal: 'Öğle', kcal: 550.0),
        (name: 'Sebzeli akşam öğünü', meal: 'Akşam', kcal: 400.0),
        (name: 'Meyve ve kuruyemiş', meal: 'Atıştırmalık', kcal: 180.0),
      ]) {
        await store.add(
          Food(
            name: item.name,
            meal: item.meal,
            date: date,
            grams: 100,
            kcal: item.kcal - i * 4,
            protein: 18,
            carbs: 35,
            fat: 9,
          ),
        );
      }
      await store.addWater(date, 1750 - i * 100);
      await store.addWeight(date, 78.5 + i * .1);
    }
    final data = NutritionController(store: store);
    await data.reload();
    await tester.pumpWidget(CalorieApp(controller: data));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await binding.takeScreenshot(name);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 5)),
      );
      await tester.pumpAndSettle();
    }

    expect(data.calories, 1480);
    expect(data.today.length, 4);
    await capture('kalori-gun-ozeti');
    await tester.drag(find.byType(ListView).first, const Offset(0, -430));
    await tester.pumpAndSettle();
    await capture('kalori-ogunler');
    await tester.tap(find.text('Trendler'));
    await tester.pumpAndSettle();
    await capture('kalori-trendler');
    await tester.scrollUntilVisible(
      find.text('Haftalık kalori grafiği'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await capture('kalori-grafik');
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await capture('kalori-profil');
    final backup = await store.exportBackup();
    await store.restoreBackup(await store.validateBackup(backup));
    await data.reload();
    expect(data.today.length, 4);
    expect(data.water, 1750);
    await tester.pumpWidget(const SizedBox.shrink());
    data.dispose();
    await store.close();
    final reopened = NutritionController(store: store);
    await reopened.reload();
    await tester.pumpWidget(CalorieApp(controller: reopened));
    await tester.pumpAndSettle();
    expect(reopened.today.length, 4);
    expect(reopened.calories, 1480);
    expect(reopened.water, 1750);
    expect(find.text('1480 / 2200 kcal'), findsWidgets);
  });
}

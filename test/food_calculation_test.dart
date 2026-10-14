import 'package:flutter_test/flutter_test.dart';
import 'package:kalori_hesaplayici/models/food.dart';
import 'package:kalori_hesaplayici/utils/date.dart';

void main() {
  group('Besin porsiyon hesaplamaları', () {
    Food food({double grams = 150}) => Food(
      name: 'Örnek besin',
      meal: 'Öğle',
      date: '2026-10-12',
      grams: grams,
      kcal: 200,
      protein: 10,
      carbs: 20,
      fat: 5,
    );

    test('100 gram başına değerler porsiyona ölçeklenir', () {
      final item = food();
      expect(item.energy, closeTo(300, 0.0001));
      expect(item.p, closeTo(15, 0.0001));
      expect(item.c, closeTo(30, 0.0001));
      expect(item.f, closeTo(7.5, 0.0001));
    });

    test('Sıfır gram sıfır besin değeri üretir', () {
      final item = food(grams: 0);
      expect(item.energy, 0);
      expect(item.p, 0);
      expect(item.c, 0);
      expect(item.f, 0);
    });

    test('Tarih sıfır dolgulu ISO biçimindedir', () {
      expect(day(DateTime(2026, 1, 9)), '2026-01-09');
    });

    test('Besin kaydı haritaya dönüştürülür', () {
      final item = food();
      final map = item.toMap();
      expect(map['grams'], 150);
      expect(map['kcal_per_100g'], 200);
      expect(map['created_at'], '2026-10-12');
    });
  });
}

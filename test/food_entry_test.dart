import 'package:flutter_test/flutter_test.dart';
import 'package:kalori_hesaplayici/models/food.dart';

void main() {
  test('Porsiyon kalorisi ve makrolar hesaplanır', () {
    final food = Food(
      name: 'Elma',
      meal: 'Kahvaltı',
      date: '2026-10-12',
      grams: 150,
      kcal: 52,
      protein: 0.3,
      carbs: 14,
      fat: 0.2,
    );
    expect(food.energy, 78);
    expect(food.p, closeTo(0.45, 0.001));
    expect(food.c, 21);
    expect(food.f, closeTo(0.3, 0.001));
  });
}

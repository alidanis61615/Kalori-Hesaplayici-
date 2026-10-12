import 'package:flutter_test/flutter_test.dart';
import 'package:kalori_hesaplayici/main.dart';

void main() {
  test('Porsiyon kalorisi hesaplanır', () {
    final food = FoodEntry(name: 'Elma', grams: 150, kcalPer100g: 52, createdAt: DateTime(2026));
    expect(food.calories, 78);
  });
}

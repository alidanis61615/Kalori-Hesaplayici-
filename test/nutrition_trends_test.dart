import 'package:flutter_test/flutter_test.dart';
import 'package:kalori_hesaplayici/nutrition_trends.dart';

void main() {
  final end = DateTime(2026, 10, 12);
  DailyNutrition entry(int day, double kcal, {double protein = 0}) =>
      DailyNutrition(date: DateTime(2026, 10, day), calories: kcal,
          protein: protein, carbs: 0, fat: 0);

  test('Boş kayıtlar güvenli sıfır özet döndürür', () {
    final result = summarizeNutrition([], end: end);
    expect(result.recordedDays, 0);
    expect(result.averageCalories, 0);
  });

  test('Yalnızca kayıtlı günler ortalamaya girer', () {
    final result = summarizeNutrition([
      entry(11, 200, protein: 10),
      entry(12, 400, protein: 20),
    ], end: end, days: 7);
    expect(result.recordedDays, 2);
    expect(result.averageCalories, 300);
    expect(result.averageProtein, 15);
  });

  test('Aynı gün birden fazla öğün tek güne toplanır', () {
    final result = summarizeNutrition([
      entry(12, 100), entry(12, 250),
    ], end: end);
    expect(result.recordedDays, 1);
    expect(result.totalCalories, 350);
    expect(result.averageCalories, 350);
  });

  test('Tarih aralığı dışındaki kayıtlar sayılmaz', () {
    final result = summarizeNutrition([
      entry(1, 999), entry(11, 100), entry(12, 200),
    ], end: end, days: 2);
    expect(result.recordedDays, 2);
    expect(result.totalCalories, 300);
  });

  test('Geçersiz aralık reddedilir', () {
    expect(() => summarizeNutrition([], end: end, days: 0), throwsArgumentError);
  });

  test('Negatif kalori reddedilir', () {
    expect(() => summarizeNutrition([entry(12, -1)], end: end),
        throwsArgumentError);
  });
}

/// Trendler ve raporlar için, SQLite veya arayüze bağlı olmayan hesaplamalar.
/// Eksik günler sıfır tüketim olarak ortalamaya dahil edilmez.
class DailyNutrition {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const DailyNutrition({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class NutritionSummary {
  final int recordedDays;
  final double totalCalories;
  final double averageCalories;
  final double averageProtein;
  final double averageCarbs;
  final double averageFat;

  const NutritionSummary({
    required this.recordedDays,
    required this.totalCalories,
    required this.averageCalories,
    required this.averageProtein,
    required this.averageCarbs,
    required this.averageFat,
  });
}

/// [end] günü dahil, son [days] takvim gününün özetini üretir.
/// Aynı gün için birden fazla satır verilirse değerler birleştirilir.
/// Sadece kayıt bulunan günler ortalamaya girer.
NutritionSummary summarizeNutrition(
  Iterable<DailyNutrition> entries, {
  required DateTime end,
  int days = 30,
}) {
  if (days <= 0) throw ArgumentError.value(days, 'days', 'Pozitif olmalı');
  final endDate = DateTime.utc(end.year, end.month, end.day);
  final start = endDate.subtract(Duration(days: days - 1));
  final byDay = <DateTime, List<double>>{};

  for (final entry in entries) {
    final d = DateTime.utc(entry.date.year, entry.date.month, entry.date.day);
    if (d.isBefore(start) || d.isAfter(endDate)) continue;
    final values = [entry.calories, entry.protein, entry.carbs, entry.fat];
    if (values.any((v) => !v.isFinite || v < 0)) {
      throw ArgumentError('Besin değerleri negatif veya geçersiz olamaz');
    }
    final totals = byDay.putIfAbsent(d, () => [0, 0, 0, 0]);
    for (var i = 0; i < totals.length; i++) {
      totals[i] += values[i];
    }
  }

  final sums = [0.0, 0.0, 0.0, 0.0];
  for (final values in byDay.values) {
    for (var i = 0; i < sums.length; i++) {
      sums[i] += values[i];
    }
  }
  final count = byDay.length;
  double avg(int i) => count == 0 ? 0 : sums[i] / count;
  return NutritionSummary(
    recordedDays: count,
    totalCalories: sums[0],
    averageCalories: avg(0),
    averageProtein: avg(1),
    averageCarbs: avg(2),
    averageFat: avg(3),
  );
}

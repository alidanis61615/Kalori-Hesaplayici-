class Food {
  final int? id;
  final String name, meal, date;
  final double grams, kcal, protein, carbs, fat;
  Food({
    this.id,
    required this.name,
    required this.meal,
    required this.date,
    required this.grams,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  double get energy => grams * kcal / 100;
  double get p => grams * protein / 100;
  double get c => grams * carbs / 100;
  double get f => grams * fat / 100;
  Map<String, Object?> toMap() => {
    'name': name,
    'meal': meal,
    'created_at': date,
    'grams': grams,
    'kcal_per_100g': kcal,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
  factory Food.fromMap(Map<String, Object?> m) => Food(
    id: m['id'] as int,
    name: m['name'] as String,
    meal: m['meal'] as String,
    date: m['created_at'] as String,
    grams: (m['grams'] as num).toDouble(),
    kcal: (m['kcal_per_100g'] as num).toDouble(),
    protein: (m['protein'] as num).toDouble(),
    carbs: (m['carbs'] as num).toDouble(),
    fat: (m['fat'] as num).toDouble(),
  );
}

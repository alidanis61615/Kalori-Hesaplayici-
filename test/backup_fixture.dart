Map<String, dynamic> sampleBackup() => {
  'format': 'kalori_hesaplayici_backup',
  'version': 1,
  'food_entries': [
    <String, dynamic>{
      'id': 1,
      'name': 'Elma',
      'grams': 120,
      'kcal_per_100g': 52,
      'protein': 0.3,
      'carbs': 13.8,
      'fat': 0.2,
      'created_at': '2026-10-14',
      'meal': 'Kahvaltı',
    },
  ],
  'water_entries': [
    <String, dynamic>{'day': '2026-10-14', 'ml': 250},
  ],
  'settings': [
    <String, dynamic>{'key': 'calories', 'value': '2200'},
  ],
  'favorites': [
    <String, dynamic>{
      'name': 'Elma',
      'grams': 100,
      'kcal_per_100g': 52,
      'protein': 0.3,
      'carbs': 13.8,
      'fat': 0.2,
    },
  ],
  'weight_entries': [
    <String, dynamic>{'day': '2026-10-14', 'kg': 78.5},
  ],
};

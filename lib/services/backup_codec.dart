import 'dart:convert';

/// Validates the complete payload before any SQLite rows are replaced.
class BackupCodec {
  static const maxBytes = 5000000;
  static const maxRows = 50000;
  static const tables = [
    'food_entries',
    'water_entries',
    'settings',
    'favorites',
    'weight_entries',
  ];
  static const meals = ['Kahvaltı', 'Öğle', 'Akşam', 'Atıştırmalık', 'Diğer'];

  static Map<String, List<Map<String, Object?>>> decode(String raw) {
    if (utf8.encode(raw).length > maxBytes)
      throw const FormatException('Yedek çok büyük');
    final decoded = jsonDecode(raw);
    if (decoded is! Map ||
        decoded['format'] != 'kalori_hesaplayici_backup' ||
        decoded['version'] != 1)
      throw const FormatException('Desteklenmeyen yedek biçimi');
    return validateTables(decoded);
  }

  static Map<String, List<Map<String, Object?>>> validateTables(Map source) {
    final result = <String, List<Map<String, Object?>>>{};
    for (final table in tables) {
      final rows = source[table];
      if (rows is! List || rows.length > maxRows)
        throw FormatException('Eksik veya geçersiz tablo: $table');
      final unique = <String>{};
      result[table] = rows.map((value) {
        if (value is! Map) throw const FormatException('Geçersiz kayıt');
        final Map<String, Object?> row;
        switch (table) {
          case 'food_entries':
            row = _nutrition(value);
            row['created_at'] = _date(value['created_at']);
            final meal = _text(value['meal'], 'Öğün');
            if (!meals.contains(meal))
              throw const FormatException('Geçersiz öğün');
            row['meal'] = meal;
            break;
          case 'favorites':
            row = _nutrition(value);
            break;
          case 'water_entries':
            final date = _date(value['day']);
            final ml = value['ml'];
            if (ml is! int || ml < 0)
              throw const FormatException(
                'Su miktarı negatif olmayan tam sayı olmalı',
              );
            if (!unique.add(date))
              throw const FormatException('Aynı güne ait yinelenen su kaydı');
            row = {'day': date, 'ml': ml};
            break;
          case 'settings':
            final key = _text(value['key'], 'Hedef');
            final setting = _text(value['value'], 'Hedef değeri');
            if (!unique.add(key))
              throw const FormatException('Yinelenen hedef kaydı');
            if ([
              'calories',
              'protein',
              'carbs',
              'fat',
              'water_goal',
            ].contains(key)) {
              final number = double.tryParse(setting);
              if (number == null || !number.isFinite || number <= 0)
                throw const FormatException(
                  'Hedef değeri pozitif bir sayı olmalı',
                );
            }
            row = {'key': key, 'value': setting};
            break;
          case 'weight_entries':
            final kg = _number(value['kg'], 'Kilo', positive: true);
            if (kg > 500)
              throw const FormatException('Kilo 500 kg sınırını aşıyor');
            row = {'day': _date(value['day']), 'kg': kg};
            break;
          default:
            throw const FormatException('Desteklenmeyen tablo');
        }
        return row;
      }).toList();
    }
    return result;
  }

  static Map<String, Object?> _nutrition(Map source) {
    final grams = _number(source['grams'], 'Porsiyon', positive: true);
    final kcal = _number(source['kcal_per_100g'], 'Kalori');
    final protein = _number(source['protein'], 'Protein');
    final carbs = _number(source['carbs'], 'Karbonhidrat');
    final fat = _number(source['fat'], 'Yağ');
    for (final value in [kcal, protein, carbs, fat]) {
      if (!(grams * value / 100).isFinite)
        throw const FormatException(
          'Porsiyon hesaplaması sayı sınırını aşıyor',
        );
    }
    return {
      'name': _text(source['name'], 'Besin adı'),
      'grams': grams,
      'kcal_per_100g': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  static double _number(Object? value, String label, {bool positive = false}) {
    if (value is! num || !value.isFinite || (positive ? value <= 0 : value < 0))
      throw FormatException('$label geçerli bir sayı olmalı');
    return value.toDouble();
  }

  static String _text(Object? value, String label) {
    if (value is! String || value.trim().isEmpty)
      throw FormatException('$label boş olmayan bir metin olmalı');
    return value;
  }

  static String _date(Object? value) {
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value))
      throw const FormatException('Geçersiz tarih');
    final date = DateTime.tryParse(value);
    if (date == null ||
        date.year < 1 ||
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' !=
            value)
      throw const FormatException('Geçersiz tarih');
    return value;
  }
}

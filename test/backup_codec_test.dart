import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalori_hesaplayici/services/backup_codec.dart';

import 'backup_fixture.dart';

void main() {
  test('Mevcut sürümün yedeği doğrulanır ve yalnızca izinli alanlar döner', () {
    final source = sampleBackup();
    final parsed = BackupCodec.decode(jsonEncode(source));
    expect(parsed['food_entries']!.single['grams'], 120.0);
    expect(parsed['food_entries']!.single.containsKey('id'), isFalse);
    expect(parsed['settings']!.single['value'], '2200');
    expect((source['food_entries'] as List).single['id'], 1);
  });
  final invalidFood = <String, Object?>{
    'grams': '100',
    'kcal_per_100g': -1,
    'protein': null,
    'carbs': 'abc',
    'fat': false,
    'name': ' ',
    'meal': 'Bilinmeyen',
    'created_at': '2026-02-30',
  };
  for (final entry in invalidFood.entries) {
    test('Besin alanı ${entry.key} hatalıysa tüm yedek reddedilir', () {
      final backup = sampleBackup();
      (backup['food_entries'] as List).single[entry.key] = entry.value;
      expect(
        () => BackupCodec.decode(jsonEncode(backup)),
        throwsFormatException,
      );
    });
  }
  test('Gerçek artık gün kabul edilir, olmayan artık gün reddedilir', () {
    final backup = sampleBackup();
    (backup['food_entries'] as List).single['created_at'] = '2024-02-29';
    expect(() => BackupCodec.decode(jsonEncode(backup)), returnsNormally);
    (backup['food_entries'] as List).single['created_at'] = '2026-02-29';
    expect(() => BackupCodec.decode(jsonEncode(backup)), throwsFormatException);
  });
  test('Negatif veya kesirli su miktarı reddedilir', () {
    for (final value in [-1, 2.5, '250']) {
      final backup = sampleBackup();
      (backup['water_entries'] as List).single['ml'] = value;
      expect(
        () => BackupCodec.decode(jsonEncode(backup)),
        throwsFormatException,
      );
    }
  });
  test('Yinelenen su ve hedef kayıtları işlem öncesinde reddedilir', () {
    for (final table in ['water_entries', 'settings']) {
      final backup = sampleBackup();
      final rows = backup[table] as List;
      rows.add(Map<String, dynamic>.from(rows.single));
      expect(
        () => BackupCodec.decode(jsonEncode(backup)),
        throwsFormatException,
      );
    }
  });
  test('Hedef değerleri pozitif ve sonlu sayı olmalıdır', () {
    for (final value in ['0', '-1', 'NaN', 'Infinity', 'abc']) {
      final backup = sampleBackup();
      (backup['settings'] as List).single['value'] = value;
      expect(
        () => BackupCodec.decode(jsonEncode(backup)),
        throwsFormatException,
      );
    }
  });
  test('Eksik tablolar, geçersiz kilo ve farklı biçimler reddedilir', () {
    final missing = sampleBackup()..remove('favorites');
    expect(
      () => BackupCodec.decode(jsonEncode(missing)),
      throwsFormatException,
    );
    final wrong = sampleBackup()..['version'] = 2;
    expect(() => BackupCodec.decode(jsonEncode(wrong)), throwsFormatException);
    final weight = sampleBackup();
    (weight['weight_entries'] as List).single['kg'] = 501;
    expect(() => BackupCodec.decode(jsonEncode(weight)), throwsFormatException);
    expect(() => BackupCodec.decode('not-json'), throwsFormatException);
  });
  test('Hesaplama taşması ve sonlu olmayan sayılar reddedilir', () {
    final backup = sampleBackup();
    final food = (backup['food_entries'] as List).single;
    food['grams'] = 1e308;
    food['kcal_per_100g'] = 1e308;
    expect(() => BackupCodec.validateTables(backup), throwsFormatException);
    food['grams'] = double.infinity;
    expect(() => BackupCodec.validateTables(backup), throwsFormatException);
  });
}

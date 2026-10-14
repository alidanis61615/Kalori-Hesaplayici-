import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:kalori_hesaplayici/models/food.dart';
import 'package:kalori_hesaplayici/services/store.dart';

import 'backup_fixture.dart';

void main() {
  sqfliteFfiInit();
  late Store store;
  setUp(
    () => store = Store(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    ),
  );
  tearDown(() async => store.close());
  Food original() => Food(
    name: 'Korunacak',
    meal: 'Kahvaltı',
    date: '2026-10-14',
    grams: 100,
    kcal: 200,
    protein: 5,
    carbs: 10,
    fat: 5,
  );

  test('Geçersiz yedek SQLite kayıtları değişmeden reddedilir', () async {
    await store.add(original());
    await store.addWater('2026-10-14', 500);
    final valid = await store.validateBackup(jsonEncode(sampleBackup()));
    valid['food_entries']!.single['grams'] = 'abc';
    await expectLater(store.restoreBackup(valid), throwsFormatException);
    expect((await store.foods()).single.name, 'Korunacak');
    expect(await store.water('2026-10-14'), 500);
  });
  test('Veritabanı geri yükleme hatasında tüm silmeler geri alınır', () async {
    await store.add(original());
    await store.addWater('2026-10-14', 500);
    final db = await store.db;
    await db.execute(
      "CREATE TRIGGER fail_restore BEFORE INSERT ON food_entries WHEN NEW.name='blocked' BEGIN SELECT RAISE(ABORT,'blocked'); END",
    );
    final backup = sampleBackup();
    (backup['food_entries'] as List).single['name'] = 'blocked';
    final parsed = await store.validateBackup(jsonEncode(backup));
    await expectLater(
      store.restoreBackup(parsed),
      throwsA(isA<DatabaseException>()),
    );
    expect((await store.foods()).single.name, 'Korunacak');
    expect(await store.water('2026-10-14'), 500);
  });
  test('JSON yedek SQLite verilerini ve hedeflerini geri getirir', () async {
    await store.add(original());
    await store.addWater('2026-10-14', 500);
    await store.setSetting('calories', '2100');
    final backup = await store.exportBackup();
    await store.delete((await store.foods()).single.id!);
    await store.setSetting('calories', '1900');
    await store.restoreBackup(await store.validateBackup(backup));
    expect((await store.foods()).single.energy, 200);
    expect(await store.getSetting('calories'), '2100');
    expect(await store.water('2026-10-14'), 500);
  });
}

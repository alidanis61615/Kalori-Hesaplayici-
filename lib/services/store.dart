import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/food.dart';
import '../models/weight_record.dart';
import 'backup_codec.dart';

class Store {
  Store({this.factory, this.databasePath});
  static final instance = Store();
  final DatabaseFactory? factory;
  final String? databasePath;
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final activeFactory = factory ?? databaseFactory;
    final path =
        databasePath ??
        p.join(await activeFactory.getDatabasesPath(), 'calorie_tracker.db');
    _db = await activeFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (d, v) async {
          await d.execute(
            'CREATE TABLE food_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,created_at TEXT NOT NULL,meal TEXT NOT NULL DEFAULT "Diğer",protein REAL NOT NULL DEFAULT 0,carbs REAL NOT NULL DEFAULT 0,fat REAL NOT NULL DEFAULT 0)',
          );
          await d.execute(
            'CREATE TABLE water_entries (day TEXT PRIMARY KEY,ml INTEGER NOT NULL)',
          );
          await d.execute(
            'CREATE TABLE settings (key TEXT PRIMARY KEY,value TEXT NOT NULL)',
          );
          await d.execute(
            'CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,protein REAL NOT NULL,carbs REAL NOT NULL,fat REAL NOT NULL)',
          );
          await d.execute(
            'CREATE TABLE weight_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,day TEXT NOT NULL,kg REAL NOT NULL CHECK(kg>0))',
          );
        },
        onUpgrade: (d, old, v) async {
          if (old < 2) {
            for (final col in [
              'meal TEXT NOT NULL DEFAULT "Diğer"',
              'protein REAL NOT NULL DEFAULT 0',
              'carbs REAL NOT NULL DEFAULT 0',
              'fat REAL NOT NULL DEFAULT 0',
            ]) {
              await d.execute('ALTER TABLE food_entries ADD COLUMN $col');
            }
            await d.execute(
              'CREATE TABLE water_entries (day TEXT PRIMARY KEY,ml INTEGER NOT NULL)',
            );
            await d.execute(
              'CREATE TABLE settings (key TEXT PRIMARY KEY,value TEXT NOT NULL)',
            );
          }
          if (old < 3) {
            await d.execute(
              'CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,grams REAL NOT NULL,kcal_per_100g REAL NOT NULL,protein REAL NOT NULL,carbs REAL NOT NULL,fat REAL NOT NULL)',
            );
          }
          if (old < 4) {
            await d.execute(
              'CREATE TABLE weight_entries (id INTEGER PRIMARY KEY AUTOINCREMENT,day TEXT NOT NULL,kg REAL NOT NULL CHECK(kg>0))',
            );
          }
        },
      ),
    );
    return _db!;
  }

  Future<String> exportBackup() async {
    final database = await db;
    final tables = [
      'food_entries',
      'water_entries',
      'settings',
      'favorites',
      'weight_entries',
    ];
    final data = <String, dynamic>{
      'format': 'kalori_hesaplayici_backup',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
    };
    for (final table in tables) {
      data[table] = await database.query(table);
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<Map<String, List<Map<String, Object?>>>> validateBackup(
    String raw,
  ) async => BackupCodec.decode(raw);
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> restoreBackup(
    Map<String, List<Map<String, Object?>>> backup,
  ) async {
    final validated = BackupCodec.validateTables(backup);
    final database = await db;
    await database.transaction((txn) async {
      for (final table in [
        'food_entries',
        'water_entries',
        'settings',
        'favorites',
        'weight_entries',
      ]) {
        await txn.delete(table);
        for (final record in validated[table]!) {
          await txn.insert(table, record);
        }
      }
    });
  }

  Future<List<WeightRecord>> weights() async {
    final rows = await (await db).query(
      'weight_entries',
      orderBy: 'day DESC,id DESC',
    );
    return rows
        .map(
          (r) => WeightRecord(
            id: r['id'] as int,
            date: r['day'] as String,
            kg: (r['kg'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<void> addWeight(String date, double kg) async {
    if (!kg.isFinite || kg <= 0 || kg > 500) {
      throw ArgumentError('Geçerli bir kilo girin');
    }
    await (await db).insert('weight_entries', {'day': date, 'kg': kg});
  }

  Future<void> deleteWeight(int id) async {
    await (await db).delete('weight_entries', where: 'id=?', whereArgs: [id]);
  }

  Future<List<Food>> foods() async => (await (await db).query(
    'food_entries',
    orderBy: 'created_at DESC,id DESC',
  )).map(Food.fromMap).toList();
  Future<void> add(Food f) async {
    await (await db).insert('food_entries', f.toMap());
  }

  Future<List<Food>> favorites() async =>
      (await (await db).query('favorites', orderBy: 'name COLLATE NOCASE'))
          .map(
            (m) => Food(
              id: m['id'] as int,
              name: m['name'] as String,
              meal: 'Kahvaltı',
              date: '',
              grams: (m['grams'] as num).toDouble(),
              kcal: (m['kcal_per_100g'] as num).toDouble(),
              protein: (m['protein'] as num).toDouble(),
              carbs: (m['carbs'] as num).toDouble(),
              fat: (m['fat'] as num).toDouble(),
            ),
          )
          .toList();
  Future<void> saveFavorite(Food f) async {
    await (await db).insert('favorites', {
      'name': f.name,
      'grams': f.grams,
      'kcal_per_100g': f.kcal,
      'protein': f.protein,
      'carbs': f.carbs,
      'fat': f.fat,
    });
  }

  Future<void> removeFavorite(int id) async {
    await (await db).delete('favorites', where: 'id=?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    await (await db).delete('food_entries', where: 'id=?', whereArgs: [id]);
  }

  Future<void> update(Food f) async {
    if (f.id == null) throw ArgumentError('Missing food id');
    await (await db).update(
      'food_entries',
      f.toMap(),
      where: 'id=?',
      whereArgs: [f.id],
    );
  }

  Future<int> water(String date) async {
    final rows = await (await db).query(
      'water_entries',
      where: 'day=?',
      whereArgs: [date],
    );
    return rows.isEmpty ? 0 : rows.first['ml'] as int;
  }

  Future<Map<String, int>> waterHistory() async {
    final rows = await (await db).query('water_entries');
    return {for (final row in rows) row['day'] as String: row['ml'] as int};
  }

  Future<void> addWater(String date, int ml) async {
    final total = await water(date) + ml;
    await (await db).insert('water_entries', {
      'day': date,
      'ml': total,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeWater(String date, int ml) async {
    final total = ((await water(date)) - ml).clamp(0, 1000000);
    await (await db).insert('water_entries', {
      'day': date,
      'ml': total,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final rows = await (await db).query(
      'settings',
      where: 'key=?',
      whereArgs: [key],
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    await (await db).insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalorieApp());
}

class FoodEntry {
  final int? id;
  final String name;
  final double grams;
  final double kcalPer100g;
  final DateTime createdAt;

  const FoodEntry({this.id, required this.name, required this.grams,
    required this.kcalPer100g, required this.createdAt});

  double get calories => grams * kcalPer100g / 100;

  Map<String, Object?> toMap() => {
    'name': name, 'grams': grams, 'kcal_per_100g': kcalPer100g,
    'created_at': createdAt.toIso8601String(),
  };

  factory FoodEntry.fromMap(Map<String, Object?> m) => FoodEntry(
    id: m['id'] as int, name: m['name'] as String,
    grams: (m['grams'] as num).toDouble(),
    kcalPer100g: (m['kcal_per_100g'] as num).toDouble(),
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}

class FoodDatabase {
  FoodDatabase._();
  static final instance = FoodDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(p.join(await getDatabasesPath(), 'calorie_tracker.db'),
      version: 1, onCreate: (db, version) async {
        await db.execute('CREATE TABLE food_entries (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, grams REAL NOT NULL, kcal_per_100g REAL NOT NULL, created_at TEXT NOT NULL)');
      });
    return _db!;
  }

  Future<List<FoodEntry>> all() async {
    final db = await database;
    final rows = await db.query('food_entries', orderBy: 'created_at DESC, id DESC');
    return rows.map(FoodEntry.fromMap).toList();
  }

  Future<void> add(FoodEntry entry) async {
    final db = await database;
    await db.insert('food_entries', entry.toMap());
  }

  Future<void> remove(int id) async {
    final db = await database;
    await db.delete('food_entries', where: 'id = ?', whereArgs: [id]);
  }
}

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kalori Hesaplayıcı',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const CalorieHome(),
  );
}

class CalorieHome extends StatefulWidget {
  const CalorieHome({super.key});

  @override
  State<CalorieHome> createState() => _CalorieHomeState();
}

class _CalorieHomeState extends State<CalorieHome> {
  List<FoodEntry> entries = [];
  DateTime selectedDate = DateTime.now();
  String? error;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final result = await FoodDatabase.instance.all();
      if (mounted) setState(() { entries = result; error = null; });
    } catch (e) {
      if (mounted) setState(() => error = 'Kayıtlar okunamadı: $e');
    }
  }

  bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> changeDate() async {
    final date = await showDatePicker(context: context, initialDate: selectedDate,
      firstDate: DateTime(2020), lastDate: DateTime.now());
    if (date != null && mounted) setState(() => selectedDate = date);
  }

  Future<void> addFood() async {
    final name = TextEditingController();
    final grams = TextEditingController();
    final kcal = TextEditingController();
    final form = GlobalKey<FormState>();
    final result = await showDialog<FoodEntry>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yiyecek ekle'),
        content: Form(key: form, child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Yiyecek adı'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Yiyecek adı girin' : null),
            TextFormField(controller: grams, decoration: const InputDecoration(labelText: 'Porsiyon (gram)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return n == null || !n.isFinite || n <= 0 ? 'Geçerli gram girin' : null;
              }),
            TextFormField(controller: kcal, decoration: const InputDecoration(labelText: '100 gramdaki kalori (kcal)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return n == null || !n.isFinite || n < 0 ? 'Geçerli kalori girin' : null;
              }),
          ]),
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
          FilledButton(onPressed: () {
            if (!form.currentState!.validate()) return;
            Navigator.pop(dialogContext, FoodEntry(name: name.text.trim(),
              grams: double.parse(grams.text.replaceAll(',', '.')),
              kcalPer100g: double.parse(kcal.text.replaceAll(',', '.')),
              createdAt: DateTime.now()));
          }, child: const Text('Kaydet')),
        ],
      ),
    );
    name.dispose();
    grams.dispose();
    kcal.dispose();
    if (result == null) return;
    try {
      await FoodDatabase.instance.add(result);
      if (!mounted) return;
      setState(() => selectedDate = DateTime.now());
      await refresh();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt eklenemedi: $e')));
    }
  }

  Future<void> deleteFood(FoodEntry entry) async {
    if (entry.id == null) return;
    await FoodDatabase.instance.remove(entry.id!);
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    final today = entries.where((e) => sameDay(e.createdAt, selectedDate)).toList();
    final total = today.fold<double>(0, (sum, e) => sum + e.calories);
    final dateLabel = '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}';
    return Scaffold(
      appBar: AppBar(title: const Text('Kalori Hesaplayıcı')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addFood, icon: const Icon(Icons.add), label: const Text('Yiyecek ekle')),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text('Seçili gün: $dateLabel'),
            const SizedBox(height: 8),
            Text('${total.toStringAsFixed(1)} kcal',
              style: Theme.of(context).textTheme.headlineMedium),
            const Text('Günlük toplam kalori'),
            TextButton.icon(onPressed: changeDate,
              icon: const Icon(Icons.calendar_month), label: const Text('Tarih seç')),
          ]))),
        if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
        Expanded(child: today.isEmpty
          ? const Center(child: Text('Bu güne ait yiyecek kaydı yok'))
          : ListView.builder(itemCount: today.length, itemBuilder: (context, i) {
            final food = today[i];
            return Card(child: ListTile(
              title: Text(food.name),
              subtitle: Text('${food.grams.toStringAsFixed(0)} g · 100 g için ${food.kcalPer100g.toStringAsFixed(1)} kcal'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${food.calories.toStringAsFixed(1)} kcal'),
                IconButton(onPressed: () => deleteFood(food),
                  icon: const Icon(Icons.delete_outline), tooltip: 'Sil'),
              ]),
            ));
          })),
      ])),
    );
  }
}

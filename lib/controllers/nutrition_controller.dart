import 'package:flutter/foundation.dart';

import '../models/food.dart';
import '../models/weight_record.dart';
import '../services/store.dart';
import '../utils/date.dart';

/// Owns the selected day and loaded data, independently of the UI widgets.
class NutritionController extends ChangeNotifier {
  NutritionController({required this.store, DateTime? date})
    : selected = date ?? DateTime.now();
  final Store store;
  DateTime selected;
  List<Food> foods = [];
  List<WeightRecord> weights = [];
  Map<String, int> waterDays = {};
  int tab = 0, water = 0, trendDays = 30;
  double target = 2200, pt = 120, ct = 260, ft = 70, waterGoal = 2000;
  String filter = 'Tümü';
  String? error;
  bool loaded = false;
  bool _disposed = false;
  Future<void> pending = Future.value();
  static const settingKeys = [
    'calories',
    'protein',
    'carbs',
    'fat',
    'water_goal',
  ];
  final meals = const ['Kahvaltı', 'Öğle', 'Akşam', 'Atıştırmalık', 'Diğer'];
  List<Food> get today =>
      foods.where((food) => food.date == day(selected)).toList();
  double get calories => today.fold(0, (total, food) => total + food.energy);
  double get protein => today.fold(0, (total, food) => total + food.p);
  double get carbs => today.fold(0, (total, food) => total + food.c);
  double get fat => today.fold(0, (total, food) => total + food.f);

  void _changed() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void setTab(int value) {
    tab = value;
    _changed();
  }

  void setFilter(String value) {
    filter = value;
    _changed();
  }

  void setTrendDays(int value) {
    trendDays = value;
    _changed();
  }

  Future<void> changeDay(int delta) async {
    selected = selected.add(Duration(days: delta));
    await reload();
  }

  Future<void> reload() async {
    final requestedDay = day(selected);
    try {
      final entries = await store.foods();
      final waterValue = await store.water(requestedDay);
      final records = await store.weights();
      final history = await store.waterHistory();
      final settings = await Future.wait(settingKeys.map(store.getSetting));
      if (_disposed || requestedDay != day(selected)) return;
      foods = entries;
      water = waterValue;
      weights = records;
      waterDays = history;
      target = double.tryParse(settings[0] ?? '') ?? 2200;
      pt = double.tryParse(settings[1] ?? '') ?? 120;
      ct = double.tryParse(settings[2] ?? '') ?? 260;
      ft = double.tryParse(settings[3] ?? '') ?? 70;
      waterGoal = double.tryParse(settings[4] ?? '') ?? 2000;
      error = null;
      loaded = true;
    } catch (_) {
      error = 'Veriler yüklenemedi. Yeniden deneyebilirsiniz.';
    }
    _changed();
  }

  Future<void> run(Future<void> Function() operation) {
    pending = _persist(operation);
    return pending;
  }

  Future<void> _persist(Future<void> Function() operation) async {
    await operation();
    await reload();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

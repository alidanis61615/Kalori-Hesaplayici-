import '../models/food.dart';

/// UI actions are provided by the home coordinator; tabs do not own dialogs.
class NutritionActions {
  const NutritionActions({
    required this.addFood,
    required this.searchCatalog,
    required this.savedFoods,
    required this.copyMealsToTomorrow,
    required this.addWeightRecord,
    required this.editGoals,
    required this.exportBackup,
    required this.restoreBackup,
    required this.reportError,
  });
  final Future<void> Function([Food? food]) addFood;
  final Future<void> Function() searchCatalog, savedFoods, copyMealsToTomorrow;
  final Future<void> Function() addWeightRecord,
      editGoals,
      exportBackup,
      restoreBackup;
  final void Function(Object error) reportError;
}

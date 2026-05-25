import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/core/services/local_storage_service.dart';

final dashboardSelectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dashboardWaterIntakeProvider = FutureProvider<int>((ref) async {
  final date = ref.watch(dashboardSelectedDateProvider);
  return LocalStorageService.loadWaterIntake(date);
});

typedef DashboardMacroTotals = ({
  int calories,
  int protein,
  int carbs,
  int fat,
});

final dashboardMacroTotalsProvider = Provider<DashboardMacroTotals>((ref) {
  final foodLogs = ref.watch(foodLogProvider);
  final selectedDate = ref.watch(dashboardSelectedDateProvider);

  var calories = 0;
  var protein = 0;
  var carbs = 0;
  var fat = 0;

  for (final entry in foodLogs) {
    if (entry.loggedAt.year == selectedDate.year &&
        entry.loggedAt.month == selectedDate.month &&
        entry.loggedAt.day == selectedDate.day) {
      calories += entry.calories;
      protein += entry.protein;
      carbs += entry.carbs;
      fat += entry.fat;
    }
  }

  return (calories: calories, protein: protein, carbs: carbs, fat: fat);
});

final mealEntriesByTypeProvider = Provider<Map<MealType, List<FoodEntry>>>((
  ref,
) {
  final foodLogs = ref.watch(foodLogProvider);
  final selectedDate = ref.watch(dashboardSelectedDateProvider);
  
  final groupedEntries = <MealType, List<FoodEntry>>{
    for (final mealType in MealType.values) mealType: <FoodEntry>[],
  };

  for (final entry in foodLogs) {
    if (entry.loggedAt.year == selectedDate.year &&
        entry.loggedAt.month == selectedDate.month &&
        entry.loggedAt.day == selectedDate.day) {
      groupedEntries[entry.mealType]!.add(entry);
    }
  }

  return groupedEntries;
});

final remainingCaloriesProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  final totals = ref.watch(dashboardMacroTotalsProvider);

  return (profile.calorieTarget - totals.calories).clamp(0, 9999);
});

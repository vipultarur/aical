import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/shared/models/food_entry.dart';
import 'package:calcount/shared/models/meal_type.dart';

class FoodLogNotifier extends StateNotifier<List<FoodEntry>> {
  FoodLogNotifier() : super(_initialMockEntries());

  static List<FoodEntry> _initialMockEntries() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      FoodEntry(
        id: 'mock_1',
        name: 'Oatmeal with Berries',
        brand: 'Homemade',
        calories: 285,
        protein: 8,
        carbs: 52,
        fat: 4,
        fiber: 6,
        servingAmount: 1,
        servingUnit: 'serving',
        mealType: MealType.breakfast,
        loggedAt: today.add(const Duration(hours: 8)),
      ),
      FoodEntry(
        id: 'mock_2',
        name: 'Black Coffee',
        brand: 'Starbucks',
        calories: 5,
        protein: 0,
        carbs: 1,
        fat: 0,
        fiber: 0,
        servingAmount: 1,
        servingUnit: 'cup',
        mealType: MealType.breakfast,
        loggedAt: today.add(const Duration(hours: 8, minutes: 15)),
      ),
      FoodEntry(
        id: 'mock_3',
        name: 'Banana',
        brand: 'Organic',
        calories: 90,
        protein: 1,
        carbs: 23,
        fat: 0,
        fiber: 3,
        servingAmount: 1,
        servingUnit: 'serving',
        mealType: MealType.snacks,
        loggedAt: today.add(const Duration(hours: 15)),
      ),
      FoodEntry(
        id: 'mock_4',
        name: 'Almonds',
        brand: 'Kirkland Signature',
        calories: 190,
        protein: 6,
        carbs: 6,
        fat: 16,
        fiber: 3,
        servingAmount: 30,
        servingUnit: 'g',
        mealType: MealType.snacks,
        loggedAt: today.add(const Duration(hours: 16)),
      ),
    ];
  }

  void addFood(FoodEntry entry) {
    state = [...state, entry];
  }

  void removeFood(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
}

final foodLogProvider = StateNotifierProvider<FoodLogNotifier, List<FoodEntry>>(
  (ref) {
    return FoodLogNotifier();
  },
);

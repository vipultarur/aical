import 'package:equatable/equatable.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';

/// Search result model used by food logging flows.
final class FoodSearchItem extends Equatable {
  const FoodSearchItem({
    required this.name,
    required this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.servingAmount,
    required this.servingUnit,
  });

  final String name;
  final String brand;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final double servingAmount;
  final String servingUnit;

  factory FoodSearchItem.fromJson(Map<String, dynamic> json) {
    return FoodSearchItem(
      name: json['name'] as String,
      brand: json['brand'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      fiber: json['fiber'] as int,
      servingAmount: (json['servingAmount'] as num).toDouble(),
      servingUnit: json['servingUnit'] as String,
    );
  }

  FoodSearchItem copyWith({
    String? name,
    String? brand,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    double? servingAmount,
    String? servingUnit,
  }) {
    return FoodSearchItem(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      servingAmount: servingAmount ?? this.servingAmount,
      servingUnit: servingUnit ?? this.servingUnit,
    );
  }

  FoodEntry toFoodEntry({
    required String id,
    required MealType mealType,
    double servings = 1,
    String? overrideBrand,
  }) {
    return FoodEntry.mock(
      id: id,
      name: name,
      brand: overrideBrand ?? brand,
      calories: (calories * servings).round(),
      protein: (protein * servings).round(),
      carbs: (carbs * servings).round(),
      fat: (fat * servings).round(),
      fiber: (fiber * servings).round(),
      servingAmount: servingAmount * servings,
      servingUnit: servingUnit,
      mealType: mealType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servingAmount': servingAmount,
      'servingUnit': servingUnit,
    };
  }

  @override
  List<Object?> get props => [
    name,
    brand,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    servingAmount,
    servingUnit,
  ];
}

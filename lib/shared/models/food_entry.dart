import 'package:calcount/shared/models/meal_type.dart';

/// Logged food item for a specific meal slot and time.
final class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    this.brand = '',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    required this.servingAmount,
    required this.servingUnit,
    required this.mealType,
    required this.loggedAt,
  });

  final String id;
  final String name;
  final String brand;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final double servingAmount;
  final String servingUnit;
  final MealType mealType;
  final DateTime loggedAt;

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String? ?? '',
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      fiber: json['fiber'] as int? ?? 0,
      servingAmount: (json['servingAmount'] as num).toDouble(),
      servingUnit: json['servingUnit'] as String,
      mealType: MealType.fromName(json['mealType'] as String),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }

  factory FoodEntry.mock({
    required String id,
    required String name,
    String brand = '',
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    int fiber = 0,
    required double servingAmount,
    required String servingUnit,
    required MealType mealType,
  }) {
    return FoodEntry(
      id: id,
      name: name,
      brand: brand,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      servingAmount: servingAmount,
      servingUnit: servingUnit,
      mealType: mealType,
      loggedAt: DateTime.now(),
    );
  }

  FoodEntry copyWith({
    String? id,
    String? name,
    String? brand,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    double? servingAmount,
    String? servingUnit,
    MealType? mealType,
    DateTime? loggedAt,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      servingAmount: servingAmount ?? this.servingAmount,
      servingUnit: servingUnit ?? this.servingUnit,
      mealType: mealType ?? this.mealType,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servingAmount': servingAmount,
      'servingUnit': servingUnit,
      'mealType': mealType.name,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FoodEntry(id: $id, name: $name, calories: $calories, mealType: $mealType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FoodEntry &&
        other.id == id &&
        other.name == name &&
        other.brand == brand &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat &&
        other.fiber == fiber &&
        other.servingAmount == servingAmount &&
        other.servingUnit == servingUnit &&
        other.mealType == mealType &&
        other.loggedAt == loggedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    servingAmount,
    servingUnit,
    mealType,
    loggedAt,
  );
}

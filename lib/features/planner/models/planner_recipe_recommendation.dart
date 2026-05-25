import 'package:equatable/equatable.dart';
import 'package:calcount/common/models/meal_type.dart';

/// Planner card configuration for a single suggested recipe.
final class PlannerRecipeRecommendation extends Equatable {
  const PlannerRecipeRecommendation({
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.slot,
    required this.emoji,
  });

  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final MealType slot;
  final String emoji;

  bool matchesFilter(String filter) {
    return filter == 'All' || category == filter;
  }

  String get macroSummary => 'P: ${protein}g · C: ${carbs}g · F: ${fat}g';

  PlannerRecipeRecommendation copyWith({
    String? name,
    String? category,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    MealType? slot,
    String? emoji,
  }) {
    return PlannerRecipeRecommendation(
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      slot: slot ?? this.slot,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  List<Object?> get props => [
    name,
    category,
    calories,
    protein,
    carbs,
    fat,
    slot,
    emoji,
  ];
}

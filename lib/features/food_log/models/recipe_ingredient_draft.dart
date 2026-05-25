import 'package:equatable/equatable.dart';

/// Mutable recipe ingredient data used by the recipe builder UI.
final class RecipeIngredientDraft extends Equatable {
  const RecipeIngredientDraft({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  String get macroSummary => 'P: ${protein}g · C: ${carbs}g · F: ${fat}g';

  RecipeIngredientDraft copyWith({
    String? name,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return RecipeIngredientDraft(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  @override
  List<Object?> get props => [name, calories, protein, carbs, fat];
}

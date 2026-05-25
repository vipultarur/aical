/// Mutable recipe ingredient data used by the recipe builder UI.
final class RecipeIngredientDraft {
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
  String toString() {
    return 'RecipeIngredientDraft(name: $name, calories: $calories)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RecipeIngredientDraft &&
        other.name == name &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat;
  }

  @override
  int get hashCode => Object.hash(name, calories, protein, carbs, fat);
}

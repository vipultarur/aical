import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/food_log/models/recipe_ingredient_draft.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_back_button.dart';
import 'package:calcount/common/widgets/app_button.dart';
import 'package:calcount/common/widgets/app_card.dart';
import 'package:calcount/common/widgets/app_empty_state.dart';
import 'package:calcount/common/widgets/app_snack_bar.dart';
import 'package:calcount/common/widgets/app_text_field.dart';

/// Lets the user assemble a custom recipe and log it into the food diary.
class RecipeBuilderScreen extends ConsumerStatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  ConsumerState<RecipeBuilderScreen> createState() =>
      _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends ConsumerState<RecipeBuilderScreen> {
  final TextEditingController _recipeNameController = TextEditingController(
    text: 'Healthy Avocado Salmon Bowl',
  );
  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _ingredientCalorieController =
      TextEditingController();
  final TextEditingController _ingredientProteinController =
      TextEditingController();
  final TextEditingController _ingredientCarbController =
      TextEditingController();
  final TextEditingController _ingredientFatController =
      TextEditingController();

  final List<RecipeIngredientDraft> _ingredients = [
    const RecipeIngredientDraft(
      name: 'Grilled Salmon',
      calories: 280,
      protein: 34,
      carbs: 0,
      fat: 15,
    ),
    const RecipeIngredientDraft(
      name: 'Half Avocado',
      calories: 160,
      protein: 2,
      carbs: 8,
      fat: 15,
    ),
    const RecipeIngredientDraft(
      name: 'Brown Rice',
      calories: 215,
      protein: 5,
      carbs: 45,
      fat: 2,
    ),
  ];

  @override
  void dispose() {
    _recipeNameController.dispose();
    _ingredientNameController.dispose();
    _ingredientCalorieController.dispose();
    _ingredientProteinController.dispose();
    _ingredientCarbController.dispose();
    _ingredientFatController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final name = _ingredientNameController.text.trim();
    final calories = int.tryParse(_ingredientCalorieController.text) ?? 0;
    final protein = int.tryParse(_ingredientProteinController.text) ?? 0;
    final carbs = int.tryParse(_ingredientCarbController.text) ?? 0;
    final fat = int.tryParse(_ingredientFatController.text) ?? 0;

    if (name.isEmpty) {
      AppSnackBar.showError(
        context,
        message: 'Please enter an ingredient name.',
      );
      return;
    }

    setState(() {
      _ingredients.add(
        RecipeIngredientDraft(
          name: name,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
        ),
      );
      _ingredientNameController.clear();
      _ingredientCalorieController.clear();
      _ingredientProteinController.clear();
      _ingredientCarbController.clear();
      _ingredientFatController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _onSaveRecipe() {
    if (_ingredients.isEmpty) {
      AppSnackBar.showError(
        context,
        message: 'Please add at least one ingredient.',
      );
      return;
    }

    final totals = _nutritionTotals;
    final recipeName = _recipeNameController.text.trim().isEmpty
        ? 'Custom Recipe'
        : _recipeNameController.text.trim();

    final entry = FoodEntry.mock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: recipeName,
      brand: 'My Recipes',
      calories: totals.calories,
      protein: totals.protein,
      carbs: totals.carbs,
      fat: totals.fat,
      servingAmount: 1,
      servingUnit: 'Bowl',
      mealType: MealType.lunch,
    );

    ref.read(foodLogProvider.notifier).addFood(entry);
    AppSnackBar.showSuccess(
      context,
      message: 'Saved and logged "$recipeName" as Lunch!',
    );
    context.go(AppRoutes.dashboard);
  }

  ({int calories, int protein, int carbs, int fat}) get _nutritionTotals {
    var calories = 0;
    var protein = 0;
    var carbs = 0;
    var fat = 0;

    for (final ingredient in _ingredients) {
      calories += ingredient.calories;
      protein += ingredient.protein;
      carbs += ingredient.carbs;
      fat += ingredient.fat;
    }

    return (calories: calories, protein: protein, carbs: carbs, fat: fat);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totals = _nutritionTotals;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          'Recipe Builder',
          style: AppTypography.headingLg(color: colors.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Recipe Name',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              SizedBox(height: AppDimensions.sm),
              AppTextField(
                controller: _recipeNameController,
                hint: 'Enter recipe name',
                prefix: const Icon(LucideIcons.menu),
              ),
              SizedBox(height: AppDimensions.xxl),
              _RecipeNutritionSummary(totals: totals),
              SizedBox(height: AppDimensions.xxxl),
              _IngredientComposer(
                ingredientNameController: _ingredientNameController,
                ingredientCalorieController: _ingredientCalorieController,
                ingredientProteinController: _ingredientProteinController,
                ingredientCarbController: _ingredientCarbController,
                ingredientFatController: _ingredientFatController,
                onAddIngredient: _addIngredient,
              ),
              SizedBox(height: AppDimensions.xxxl),
              _IngredientList(
                ingredients: _ingredients,
                onRemoveIngredient: _removeIngredient,
              ),
              SizedBox(height: AppDimensions.jumbo),
              AppButton.primary(
                label: 'Save & Log Custom Recipe',
                onPressed: _onSaveRecipe,
              ),
              SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeNutritionSummary extends StatelessWidget {
  const _RecipeNutritionSummary({required this.totals});

  final ({int calories, int protein, int carbs, int fat}) totals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      color: colors.primaryContainer.withValues(alpha: 0.12),
      borderColor: colors.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text(
            'AGGREGATED NUTRITION PREVIEW',
            style: AppTypography.labelSm(color: colors.primary),
          ),
          SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryStat(
                label: 'Calories',
                value: '${totals.calories} kcal',
                color: AppColors.greenLeaf,
              ),
              _SummaryStat(
                label: 'Protein',
                value: '${totals.protein}g',
                color: AppColors.macroProtein,
              ),
              _SummaryStat(
                label: 'Carbs',
                value: '${totals.carbs}g',
                color: AppColors.macroCarbs,
              ),
              _SummaryStat(
                label: 'Fats',
                value: '${totals.fat}g',
                color: AppColors.macroFat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IngredientComposer extends StatelessWidget {
  const _IngredientComposer({
    required this.ingredientNameController,
    required this.ingredientCalorieController,
    required this.ingredientProteinController,
    required this.ingredientCarbController,
    required this.ingredientFatController,
    required this.onAddIngredient,
  });

  final TextEditingController ingredientNameController;
  final TextEditingController ingredientCalorieController;
  final TextEditingController ingredientProteinController;
  final TextEditingController ingredientCarbController;
  final TextEditingController ingredientFatController;
  final VoidCallback onAddIngredient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add Ingredient Component',
          style: AppTypography.headingSm(color: colors.onSurface),
        ),
        SizedBox(height: AppDimensions.md),
        AppCard(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Column(
            children: [
              AppTextField(
                controller: ingredientNameController,
                label: 'Ingredient Name',
                hint: 'e.g. Avocado slice',
              ),
              SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: ingredientCalorieController,
                      label: 'Cal (kcal)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: AppTextField(
                      controller: ingredientProteinController,
                      label: 'P (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: AppTextField(
                      controller: ingredientCarbController,
                      label: 'C (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: AppTextField(
                      controller: ingredientFatController,
                      label: 'F (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.lg),
              AppButton.icon(
                label: 'Add Component',
                onPressed: onAddIngredient,
                icon: const Icon(LucideIcons.plus, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({
    required this.ingredients,
    required this.onRemoveIngredient,
  });

  final List<RecipeIngredientDraft> ingredients;
  final ValueChanged<int> onRemoveIngredient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recipe Ingredients (${ingredients.length})',
          style: AppTypography.headingSm(color: colors.onSurface),
        ),
        SizedBox(height: AppDimensions.md),
        if (ingredients.isEmpty)
          const AppEmptyState(
            title: 'No ingredients added yet.',
            subtitle: 'Add components above to build your custom recipe.',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];

              return AppCard(
                margin: EdgeInsets.only(bottom: AppDimensions.sm),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    child: Icon(
                      LucideIcons.coffee,
                      color: colors.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    ingredient.name,
                    style: AppTypography.bodyLg(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    ingredient.macroSummary,
                    style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${ingredient.calories} cal',
                        style: AppTypography.numeralSm(
                          color: AppColors.amberWarm,
                        ),
                      ),
                      SizedBox(width: AppDimensions.sm),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.trash2,
                          color: AppColors.coralAlert,
                        ),
                        onPressed: () => onRemoveIngredient(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.labelSm(color: color)),
        SizedBox(height: AppDimensions.xs),
        Text(value, style: AppTypography.numeralSm(color: color)),
      ],
    );
  }
}

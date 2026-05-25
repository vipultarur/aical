import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/planner/models/planner_recipe_recommendation.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_button.dart';
import 'package:calcount/common/widgets/app_card.dart';
import 'package:calcount/common/widgets/app_empty_state.dart';
import 'package:calcount/common/widgets/app_section_header.dart';
import 'package:calcount/common/widgets/app_snack_bar.dart';

/// Shows weekly meal suggestions and lets the user log them quickly.
class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _filters = [
    'All',
    'Vegan',
    'Keto',
    'High Protein',
    'Vegetarian',
  ];

  static const List<PlannerRecipeRecommendation> _recommendations = [
    PlannerRecipeRecommendation(
      name: 'Berry Oat Parfait',
      category: 'High Protein',
      calories: 310,
      protein: 16,
      carbs: 42,
      fat: 6,
      slot: MealType.breakfast,
      emoji: '🍓',
    ),
    PlannerRecipeRecommendation(
      name: 'Keto Egg Scramble',
      category: 'Keto',
      calories: 340,
      protein: 22,
      carbs: 2,
      fat: 26,
      slot: MealType.breakfast,
      emoji: '🍳',
    ),
    PlannerRecipeRecommendation(
      name: 'Salmon Avocado Salad',
      category: 'High Protein',
      calories: 460,
      protein: 36,
      carbs: 8,
      fat: 32,
      slot: MealType.lunch,
      emoji: '🥗',
    ),
    PlannerRecipeRecommendation(
      name: 'Mediterranean Chickpea Bowl',
      category: 'Vegetarian',
      calories: 410,
      protein: 14,
      carbs: 62,
      fat: 12,
      slot: MealType.lunch,
      emoji: '🧆',
    ),
    PlannerRecipeRecommendation(
      name: 'Grilled Tofu Stir Fry',
      category: 'Vegan',
      calories: 320,
      protein: 18,
      carbs: 24,
      fat: 16,
      slot: MealType.dinner,
      emoji: '🍲',
    ),
    PlannerRecipeRecommendation(
      name: 'Sirloin Steak & Asparagus',
      category: 'Keto',
      calories: 520,
      protein: 42,
      carbs: 4,
      fat: 36,
      slot: MealType.dinner,
      emoji: '🥩',
    ),
  ];

  String _selectedDay = 'Monday';
  String _selectedFilter = 'High Protein';

  void _onQuickLogRecipe(PlannerRecipeRecommendation recipe) {
    final entry = FoodEntry.mock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: recipe.name,
      brand: 'Planned Recipes',
      calories: recipe.calories,
      protein: recipe.protein,
      carbs: recipe.carbs,
      fat: recipe.fat,
      servingAmount: 1,
      servingUnit: 'Serving',
      mealType: recipe.slot,
    );

    ref.read(foodLogProvider.notifier).addFood(entry);
    AppSnackBar.showSuccess(
      context,
      message:
          'Logged "${recipe.name}" directly to ${entry.mealType.displayName}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filteredRecipes = _recommendations.where((recipe) {
      return recipe.matchesFilter(_selectedFilter);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weekly Planner',
          style: AppTypography.headingXl(color: colors.onSurface),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlannerDaySelector(
              days: _days,
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() => _selectedDay = day);
              },
            ),
            SizedBox(height: AppDimensions.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              child: _PlannerFilterBar(
                filters: _filters,
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
            ),
            Divider(height: AppDimensions.xxxl),
            Expanded(
              child: filteredRecipes.isEmpty
                  ? AppEmptyState(
                      title: 'No suggestions found',
                      subtitle:
                          'Try selecting another preference filter to load meal concepts.',
                      icon: Text(
                        '🥗',
                        style: TextStyle(fontSize: AppDimensions.font(56)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredRecipes.length,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.xl,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        return _PlannerRecipeCard(
                          recipe: recipe,
                          onQuickLog: () => _onQuickLogRecipe(recipe),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerDaySelector extends StatelessWidget {
  const _PlannerDaySelector({
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final List<String> days;
  final String selectedDay;
  final ValueChanged<String> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.hero,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selectedDay;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.xs),
            child: ChoiceChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onDaySelected(day);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _PlannerFilterBar extends StatelessWidget {
  const _PlannerFilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Text(
          'Preferences: ',
          style: AppTypography.labelSm(color: colors.onSurfaceVariant),
        ),
        Expanded(
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filters.map((filter) {
                final isSelected = filter == selectedFilter;

                return Padding(
                  padding: EdgeInsets.only(right: AppDimensions.sm),
                  child: ActionChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? colors.primary : colors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isSelected
                        ? colors.primaryContainer.withValues(alpha: 0.4)
                        : colors.surface,
                    side: BorderSide(
                      color: isSelected ? colors.primary : colors.outline,
                    ),
                    onPressed: () => onFilterSelected(filter),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlannerRecipeCard extends StatelessWidget {
  const _PlannerRecipeCard({required this.recipe, required this.onQuickLog});

  final PlannerRecipeRecommendation recipe;
  final VoidCallback onQuickLog;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      margin: EdgeInsets.only(bottom: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(recipe.slot.icon, color: recipe.slot.color, size: 18),
              SizedBox(width: AppDimensions.sm),
              Text(
                recipe.slot.displayName.toUpperCase(),
                style: AppTypography.labelSm(color: recipe.slot.color),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  recipe.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Text(
                recipe.emoji,
                style: TextStyle(fontSize: AppDimensions.font(32)),
              ),
              SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTypography.headingSm(color: colors.onSurface),
                    ),
                    SizedBox(height: AppDimensions.xs),
                    Text(
                      recipe.macroSummary,
                      style: AppTypography.bodySm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${recipe.calories}',
                    style: AppTypography.numeralSm(color: recipe.slot.color),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: AppDimensions.xxl),
          const AppSectionHeader(title: 'Ready for today?'),
          SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.outlined(
                label: 'View Recipe',
                onPressed: () {},
                isExpanded: false,
              ),
              SizedBox(width: AppDimensions.md),
              AppButton.icon(
                label: 'Log Today',
                onPressed: onQuickLog,
                icon: const Icon(LucideIcons.plus, size: 14),
                isExpanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

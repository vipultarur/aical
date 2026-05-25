import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_meal_slot_card.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:calcount/features/dashboard/providers/dashboard_summary_provider.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

/// Meal intake section with all dashboard meal slots.
class DashboardIntakeSection extends ConsumerWidget {
  const DashboardIntakeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDark;
    final macroTotals = ref.watch(dashboardMacroTotalsProvider);
    final mealEntriesByType = ref.watch(mealEntriesByTypeProvider);

    // Read calorie target from user profile to split per-meal targets proportionally
    final calorieTarget = ref.watch(
      userProfileProvider.select((p) => p.calorieTarget),
    );

    // Proportional meal calorie targets based on user's daily goal
    final breakfastTarget = (calorieTarget * 0.25).round();
    final lunchTarget = (calorieTarget * 0.35).round();
    final dinnerTarget = (calorieTarget * 0.30).round();
    final snackTarget = (calorieTarget * 0.10).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'Intake',
          trailing: Row(
            children: [
              Icon(
                LucideIcons.droplet,
                size: AppDimensions.iconSm,
                color: AppColors.dashboardHeroBlue,
              ),
              SizedBox(width: AppDimensions.xs),
              Text(
                '${macroTotals.calories} kcal',
                style: AppTypography.headingSm(
                  color: isDark ? Colors.white : AppColors.dashboardTitle,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.md),
        Column(
          children: [
            DashboardMealSlotCard(
              colors: colors,
              isDark: isDark,
              type: MealType.breakfast,
              title: 'Breakfast',
              target: breakfastTarget,
              entries: mealEntriesByType[MealType.breakfast]!,
              iconBgColor: const Color(0xFFFFF9C4),
            ),
            DashboardMealSlotCard(
              colors: colors,
              isDark: isDark,
              type: MealType.lunch,
              title: 'Lunch',
              target: lunchTarget,
              entries: mealEntriesByType[MealType.lunch]!,
              iconBgColor: const Color(0xFFFFE0B2),
            ),
            DashboardMealSlotCard(
              colors: colors,
              isDark: isDark,
              type: MealType.dinner,
              title: 'Dinner',
              target: dinnerTarget,
              entries: mealEntriesByType[MealType.dinner]!,
              iconBgColor: const Color(0xFFE8EAF6),
            ),
            DashboardMealSlotCard(
              colors: colors,
              isDark: isDark,
              type: MealType.snacks,
              title: 'Snack',
              target: snackTarget,
              entries: mealEntriesByType[MealType.snacks]!,
              iconBgColor: const Color(0xFFFFEBEE),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';

class MacroProgressBars extends StatelessWidget {
  final int protein;
  final int proteinGoal;
  final int carbs;
  final int carbsGoal;
  final int fat;
  final int fatGoal;

  const MacroProgressBars({
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fat,
    required this.fatGoal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Macros',
              style: AppTypography.headingSm(color: colors.onSurface),
            ),
            Text(
              'Targets',
              style: AppTypography.labelSm(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.lg),
        _buildMacroRow(
          'Protein',
          protein,
          proteinGoal,
          'g',
          AppColors.macroProtein,
          context,
        ),
        SizedBox(height: AppDimensions.md),
        _buildMacroRow(
          'Carbohydrates',
          carbs,
          carbsGoal,
          'g',
          AppColors.macroCarbs,
          context,
        ),
        SizedBox(height: AppDimensions.md),
        _buildMacroRow('Fats', fat, fatGoal, 'g', AppColors.macroFat, context),
      ],
    );
  }

  Widget _buildMacroRow(
    String label,
    int current,
    int goal,
    String unit,
    Color color,
    BuildContext context,
  ) {
    final colors = context.colors;
    final ratio = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMd(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current$unit / $goal$unit',
              style: AppTypography.numeralSm(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.height(6)),
        // Animated Progress bar track
        Stack(
          children: [
            Container(
              height: AppDimensions.height(8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: AppDimensions.circular(4),
              ),
            ),
            // Progress fill
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              widthFactor: ratio,
              child: Container(
                height: AppDimensions.height(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppDimensions.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: AppDimensions.width(4),
                      offset: Offset(0, AppDimensions.height(1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_assets.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/dashboard/presentation/painters/calorie_progress_painter.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_macro_row.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:calcount/features/dashboard/providers/dashboard_summary_provider.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_card.dart';

/// Daily budget and macro summary cards.
class DashboardBudgetSection extends ConsumerWidget {
  const DashboardBudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDark;
    final profile = ref.watch(
      userProfileProvider.select(
        (profile) => (
          calorieTarget: profile.calorieTarget,
          carbsTarget: profile.carbsTarget,
          proteinTarget: profile.proteinTarget,
          fatTarget: profile.fatTarget,
        ),
      ),
    );
    final macroTotals = ref.watch(dashboardMacroTotalsProvider);
    final remainingCalories = ref.watch(remainingCaloriesProvider);
    
    final isOverGoal = macroTotals.calories > profile.calorieTarget;
    final displayCalories = isOverGoal 
        ? macroTotals.calories - profile.calorieTarget 
        : remainingCalories;

    Widget buildRemainingCard() {
      return AppCard(
        borderRadius: 20,
        padding: AppDimensions.symmetric(vertical: 16, horizontal: 12),
        color: isDark ? colors.surface : Colors.white,
        borderColor: isDark ? colors.outline : Colors.grey.shade100,
        child: SizedBox(
          height: AppDimensions.height(183),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(
                            begin: 0,
                            end: _safeProgressPercent(
                              current: macroTotals.calories,
                              target: profile.calorieTarget,
                            ),
                          ),
                          builder: (context, value, _) {
                            return CustomPaint(
                              size: Size(
                                AppDimensions.size(110),
                                AppDimensions.size(110),
                              ),
                              painter: CalorieProgressPainter(
                                percent: value,
                                progressColor: isOverGoal
                                    ? const Color(0xFFF87171)
                                    : AppColors.dashboardHeroBlue,
                                trackColor: isDark
                                    ? colors.outline
                                    : AppColors.dashboardHeroBlueSoft,
                              ),
                            );
                          },
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isOverGoal ? 'Over by' : 'Remaining',
                              style: AppTypography.labelSm(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                              ).copyWith(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: AppDimensions.xxs),
                            SizedBox(
                              width: AppDimensions.size(85),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$displayCalories',
                                  style:
                                      AppTypography.numeralLg(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.dashboardInk,
                                      ).copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppDimensions.height(1)),
                            Text(
                              'kcal',
                              style: AppTypography.labelMd(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Goal ${profile.calorieTarget} kcal',
                      style: AppTypography.labelMd(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: AppDimensions.xs),
                    Icon(
                      LucideIcons.helpCircle,
                      size: AppDimensions.icon(13),
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildMacroCard() {
      return AppCard(
        borderRadius: 20,
        padding: AppDimensions.symmetric(vertical: 16, horizontal: 12),
        color: isDark ? colors.surface : Colors.white,
        borderColor: isDark ? colors.outline : Colors.grey.shade100,
        child: SizedBox(
          height: AppDimensions.height(183),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DashboardMacroRow(
                label: 'Carbs',
                eaten: macroTotals.carbs,
                target: profile.carbsTarget,
                unit: 'g',
                bgColor: AppColors.dashboardMintSoft,
                assetPath: AppAssets.carbs,
                isDark: isDark,
                progressColor: AppColors.greenFresh,
              ),
              DashboardMacroRow(
                label: 'Protein',
                eaten: macroTotals.protein,
                target: profile.proteinTarget,
                unit: 'g',
                bgColor: const Color(0xFFFFE0B2),
                assetPath: AppAssets.protein,
                isDark: isDark,
                progressColor: const Color(0xFFFB8C00),
              ),
              DashboardMacroRow(
                label: 'Fat',
                eaten: macroTotals.fat,
                target: profile.fatTarget,
                unit: 'g',
                bgColor: const Color(0xFFFFF9C4),
                assetPath: AppAssets.fat,
                isDark: isDark,
                progressColor: const Color(0xFFFFD600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeader(
          title: 'Daily budget',
          trailing: _DashboardEditLabel(),
        ),
        SizedBox(height: AppDimensions.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildRemainingCard()),
            SizedBox(width: AppDimensions.lg),
            Expanded(child: buildMacroCard()),
          ],
        ),
      ],
    );
  }
}

double _safeProgressPercent({required int current, required int target}) {
  if (target <= 0) {
    return 0;
  }

  return (current / target).clamp(0.0, 1.0);
}

class _DashboardEditLabel extends StatelessWidget {
  const _DashboardEditLabel();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      children: [
        Icon(
          LucideIcons.edit2,
          size: AppDimensions.iconSm,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        SizedBox(width: AppDimensions.xs),
        Text(
          'Edit',
          style: AppTypography.labelLg(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

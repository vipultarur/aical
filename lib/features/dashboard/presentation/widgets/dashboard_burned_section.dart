import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:calcount/common/widgets/app_card.dart';

/// Burned-calories placeholder section.
class DashboardBurnedSection extends StatelessWidget {
  const DashboardBurnedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'Burned',
          trailing: Row(
            children: [
              Icon(
                LucideIcons.flame,
                size: AppDimensions.iconSm,
                color: Colors.orange,
              ),
              SizedBox(width: AppDimensions.xs),
              Text(
                '0 kcal',
                style: AppTypography.headingSm(
                  color: isDark ? Colors.white : AppColors.dashboardTitle,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.md),
        AppCard(
          borderRadius: 20,
          color: isDark ? colors.surface : AppColors.dashboardWorkoutSurface,
          borderColor: isDark
              ? colors.outline
              : AppColors.dashboardWorkoutBorder,
          child: Column(
            children: [
              Text(
                "You haven't uploaded any workout",
                style: AppTypography.headingSm(
                  color: isDark ? Colors.white : AppColors.dashboardTitle,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppDimensions.height(6)),
              Text(
                'You can search in our database.',
                style: AppTypography.bodySm(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: AppDimensions.height(14)),
              Container(
                padding: AppDimensions.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.dashboardInk,
                  borderRadius: AppDimensions.circular(24),
                ),
                child: Text(
                  '+ Add workout',
                  style: AppTypography.labelLg(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

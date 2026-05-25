import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_decorative_dish.dart';

/// CTA banner leading to the recipe builder flow.
class DashboardRecipeBanner extends StatelessWidget {
  const DashboardRecipeBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      height: AppDimensions.height(168),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1A2E35), Color(0xFF1B2E24)]
              : const [
                  AppColors.dashboardBannerBlue,
                  AppColors.dashboardBannerGreen,
                ],
        ),
        borderRadius: AppDimensions.circular(20),
        border: Border.all(
          color: isDark ? colors.outline : const Color(0xFFCFEFE7),
          width: AppDimensions.width(1.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: AppDimensions.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -AppDimensions.width(20),
              top: -AppDimensions.height(10),
              bottom: -AppDimensions.height(10),
              width: AppDimensions.width(160),
              child: Opacity(
                opacity: isDark ? 0.15 : 0.45,
                child: Stack(
                  children: [
                    Positioned(
                      right: AppDimensions.width(10),
                      top: AppDimensions.height(20),
                      child: const DashboardDecorativeDish(
                        color: Color(0xFF81C784),
                        size: 70,
                      ),
                    ),
                    Positioned(
                      right: AppDimensions.width(50),
                      bottom: AppDimensions.height(10),
                      child: const DashboardDecorativeDish(
                        color: Color(0xFFFFB74D),
                        size: 60,
                      ),
                    ),
                    Positioned(
                      right: -AppDimensions.width(10),
                      bottom: AppDimensions.height(25),
                      child: const DashboardDecorativeDish(
                        color: Color(0xFF4FC3F7),
                        size: 75,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: AppDimensions.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Your Recipe',
                        style: AppTypography.headingSm(
                          color: isDark
                              ? Colors.white
                              : AppColors.dashboardTitle,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppDimensions.height(3)),
                      Text(
                        'Input ingredients and generate a custom recipe',
                        style: AppTypography.labelSm(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: AppDimensions.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dashboardInk,
                        borderRadius: AppDimensions.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Check it out',
                            style: AppTypography.labelMd(
                              color: Colors.white,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: AppDimensions.xs),
                          Icon(
                            LucideIcons.arrowRight,
                            size: AppDimensions.icon(13),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

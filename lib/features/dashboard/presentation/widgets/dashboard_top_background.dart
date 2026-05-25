import 'package:flutter/material.dart';

import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';

/// Decorative dashboard top gradient background.
class DashboardTopBackground extends StatelessWidget {
  const DashboardTopBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 380,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colors.primary.withValues(alpha: 0.12),
                    colors.tertiary.withValues(alpha: 0.06),
                    Colors.transparent,
                  ]
                : [
                    AppColors.dashboardMintSoft.withValues(alpha: 0.8),
                    AppColors.dashboardHeroBlueSoft.withValues(alpha: 0.9),
                    AppColors.dashboardBackground,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

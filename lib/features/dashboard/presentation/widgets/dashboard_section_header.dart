import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

/// Shared section header styling for dashboard blocks.
class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({required this.title, super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headingLg(
              color: isDark ? Colors.white : AppColors.dashboardTitle,
            ).copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.4),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: AppDimensions.sm),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: trailing!,
            ),
          ),
        ],
      ],
    );
  }
}

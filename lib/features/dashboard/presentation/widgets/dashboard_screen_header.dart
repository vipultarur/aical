import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

/// Header block containing the brand row and current date selector.
class DashboardScreenHeader extends StatelessWidget {
  const DashboardScreenHeader({
    required this.selectedDate,
    required this.onDateTap,
    required this.onProfileTap,
    super.key,
  });

  final DateTime selectedDate;
  final VoidCallback onDateTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'WiseMeal',
                          style:
                              AppTypography.displayMd(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.dashboardInk,
                              ).copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                        ),
                        SizedBox(width: AppDimensions.sm),
                        Container(
                          padding: AppDimensions.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dashboardBadgeBackground,
                            border: Border.all(
                              color: AppColors.dashboardBadgeBorder,
                              width: AppDimensions.width(1),
                            ),
                            borderRadius: AppDimensions.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.zap,
                                size: AppDimensions.icon(11),
                                color: Colors.green.shade800,
                              ),
                              SizedBox(width: AppDimensions.width(1)),
                              Text(
                                'PRO',
                                style: AppTypography.labelSm(
                                  color: Colors.green.shade800,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.sm),
              GestureDetector(
                onTap: onProfileTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: AppDimensions.size(44),
                  height: AppDimensions.size(44),
                  decoration: BoxDecoration(
                    color: AppColors.dashboardAvatar,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: AppDimensions.width(2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: AppDimensions.width(6),
                        offset: Offset(0, AppDimensions.height(2)),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.user,
                      color: Colors.white,
                      size: AppDimensions.icon(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.md),
        GestureDetector(
          onTap: onDateTap,
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatHeaderDate(selectedDate),
                    style: AppTypography.headingSm(
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: AppDimensions.xs),
                  Icon(
                    LucideIcons.chevronDown,
                    size: AppDimensions.icon(18),
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatHeaderDate(DateTime date) {
  final weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}

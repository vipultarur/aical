import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';

/// Displays one dashboard macro summary row.
class DashboardMacroRow extends StatelessWidget {
  const DashboardMacroRow({
    required this.label,
    required this.eaten,
    required this.target,
    required this.unit,
    required this.bgColor,
    required this.assetPath,
    required this.isDark,
    required this.progressColor,
    super.key,
  });

  final String label;
  final int eaten;
  final int target;
  final String unit;
  final Color bgColor;
  final String assetPath;
  final bool isDark;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$eaten',
                        style: AppTypography.headingSm(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111111),
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / $target$unit',
                        style: AppTypography.bodySm(
                          color: Colors.grey.shade400,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.height(2)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSm(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: AppDimensions.size(40),
                height: AppDimensions.size(40),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(
                    begin: 0,
                    end: _safeProgressPercent(current: eaten, target: target),
                  ),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3.5,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Container(
                width: AppDimensions.size(30),
                height: AppDimensions.size(30),
                decoration: BoxDecoration(
                  color: isDark ? colors.surface : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: AppDimensions.circular(15),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      width: AppDimensions.size(30),
                      height: AppDimensions.size(30),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant_menu_rounded,
                          color: progressColor,
                          size: AppDimensions.iconSm,
                        );
                      },
                    ),
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

double _safeProgressPercent({required int current, required int target}) {
  if (target <= 0) return 0.0;
  return (current / target).clamp(0.0, 1.0);
}

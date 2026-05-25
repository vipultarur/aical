import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: AppDimensions.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Container(
            padding: AppDimensions.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: AppDimensions.iconMd),
          ),
          SizedBox(height: AppDimensions.md),
          Text(
            label,
            style: AppTypography.labelSm(color: colors.onSurfaceVariant),
          ),
          SizedBox(height: AppDimensions.xs),
          Text(value, style: AppTypography.numeralSm(color: colors.onSurface)),
        ],
      ),
    );
  }
}

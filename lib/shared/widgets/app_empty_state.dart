import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/shared/widgets/app_button.dart';

/// Shared empty-state view for sections with no content.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: AppDimensions.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...?icon == null
                ? null
                : [icon!, SizedBox(height: AppDimensions.xl)],
            Text(
              title,
              style: AppTypography.headingLg(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimensions.xxl),
              AppButton.outlined(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

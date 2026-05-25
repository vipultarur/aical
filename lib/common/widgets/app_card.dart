import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_theme.dart';

/// Reusable surface card with consistent spacing and borders.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedPadding = padding ?? AppDimensions.all(16);
    final resolvedBorderRadius = borderRadius ?? AppDimensions.radiusLg;
    final content = Padding(padding: resolvedPadding, child: child);

    return Card(
      margin: margin,
      color: color ?? colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(resolvedBorderRadius),
        side: BorderSide(color: borderColor ?? colors.outline),
      ),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(resolvedBorderRadius),
              child: content,
            ),
    );
  }
}

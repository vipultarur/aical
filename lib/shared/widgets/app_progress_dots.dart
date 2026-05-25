import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_theme.dart';

class AppProgressDots extends StatelessWidget {
  const AppProgressDots({
    required this.totalSteps,
    required this.currentStep,
    super.key,
    this.activeWidth = 24,
    this.dotWidth = 8,
    this.dotHeight = 8,
  });

  final int totalSteps;
  final int currentStep;
  final double activeWidth;
  final double dotWidth;
  final double dotHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final resolvedActiveWidth = AppDimensions.width(activeWidth);
        final resolvedDotWidth = AppDimensions.width(dotWidth);
        final resolvedDotHeight = AppDimensions.height(dotHeight);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: AppDimensions.symmetric(horizontal: 4),
          width: isActive ? resolvedActiveWidth : resolvedDotWidth,
          height: resolvedDotHeight,
          decoration: BoxDecoration(
            color: isActive ? colors.primary : colors.outline,
            borderRadius: BorderRadius.circular(resolvedDotHeight / 2),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

class AuthHeaderBackground extends StatelessWidget {
  const AuthHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 280,
      ),
      height: MediaQuery.sizeOf(context).height * 0.35,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.greenLeaf, AppColors.greenFresh],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.24),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.leaf,
                color: colors.onPrimary,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'CaloriePal',
              style: AppTypography.displayMd(color: colors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

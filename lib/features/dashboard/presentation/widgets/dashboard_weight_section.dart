import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/dashboard/presentation/dialogs/weight_log_dialog.dart';
import 'package:calcount/features/dashboard/presentation/painters/weight_chart_painter.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_card.dart';

/// Weight summary card with quick logging access.
class DashboardWeightSection extends ConsumerWidget {
  const DashboardWeightSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDark;
    final profile = ref.watch(
      userProfileProvider.select(
        (profile) => (
          weight: profile.weight,
          targetWeight: profile.targetWeight,
          unit: profile.weightUnit,
        ),
      ),
    );

    // Real weight delta from history
    final weightHistory = ref.watch(weightHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'Weight',
          trailing: GestureDetector(
            onTap: () => context.push(AppRoutes.weightLog),
            child: Text(
              'More >',
              style: AppTypography.labelLg(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.md),
        AppCard(
          borderRadius: 20,
          color: isDark ? colors.surface : Colors.white,
          borderColor: isDark ? colors.outline : Colors.grey.shade200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < AppDimensions.width(300);
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.weight.toStringAsFixed(1)} ${profile.unit}',
                    style: AppTypography.numeralLg(
                      color: isDark ? Colors.white : AppColors.dashboardInk,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: AppDimensions.xxs),
                  Text(
                    'Goal ${profile.targetWeight.toStringAsFixed(1)}${profile.unit}',
                    style: AppTypography.bodySm(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: AppDimensions.md),
                  Builder(
                    builder: (context) {
                      // Compute real weight delta from history
                      double? delta;
                      bool isGain = false;
                      if (weightHistory.length >= 2) {
                        final sorted = List.of(weightHistory)
                          ..sort((a, b) => a.date.compareTo(b.date));
                        delta = sorted.last.weight - sorted[sorted.length - 2].weight;
                        isGain = delta >= 0;
                      }

                      if (delta == null) {
                        return const SizedBox.shrink();
                      }

                      final deltaText = '${delta.abs().toStringAsFixed(1)} ${profile.unit}';
                      final deltaColor = isGain ? Colors.red.shade700 : Colors.green.shade800;
                      final bgColor = isGain
                          ? Colors.red.shade50
                          : AppColors.dashboardMintSoft;

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: AppDimensions.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGain ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                              size: AppDimensions.icon(11),
                              color: deltaColor,
                            ),
                            SizedBox(width: AppDimensions.width(2)),
                            Text(
                              deltaText,
                              style: AppTypography.labelSm(
                                color: deltaColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
              final chart = SizedBox(
                height: AppDimensions.height(75),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: WeightChartPainter(
                      lineColor: AppColors.dashboardChartBlue,
                      dotColor: AppColors.dashboardHeroBlueDeep,
                      weightHistory: weightHistory,
                    ),
                  ),
                ),
              );
              final action = GestureDetector(
                onTap: () => showWeightLogDialog(context, ref),
                child: Container(
                  width: AppDimensions.size(36),
                  height: AppDimensions.size(36),
                  decoration: BoxDecoration(
                    color: AppColors.dashboardHeroBlueSoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: AppDimensions.width(1.5),
                    ),
                  ),
                  child: Icon(
                    LucideIcons.plus,
                    color: AppColors.dashboardHeroBlueDark,
                    size: AppDimensions.icon(22),
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: summary),
                        SizedBox(width: AppDimensions.sm),
                        action,
                      ],
                    ),
                    SizedBox(height: AppDimensions.md),
                    chart,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  summary,
                  Expanded(
                    child: Padding(
                      padding: AppDimensions.only(left: 20, right: 12),
                      child: chart,
                    ),
                  ),
                  action,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

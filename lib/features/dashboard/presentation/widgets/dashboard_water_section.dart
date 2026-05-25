import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/dashboard/presentation/painters/water_cup_painter.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_card.dart';
import 'package:calcount/features/dashboard/providers/dashboard_summary_provider.dart';
import 'package:calcount/core/services/local_storage_service.dart';

/// Water intake widget with dynamic looping fluid-wave animation.
class DashboardWaterSection extends ConsumerStatefulWidget {
  const DashboardWaterSection({super.key});

  @override
  ConsumerState<DashboardWaterSection> createState() =>
      _DashboardWaterSectionState();
}

class _DashboardWaterSectionState extends ConsumerState<DashboardWaterSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // 2-second smooth wave repetition cycle
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    
    final selectedDate = ref.watch(dashboardSelectedDateProvider);
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
                    selectedDate.month == now.month &&
                    selectedDate.day == now.day;
    
    final waterLoggedAsync = ref.watch(dashboardWaterIntakeProvider);
    final waterLogged = isToday ? ref.watch(waterIntakeProvider) : (waterLoggedAsync.valueOrNull ?? 0);
    
    final profile = ref.watch(
      userProfileProvider.select(
        (profile) => (waterTarget: profile.waterTarget),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeader(
          title: 'Water',
          trailing: _DashboardMoreLabel(),
        ),
        SizedBox(height: AppDimensions.md),
        AppCard(
          borderRadius: 20,
          color: isDark ? colors.surface : Colors.white,
          borderColor: isDark ? colors.outline : Colors.grey.shade200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < AppDimensions.width(280);
              final status = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$waterLogged ml',
                    style: AppTypography.numeralLg(
                      color: isDark ? Colors.white : AppColors.dashboardInk,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: AppDimensions.xxs),
                  Text(
                    'Goal ${profile.waterTarget}ml',
                    style: AppTypography.bodySm(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: AppDimensions.md),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? colors.outline : AppColors.neutral100,
                      borderRadius: AppDimensions.circular(6),
                    ),
                    child: Text(
                      '1 cup = 250ml',
                      style: AppTypography.labelSm(
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
              final action = GestureDetector(
                onTap: () {
                  if (isToday) {
                    ref.read(waterIntakeProvider.notifier).addWater(250);
                  } else {
                    LocalStorageService.saveWaterIntake(waterLogged + 250, selectedDate).then((_) {
                      ref.invalidate(dashboardWaterIntakeProvider);
                    });
                  }
                },
                child: RepaintBoundary(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: _safeWaterProgressPercent(
                                current: waterLogged,
                                target: profile.waterTarget,
                              ),
                            ),
                            builder: (context, fillValue, _) {
                              return CustomPaint(
                                size: Size(
                                  AppDimensions.width(80),
                                  AppDimensions.height(100),
                                ),
                                painter: WaterCupPainter(
                                  fillPercent: fillValue,
                                  animationValue: _animationController.value,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Container(
                        width: AppDimensions.size(32),
                        height: AppDimensions.size(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade900.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: AppDimensions.width(4),
                              offset: Offset(0, AppDimensions.height(2)),
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.plus,
                          color: AppColors.dashboardHeroBlueDark,
                          size: AppDimensions.iconMd,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    status,
                    SizedBox(height: AppDimensions.md),
                    Align(alignment: Alignment.centerRight, child: action),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [status, action],
              );
            },
          ),
        ),
      ],
    );
  }
}

double _safeWaterProgressPercent({required int current, required int target}) {
  if (target <= 0) {
    return 0;
  }

  return (current / target).clamp(0.0, 1.0);
}

class _DashboardMoreLabel extends StatelessWidget {
  const _DashboardMoreLabel();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Text(
      'More >',
      style: AppTypography.labelLg(
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

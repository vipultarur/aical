import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/features/dashboard/presentation/dialogs/calendar_bottom_sheet.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_budget_section.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_burned_section.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_day_ribbon.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_insight_banner.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_intake_section.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_recipe_banner.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_screen_header.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_top_background.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_water_section.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_weight_section.dart';
import 'package:calcount/features/dashboard/providers/dashboard_summary_provider.dart';

/// Main dashboard screen for daily overview and quick actions.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentHorizontalPadding = screenWidth < AppBreakpoints.tablet
        ? AppDimensions.lg
        : AppDimensions.xl;

    final selectedDate = ref.watch(dashboardSelectedDateProvider);

    return Scaffold(
      backgroundColor: isDark ? colors.surface : AppColors.dashboardBackground,
      body: Stack(
        children: [
          const DashboardTopBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.lg),
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: contentHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardScreenHeader(
                      selectedDate: selectedDate,
                      onDateTap: () => _showCalendarBottomSheet(context, selectedDate),
                      onProfileTap: () => context.go(AppRoutes.profile),
                    ),
                    SizedBox(height: AppDimensions.md),
                    DashboardDayRibbon(
                      colors: colors,
                      isDark: isDark,
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        ref.read(dashboardSelectedDateProvider.notifier).state = date;
                      },
                    ),
                    SizedBox(height: AppDimensions.xxl),
                    const DashboardBudgetSection(),
                    SizedBox(height: AppDimensions.xl),
                    const DashboardInsightBanner(),
                    SizedBox(height: AppDimensions.xl),
                    DashboardRecipeBanner(
                      onTap: () => context.push(AppRoutes.recipeBuilder),
                    ),
                    SizedBox(height: AppDimensions.xxl),
                    const DashboardIntakeSection(),
                    SizedBox(height: AppDimensions.xxl),
                    const DashboardBurnedSection(),
                    SizedBox(height: AppDimensions.xxl),
                    const DashboardWaterSection(),
                    SizedBox(height: AppDimensions.xxl),
                    const DashboardWeightSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendarBottomSheet(BuildContext context, DateTime currentSelectedDate) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return DashboardCalendarBottomSheet(
          initialSelectedDate: currentSelectedDate,
          onDateSelected: (newDate) {
            ref.read(dashboardSelectedDateProvider.notifier).state = newDate;
          },
        );
      },
    );
  }
}

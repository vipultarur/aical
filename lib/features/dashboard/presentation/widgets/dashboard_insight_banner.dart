import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/services/gemini_service.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_card.dart';
import 'package:calcount/features/dashboard/providers/dashboard_summary_provider.dart';

// ─── Pre-fetch provider ───────────────────────────────────────────────────────
// Fetches (and caches inside GeminiService) the daily insight as soon as the
// dashboard mounts — so users never wait for a spinner on first tap.

final _dailyInsightProvider = FutureProvider.autoDispose<String>((ref) async {
  final profile = ref.watch(userProfileProvider);
  final macroTotals = ref.watch(dashboardMacroTotalsProvider);
  final waterLogged = ref.watch(waterIntakeProvider);

  return GeminiService.getDailyInsight(
    name: profile.name.isNotEmpty ? profile.name : 'there',
    goal: profile.mainGoal,
    calorieTarget: profile.calorieTarget,
    caloriesConsumed: macroTotals.calories,
    waterTarget: profile.waterTarget,
    waterLogged: waterLogged,
    currentWeight: profile.weight,
    targetWeight: profile.targetWeight,
    weightUnit: profile.weightUnit,
    activityLevel: profile.activityLevel,
  );
});

/// Daily insight banner powered by Gemini AI.
class DashboardInsightBanner extends ConsumerWidget {
  const DashboardInsightBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kick off the fetch (or hit the cache) immediately on build.
    ref.watch(_dailyInsightProvider);

    final colors = context.colors;
    final isDark = context.isDark;

    return AppCard(
      borderRadius: 16,
      padding: AppDimensions.all(12),
      color: isDark ? colors.surface : AppColors.dashboardSkySoft,
      borderColor: isDark ? colors.outline : AppColors.dashboardSkySoftBorder,
      child: GestureDetector(
        onTap: () => _showInsightSheet(context, ref),
        child: Row(
          children: [
            Container(
              padding: AppDimensions.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD0E1FD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.sparkles,
                color: AppColors.dashboardHeroBlueDeep,
                size: AppDimensions.iconMd,
              ),
            ),
            SizedBox(width: AppDimensions.md),
            Text(
              'Daily AI Insight',
              style: AppTypography.headingSm(
                color: AppColors.dashboardHeroBlueDeep,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: AppDimensions.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
                ),
                borderRadius: AppDimensions.circular(8),
              ),
              child: Text(
                'Tap',
                style: AppTypography.labelSm(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: AppDimensions.sm),
            Icon(
              LucideIcons.chevronRight,
              color: const Color(0xFF29B6F6),
              size: AppDimensions.iconMd,
            ),
          ],
        ),
      ),
    );
  }

  void _showInsightSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _InsightBottomSheet(parentRef: ref);
      },
    );
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _InsightBottomSheet extends ConsumerWidget {
  const _InsightBottomSheet({required this.parentRef});

  final WidgetRef parentRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insightAsync = ref.watch(_dailyInsightProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E1FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  color: AppColors.dashboardHeroBlueDeep,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Daily AI Insight',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Powered by Gemini AI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Content — driven by pre-fetched FutureProvider
          insightAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(strokeCap: StrokeCap.round),
              ),
            ),
            error: (_, e) => _InsightContent(
              isDark: isDark,
              text:
                  'Stay consistent with your goals today! Every healthy choice brings you closer to your target.',
            ),
            data: (text) => _InsightContent(isDark: isDark, text: text),
          ),
          const SizedBox(height: 16),
          // Refresh button — only visible when loaded
          if (insightAsync.hasValue)
            GestureDetector(
              onTap: () => ref.invalidate(_dailyInsightProvider),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.refreshCw,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Refresh insight',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InsightContent extends StatelessWidget {
  const _InsightContent({required this.isDark, required this.text});

  final bool isDark;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

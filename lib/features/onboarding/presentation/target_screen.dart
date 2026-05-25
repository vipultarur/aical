import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/calorie_ring.dart';

class TargetScreen extends ConsumerStatefulWidget {
  const TargetScreen({super.key});

  @override
  ConsumerState<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends ConsumerState<TargetScreen> {
  double _weeklyPace = 0.5; // in kg (approx 1 lb)
  @override
  void initState() {
    super.initState();
  }

  int get _calculatedCalorieTarget {
    // If maintaining, keep base. If losing, adjust based on pace.
    final profile = ref.read(userProfileProvider);
    if (profile.mainGoal == 'Maintain Weight') {
      return 2100;
    } else if (profile.mainGoal == 'Gain Muscle') {
      return (2100 + (_weeklyPace * 1000)).round();
    } else {
      // Lose weight
      return (2100 - (_weeklyPace * 1000)).round();
    }
  }

  void _onNext() {
    final currentProfile = ref.read(userProfileProvider);
    // Calculate final macronutrient split (Protein 30%, Carbs 50%, Fat 20%)
    final totalCals = _calculatedCalorieTarget;
    final pGrams = ((totalCals * 0.3) / 4).round();
    final cGrams = ((totalCals * 0.5) / 4).round();
    final fGrams = ((totalCals * 0.2) / 9).round();

    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          currentProfile.copyWith(
            calorieTarget: totalCals,
            proteinTarget: pGrams,
            carbsTarget: cGrams,
            fatTarget: fGrams,
          ),
        );
    context.go(AppRoutes.onboardingDietPrefs);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = ref.watch(userProfileProvider);
    final finalCalories = _calculatedCalorieTarget;

    // Macro grams
    final pGrams = ((finalCalories * 0.3) / 4).round();
    final cGrams = ((finalCalories * 0.5) / 4).round();
    final fGrams = ((finalCalories * 0.2) / 9).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingGoals),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: index == 3 ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == 3 ? colors.primary : colors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your calorie goal',
                style: AppTypography.headingXl(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Customized directly based on your weight and health ambitions.",
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Animated Calorie Preview Card
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CalorieRing(eaten: 0, goal: finalCalories, size: 200),
                      const SizedBox(height: 24),
                      Text(
                        'Macronutrient Split',
                        style: AppTypography.headingSm(color: colors.onSurface),
                      ),
                      const SizedBox(height: 16),
                      // Protein, Carbs, Fat grid cards
                      Row(
                        children: [
                          _buildMacroCard(
                            'Protein',
                            '${pGrams}g',
                            AppColors.macroProtein,
                          ),
                          const SizedBox(width: 8),
                          _buildMacroCard(
                            'Carbs',
                            '${cGrams}g',
                            AppColors.macroCarbs,
                          ),
                          const SizedBox(width: 8),
                          _buildMacroCard(
                            'Fats',
                            '${fGrams}g',
                            AppColors.macroFat,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              if (profile.mainGoal != 'Maintain Weight') ...[
                // Pace Selector Title
                Text(
                  'Weekly Pace Target',
                  style: AppTypography.headingSm(color: colors.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [0.25, 0.5, 0.75].map((pace) {
                    final isSelected = _weeklyPace == pace;
                    final displayLabel =
                        '${(pace * 2).toStringAsFixed(1)} lbs/wk';
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(
                            displayLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _weeklyPace = pace);
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Estimated to reach goal weight by July 2026',
                  style: AppTypography.bodyMd(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Maintaining is a sustainable habit. We will keep your calories optimized for stability.',
                  style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onNext,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(LucideIcons.arrowRight, size: 24),
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(label, style: AppTypography.labelSm(color: color)),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.numeralSm(color: color)),
          ],
        ),
      ),
    );
  }
}

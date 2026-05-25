import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_durations.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/onboarding/models/recipe_plan_preview.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_back_button.dart';
import 'package:calcount/common/widgets/app_card.dart';
import 'package:calcount/common/widgets/app_progress_dots.dart';

/// Shows a generated onboarding meal-plan preview before completion.
class RecipePlanScreen extends ConsumerStatefulWidget {
  const RecipePlanScreen({super.key});

  @override
  ConsumerState<RecipePlanScreen> createState() => _RecipePlanScreenState();
}

class _RecipePlanScreenState extends ConsumerState<RecipePlanScreen> {
  static const List<String> _loadingSteps = [
    'Calibrating daily energy budget...',
    'Locking macronutrient distribution ratios...',
    'Compiling chef-approved recipe databases...',
    'Finalizing custom recipe blueprint...',
  ];

  bool _isFinalizing = false;
  int _loadingStepIndex = 0;
  late Timer _stepTimer;

  @override
  void initState() {
    super.initState();
    _startLoadingSteps();
  }

  @override
  void dispose() {
    _stepTimer.cancel();
    super.dispose();
  }

  void _startLoadingSteps() {
    _stepTimer = Timer.periodic(AppDurations.recipePlanStep, (timer) {
      if (_loadingStepIndex < _loadingSteps.length - 1) {
        setState(() {
          _loadingStepIndex++;
        });
      } else {
        _stepTimer.cancel();
      }
    });
  }

  Future<void> _onFinalize() async {
    setState(() {
      _isFinalizing = true;
    });

    await Future.delayed(AppDurations.recipePlanNavigationDelay);

    if (mounted) {
      context.go(AppRoutes.onboardingComplete);
    }
  }

  List<RecipePlanPreview> _getMockRecipes(String eatingStyle) {
    if (eatingStyle == 'Keto') {
      return const [
        RecipePlanPreview(
          slot: 'Breakfast',
          name: 'Avocado & Bacon Scramble',
          caloriesLabel: '420 kcal',
          macrosLabel: 'P: 28g · C: 4g · F: 32g',
          icon: LucideIcons.egg,
          color: AppColors.mealBreakfast,
        ),
        RecipePlanPreview(
          slot: 'Lunch',
          name: 'Creamy Salmon & Spinach Salad',
          caloriesLabel: '580 kcal',
          macrosLabel: 'P: 42g · C: 5g · F: 44g',
          icon: LucideIcons.fish,
          color: AppColors.mealLunch,
        ),
        RecipePlanPreview(
          slot: 'Dinner',
          name: 'Garlic Butter Ribeye Steak',
          caloriesLabel: '650 kcal',
          macrosLabel: 'P: 48g · C: 2g · F: 50g',
          icon: LucideIcons.menu,
          color: AppColors.mealDinner,
        ),
      ];
    }

    if (eatingStyle == 'Vegetarian' || eatingStyle == 'Vegan') {
      return const [
        RecipePlanPreview(
          slot: 'Breakfast',
          name: 'Almond Butter & Banana Chia Bowl',
          caloriesLabel: '380 kcal',
          macrosLabel: 'P: 12g · C: 48g · F: 16g',
          icon: LucideIcons.coffee,
          color: AppColors.mealBreakfast,
        ),
        RecipePlanPreview(
          slot: 'Lunch',
          name: 'Quinoa, Hummus & Broccoli Buddha Bowl',
          caloriesLabel: '510 kcal',
          macrosLabel: 'P: 18g · C: 62g · F: 22g',
          icon: LucideIcons.leaf,
          color: AppColors.mealLunch,
        ),
        RecipePlanPreview(
          slot: 'Dinner',
          name: 'Crispy Sesame Tofu & Brown Rice Bowl',
          caloriesLabel: '560 kcal',
          macrosLabel: 'P: 24g · C: 72g · F: 18g',
          icon: LucideIcons.leaf,
          color: AppColors.mealDinner,
        ),
      ];
    }

    return const [
      RecipePlanPreview(
        slot: 'Breakfast',
        name: 'Spinach, Feta & Tomato Omelet',
        caloriesLabel: '350 kcal',
        macrosLabel: 'P: 24g · C: 8g · F: 22g',
        icon: LucideIcons.egg,
        color: AppColors.mealBreakfast,
      ),
      RecipePlanPreview(
        slot: 'Lunch',
        name: 'Mediterranean Lemon Chicken & Quinoa Salad',
        caloriesLabel: '520 kcal',
        macrosLabel: 'P: 38g · C: 44g · F: 16g',
        icon: LucideIcons.fish,
        color: AppColors.mealLunch,
      ),
      RecipePlanPreview(
        slot: 'Dinner',
        name: 'Baked Herb Salmon with Sweet Potatoes',
        caloriesLabel: '600 kcal',
        macrosLabel: 'P: 42g · C: 38g · F: 20g',
        icon: LucideIcons.coffee,
        color: AppColors.mealDinner,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = ref.watch(userProfileProvider);
    final eatingStyle = profile.dietPrefs.isNotEmpty
        ? profile.dietPrefs.first
        : 'Balanced';
    final targetCalories = profile.calorieTarget;
    final recipes = _getMockRecipes(eatingStyle);

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          onPressed: () => context.go(AppRoutes.onboardingEatingStyle),
        ),
        title: const AppProgressDots(totalSteps: 9, currentStep: 8),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.xxl,
                vertical: AppDimensions.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Customized Meal Plan',
                    style: AppTypography.headingXl(color: colors.onSurface),
                  ),
                  SizedBox(height: AppDimensions.xs),
                  Text(
                    'Here is your personalized calorie-matched recipe blueprint for a typical day:',
                    style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.sm),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.xxl,
                vertical: AppDimensions.sm,
              ),
              child: _RecipePlanLoadingCard(
                stepLabel: _loadingSteps[_loadingStepIndex],
                isCompleted: _loadingStepIndex == _loadingSteps.length - 1,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.xxl,
                  vertical: AppDimensions.md,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return _RecipePlanPreviewCard(recipe: recipes[index]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.xxl,
                vertical: AppDimensions.sm,
              ),
              child: AppCard(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderColor: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.sparkles, color: colors.primary, size: 16),
                    SizedBox(width: AppDimensions.sm),
                    Text(
                      'Matching $eatingStyle diet · $targetCalories kcal daily',
                      style: AppTypography.labelSm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.xxl,
                vertical: AppDimensions.lg,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: AppDimensions.size(56),
                  height: AppDimensions.size(56),
                  child: ElevatedButton(
                    onPressed: _isFinalizing ? null : _onFinalize,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 2,
                    ),
                    child: _isFinalizing
                        ? SizedBox(
                            width: AppDimensions.xl,
                            height: AppDimensions.xl,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          )
                        : Icon(LucideIcons.check, size: AppDimensions.iconLg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipePlanLoadingCard extends StatelessWidget {
  const _RecipePlanLoadingCard({
    required this.stepLabel,
    required this.isCompleted,
  });

  final String stepLabel;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      color: colors.primary.withValues(alpha: 0.06),
      borderColor: colors.primary.withValues(alpha: 0.15),
      child: Row(
        children: [
          SizedBox(
            width: AppDimensions.lg,
            height: AppDimensions.lg,
            child: isCompleted
                ? Icon(
                    LucideIcons.checkCircle2,
                    color: colors.primary,
                    size: 18,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    strokeCap: StrokeCap.round,
                  ),
          ),
          SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              stepLabel,
              style: AppTypography.labelMd(
                color: colors.primary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipePlanPreviewCard extends StatelessWidget {
  const _RecipePlanPreviewCard({required this.recipe});

  final RecipePlanPreview recipe;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      margin: EdgeInsets.only(bottom: AppDimensions.lg),
      borderColor: colors.outline.withValues(alpha: 0.6),
      child: Row(
        children: [
          Container(
            padding: AppDimensions.all(12),
            decoration: BoxDecoration(
              color: recipe.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(recipe.icon, color: recipe.color, size: 24),
          ),
          SizedBox(width: AppDimensions.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.slot,
                      style: AppTypography.labelMd(
                        color: recipe.color,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      recipe.caloriesLabel,
                      style: AppTypography.numeralSm(color: colors.primary),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.xs),
                Text(
                  recipe.name,
                  style: AppTypography.headingSm(color: colors.onSurface),
                ),
                SizedBox(height: AppDimensions.xs),
                Text(
                  recipe.macrosLabel,
                  style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

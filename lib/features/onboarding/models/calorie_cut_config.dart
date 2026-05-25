import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/theme/app_colors.dart';

/// Typed presentation config for the calorie-cut onboarding screen.
final class CalorieCutConfig extends Equatable {
  const CalorieCutConfig({
    required this.cutValue,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.primaryIcon,
    required this.targetIcon,
    required this.primaryLabel,
    required this.primaryCalories,
    required this.targetLabel,
    required this.targetCalories,
    required this.swapText,
  });

  final int cutValue;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final IconData primaryIcon;
  final IconData targetIcon;
  final String primaryLabel;
  final String primaryCalories;
  final String targetLabel;
  final String targetCalories;
  final String swapText;

  static CalorieCutConfig forActivityLevel(String activityLevel) {
    return switch (activityLevel) {
      'No Active' => const CalorieCutConfig(
        cutValue: 350,
        title: 'Easy Snack Swap',
        description:
            'Swap processed sugary cookies for organic black coffee or herbal tea.',
        gradientColors: [AppColors.mealBreakfast, AppColors.amberSoft],
        primaryIcon: LucideIcons.cookie,
        targetIcon: LucideIcons.coffee,
        primaryLabel: '1 Sugary Cookie',
        primaryCalories: '380 kcal',
        targetLabel: 'Organic Tea/Coffee',
        targetCalories: '5 kcal',
        swapText: 'Saves 375 kcal instantly!',
      ),
      'Lightly Active' => const CalorieCutConfig(
        cutValue: 400,
        title: 'Lifestyle & Walk Swap',
        description:
            'Take a brisk 15-minute walk after lunch instead of sitting at your desk.',
        gradientColors: [AppColors.macroFiber, AppColors.greenSoft],
        primaryIcon: LucideIcons.car,
        targetIcon: LucideIcons.footprints,
        primaryLabel: 'Driving Home directly',
        primaryCalories: '0 kcal burned',
        targetLabel: '15-min Post-Meal Walk',
        targetCalories: '150 kcal burned',
        swapText: 'Plus a healthy digestion boost!',
      ),
      'Highly Active' => const CalorieCutConfig(
        cutValue: 600,
        title: 'Clean Hydration Swap',
        description:
            'Swap sugary sports energy drinks for cold filtered water and a protein scoop.',
        gradientColors: [AppColors.blueInfo, AppColors.blueSoft],
        primaryIcon: LucideIcons.beer,
        targetIcon: LucideIcons.droplets,
        primaryLabel: 'Sugary Sports Drink',
        primaryCalories: '290 kcal',
        targetLabel: 'Filtered Water + Ice',
        targetCalories: '0 kcal',
        swapText: 'Saves 290 kcal + maximum cellular hydration!',
      ),
      _ => const CalorieCutConfig(
        cutValue: 500,
        title: 'Light Dressing Swap',
        description:
            'Swap heavy creamy ranch salad dressing for pure fresh lemon and olive oil.',
        gradientColors: [AppColors.macroCarbs, AppColors.macroProtein],
        primaryIcon: LucideIcons.coffee,
        targetIcon: LucideIcons.citrus,
        primaryLabel: 'Creamy Ranch dressing',
        primaryCalories: '220 kcal',
        targetLabel: 'Olive Oil & Lemon juice',
        targetCalories: '60 kcal',
        swapText: 'Saves 160 kcal + adds healthy antioxidants!',
      ),
    };
  }

  @override
  List<Object?> get props => [
    cutValue,
    title,
    description,
    gradientColors,
    primaryIcon,
    targetIcon,
    primaryLabel,
    primaryCalories,
    targetLabel,
    targetCalories,
    swapText,
  ];
}

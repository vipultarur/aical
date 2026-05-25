import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_assets.dart';
import 'package:calcount/core/theme/app_colors.dart';

/// Supported meal buckets for logging and planning.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks;

  static MealType current() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return MealType.breakfast;
    } else if (hour >= 11 && hour < 16) {
      return MealType.lunch;
    } else if (hour >= 16 && hour < 22) {
      return MealType.dinner;
    } else {
      return MealType.snacks;
    }
  }

  static MealType fromName(String name) {
    return MealType.values.firstWhere(
      (mealType) => mealType.name == name,
      orElse: () => MealType.current(),
    );
  }

  String get displayName => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snacks => 'Snacks',
  };

  IconData get icon => switch (this) {
    MealType.breakfast => LucideIcons.coffee,
    MealType.lunch => LucideIcons.sun,
    MealType.dinner => LucideIcons.moon,
    MealType.snacks => LucideIcons.cookie,
  };

  Color get color => switch (this) {
    MealType.breakfast => AppColors.mealBreakfast,
    MealType.lunch => AppColors.mealLunch,
    MealType.dinner => AppColors.mealDinner,
    MealType.snacks => AppColors.mealSnacks,
  };

  String get assetPath => switch (this) {
    MealType.breakfast => AppAssets.breakfast,
    MealType.lunch => AppAssets.lunch,
    MealType.dinner => AppAssets.dinner,
    MealType.snacks => AppAssets.snack,
  };
}

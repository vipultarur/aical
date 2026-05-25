import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/router/navigation_shell.dart';
import 'package:calcount/features/auth/presentation/login_screen.dart';
import 'package:calcount/features/auth/presentation/signup_screen.dart';
import 'package:calcount/features/dashboard/presentation/dashboard_screen.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/features/food_log/presentation/barcode_scanner_screen.dart';
import 'package:calcount/features/food_log/presentation/food_detail_screen.dart';
import 'package:calcount/features/food_log/presentation/food_search_screen.dart';
import 'package:calcount/features/food_log/presentation/recipe_builder_screen.dart';
import 'package:calcount/features/insights/presentation/insights_screen.dart';
import 'package:calcount/features/insights/presentation/weight_log_screen.dart';
import 'package:calcount/features/onboarding/presentation/activity_level_screen.dart';
import 'package:calcount/features/onboarding/presentation/basic_info_screen.dart';
import 'package:calcount/features/onboarding/presentation/calorie_cut_screen.dart';
import 'package:calcount/features/onboarding/presentation/complete_screen.dart';
import 'package:calcount/features/onboarding/presentation/diet_prefs_screen.dart';
import 'package:calcount/features/onboarding/presentation/eating_style_screen.dart';
import 'package:calcount/features/onboarding/presentation/goals_screen.dart';
import 'package:calcount/features/onboarding/presentation/height_weight_screen.dart';
import 'package:calcount/features/onboarding/presentation/recipe_plan_screen.dart';
import 'package:calcount/features/onboarding/presentation/target_reach_screen.dart';
import 'package:calcount/features/onboarding/presentation/target_screen.dart';
import 'package:calcount/features/onboarding/presentation/welcome_screen.dart';
import 'package:calcount/features/onboarding/presentation/weight_prediction_screen.dart';
import 'package:calcount/features/planner/presentation/meal_planner_screen.dart';
import 'package:calcount/features/profile/presentation/profile_screen.dart';
import 'package:calcount/features/profile/presentation/settings_screen.dart';
import 'package:calcount/features/splash/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingWelcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingBasicInfo,
      builder: (context, state) => const BasicInfoScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingHeightWeight,
      builder: (context, state) => const HeightWeightScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingGoals,
      builder: (context, state) => const GoalsScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingTargetReach,
      builder: (context, state) => const TargetReachScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingPrediction,
      builder: (context, state) => const WeightPredictionScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingActivityLevel,
      builder: (context, state) => const ActivityLevelScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingCalorieCut,
      builder: (context, state) => const CalorieCutScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingEatingStyle,
      builder: (context, state) => const EatingStyleScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingRecipePlan,
      builder: (context, state) => const RecipePlanScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingComplete,
      builder: (context, state) => const CompleteScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingTarget,
      builder: (context, state) => const TargetScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingDietPrefs,
      builder: (context, state) => const DietPrefsScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => NavigationShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.insights,
          builder: (context, state) => const InsightsScreen(),
        ),
        GoRoute(
          path: AppRoutes.planner,
          builder: (context, state) => const MealPlannerScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.foodLog,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final slot = state.uri.queryParameters['slot'];
        return FoodSearchScreen(initialSlot: slot);
      },
    ),
    GoRoute(
      path: AppRoutes.foodDetailPath,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extraFood = state.extra as FoodSearchItem?;
        final slotStr = state.uri.queryParameters['slot'];
        final mealSlot = MealType.values.firstWhere(
          (s) => s.name == slotStr,
          orElse: () => MealType.current(),
        );
        return FoodDetailScreen(
          foodId: id,
          initialFoodData: extraFood,
          initialMealSlot: mealSlot,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.barcodeScanner,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BarcodeScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.recipeBuilder,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecipeBuilderScreen(),
    ),
    GoRoute(
      path: AppRoutes.weightLog,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WeightLogScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

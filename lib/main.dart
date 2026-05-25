import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common/models/food_entry.dart';
import 'common/models/user_profile.dart';
import 'common/models/weight_entry.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/app_startup_data.dart';
import 'core/services/gemini_service.dart';
import 'common/providers/user_profile_provider.dart';
import 'common/providers/food_log_provider.dart';
import 'common/providers/water_intake_provider.dart';
import 'common/providers/weight_history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all persisted data before building the widget tree.
  // SharedPreferences is pre-warmed here so all subsequent reads are instant.
  final startupData = await AppStartupData.load();

  // Initialize GeminiService (loads the API key dynamically from environment or .env asset)
  await GeminiService.init();

  runApp(
    ProviderScope(
      overrides: [
        foodLogProvider.overrideWith(() => _SeedableFoodLog(startupData.foodLog)),
        waterIntakeProvider.overrideWith(
          () => _SeedableWaterIntake(startupData.waterIntakeMl),
        ),
        weightHistoryProvider.overrideWith(
          () => _SeedableWeightHistory(startupData.weightHistory),
        ),
        userProfileProvider.overrideWith(
          () => _SeedableUserProfile(startupData.userProfile),
        ),
      ],
      child: const CaloriePalApp(),
    ),
  );
}

// ─── Seeded Notifier subclasses ───────────────────────────────────────────────
// NotifierProvider.overrideWith() receives a factory that returns a Notifier.
// We override build() to return the pre-loaded initial value.

class _SeedableFoodLog extends FoodLogNotifier {
  _SeedableFoodLog(this._seed);
  final List<FoodEntry> _seed;
  @override
  List<FoodEntry> build() => List<FoodEntry>.from(_seed);
}

class _SeedableWaterIntake extends WaterIntakeNotifier {
  _SeedableWaterIntake(this._seed);
  final int _seed;
  @override
  int build() => _seed;
}

class _SeedableWeightHistory extends WeightHistoryNotifier {
  _SeedableWeightHistory(this._seed);
  final List<WeightEntry> _seed;
  @override
  List<WeightEntry> build() => List<WeightEntry>.from(_seed);
}

class _SeedableUserProfile extends UserProfileNotifier {
  _SeedableUserProfile(this._seed);
  final UserProfile _seed;
  @override
  UserProfile build() => _seed;
}

// ─────────────────────────────────────────────────────────────────────────────

class CaloriePalApp extends ConsumerWidget {
  const CaloriePalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'CaloriePal',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: appRouter,
        );
      },
    );
  }
}

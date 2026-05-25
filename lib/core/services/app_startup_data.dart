import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/user_profile.dart';
import 'package:calcount/common/models/weight_entry.dart';
import 'package:calcount/core/services/local_storage_service.dart';

/// Holds all persisted data loaded before the app starts.
/// Passed to ProviderScope.overrides so providers start with correct initial state.
class AppStartupData {
  const AppStartupData({
    required this.userProfile,
    required this.foodLog,
    required this.weightHistory,
    required this.waterIntakeMl,
  });

  final UserProfile userProfile;
  final List<FoodEntry> foodLog;
  final List<WeightEntry> weightHistory;
  final int waterIntakeMl;

  static Future<AppStartupData> load() async {
    // Pre-warm the SharedPreferences singleton once before parallel reads.
    await LocalStorageService.init();

    // All four reads now hit the in-memory singleton — truly parallel.
    final results = await Future.wait([
      LocalStorageService.loadUserProfile(),
      LocalStorageService.loadFoodLog(),
      LocalStorageService.loadWeightHistory(),
      LocalStorageService.loadWaterIntake(),
    ]);

    return AppStartupData(
      userProfile: (results[0] as UserProfile?) ?? UserProfile.initial(),
      foodLog: results[1] as List<FoodEntry>,
      weightHistory: results[2] as List<WeightEntry>,
      waterIntakeMl: results[3] as int,
    );
  }
}

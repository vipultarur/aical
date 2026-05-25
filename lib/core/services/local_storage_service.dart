import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/user_profile.dart';
import 'package:calcount/common/models/weight_entry.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';

/// Central service for all local persistence using SharedPreferences.
/// All data is serialized as JSON strings.
///
/// Uses a singleton [SharedPreferences] instance (cached after first load)
/// to avoid repeated async disk access on every save/load call.
class LocalStorageService {
  LocalStorageService._();

  static const _keyUserProfile = 'user_profile';
  static const _keyFoodLog = 'food_log';
  static const _keyWeightHistory = 'weight_history';
  static const _keyWaterPrefix = 'water_intake_'; // keyed by date YYYY-MM-DD
  static const _keyCustomFoods = 'custom_foods';

  // ─────────────────────── Singleton Prefs ────────────────────────────────

  static SharedPreferences? _prefs;

  /// Returns the cached [SharedPreferences] instance, initializing once.
  static Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Pre-warm the singleton during app startup (called from AppStartupData).
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─────────────────────── Debounced Save Timers ──────────────────────────

  static Timer? _foodLogSaveTimer;
  static Timer? _weightSaveTimer;
  static const Duration _saveDebounceDuration = Duration(milliseconds: 300);

  // ─────────────────────── User Profile ───────────────────────────────────

  static Future<UserProfile?> loadUserProfile() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyUserProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  // ─────────────────────── Food Log ───────────────────────────────────────

  static Future<List<FoodEntry>> loadFoodLog() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyFoodLog);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Debounced save — batches rapid successive calls (e.g. add + remove)
  /// into a single disk write after [_saveDebounceDuration].
  static void saveFoodLog(List<FoodEntry> entries) {
    _foodLogSaveTimer?.cancel();
    _foodLogSaveTimer = Timer(_saveDebounceDuration, () async {
      final prefs = await _getPrefs();
      final json = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_keyFoodLog, jsonEncode(json));
    });
  }

  // ─────────────────────── Weight History ─────────────────────────────────

  static Future<List<WeightEntry>> loadWeightHistory() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyWeightHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Debounced save — batches rapid weight log calls.
  static void saveWeightHistory(List<WeightEntry> entries) {
    _weightSaveTimer?.cancel();
    _weightSaveTimer = Timer(_saveDebounceDuration, () async {
      final prefs = await _getPrefs();
      final json = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_keyWeightHistory, jsonEncode(json));
    });
  }

  // ─────────────────────── Water Intake ───────────────────────────────────
  // Water resets each day — stored per date key.

  static String _waterKey([DateTime? date]) {
    final now = date ?? DateTime.now();
    return '$_keyWaterPrefix${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<int> loadWaterIntake([DateTime? date]) async {
    final prefs = await _getPrefs();
    return prefs.getInt(_waterKey(date)) ?? 0;
  }

  static Future<void> saveWaterIntake(int ml, [DateTime? date]) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_waterKey(date), ml);
  }

  // ─────────────────────── Custom Foods (Scanned) ─────────────────────────

  /// Load all custom foods saved from camera scanning features.
  static Future<List<FoodSearchItem>> loadCustomFoods() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyCustomFoods);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FoodSearchItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save all custom foods list to disk.
  static Future<void> saveCustomFoods(List<FoodSearchItem> foods) async {
    final prefs = await _getPrefs();
    final json = foods.map((e) => e.toJson()).toList();
    await prefs.setString(_keyCustomFoods, jsonEncode(json));
  }

  /// Add a single custom food and persist.
  static Future<void> addCustomFood(FoodSearchItem food) async {
    final existing = await loadCustomFoods();
    existing.insert(0, food); // newest first
    await saveCustomFoods(existing);
  }

  // ─────────────────────── Clear All ──────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:calcount/features/food_log/models/food_search_item.dart';

/// Service wrapping Google Gemini AI for food search and personalized insights.
///
/// API key is read from the `--dart-define=GEMINI_API_KEY=<your_key>` build
/// flag so it is never committed to source control.
class GeminiService {
  GeminiService._();

  static const _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static String? _dynamicApiKey;
  static GenerativeModel? _cachedModel;

  static GenerativeModel get _model {
    if (_cachedModel != null) return _cachedModel!;
    final key = _dynamicApiKey ?? _apiKey;
    _cachedModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
    );
    return _cachedModel!;
  }

  static Future<void> init() async {
    // 1. Try to load from environment first
    if (_apiKey.isNotEmpty) {
      _dynamicApiKey = _apiKey;
      _cachedModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );
      _log('Loaded GEMINI_API_KEY from String.fromEnvironment');
      return;
    }

    // 2. Try to load from bundled assets (.env)
    try {
      final content = await rootBundle.loadString('.env');
      final lines = content.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('GEMINI_API_KEY=')) {
          var value = trimmed.substring('GEMINI_API_KEY='.length).trim();
          if ((value.startsWith("'") && value.endsWith("'")) ||
              (value.startsWith('"') && value.endsWith('"'))) {
            value = value.substring(1, value.length - 1);
          }
          if (value.isNotEmpty) {
            _dynamicApiKey = value;
            _cachedModel = GenerativeModel(
              model: 'gemini-2.5-flash',
              apiKey: value,
            );
            _log('Loaded GEMINI_API_KEY from bundled .env asset');
            return;
          }
        }
      }
    } catch (e) {
      _log('Note: .env asset could not be loaded: $e');
    }
  }

  // ─────────────────────── Suggestion Cache ───────────────────────────────

  /// Cache key → (timestamp, results)
  static final Map<String, ({DateTime cachedAt, List<FoodSearchItem> items})>
      _suggestionCache = {};

  /// Cache for daily insights: date string → insight text
  static final Map<String, ({DateTime cachedAt, String text})> _insightCache =
      {};

  static final List<FoodSearchItem> _instant50Suggestions = [
    // --- 20 LIQUIDS (ml) ---
    const FoodSearchItem(name: "Recipe: Mango Avocado Smoothie", brand: "Generic", calories: 220, protein: 4, carbs: 28, fat: 11, fiber: 5, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Protein Iced Coffee", brand: "Generic", calories: 150, protein: 20, carbs: 5, fat: 3, fiber: 1, servingAmount: 300, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Green Detox Juice", brand: "Generic", calories: 80, protein: 2, carbs: 18, fat: 0, fiber: 2, servingAmount: 240, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Warm Lemon Ginger Tea", brand: "Generic", calories: 15, protein: 0, carbs: 4, fat: 0, fiber: 0, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Coconut Water (Fresh)", brand: "Generic", calories: 45, protein: 1, carbs: 11, fat: 0, fiber: 2, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Unsweetened Almond Milk", brand: "Generic", calories: 30, protein: 1, carbs: 1, fat: 2, fiber: 1, servingAmount: 240, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Mixed Berry Shake", brand: "Generic", calories: 210, protein: 18, carbs: 24, fat: 4, fiber: 6, servingAmount: 300, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Turmeric Golden Milk", brand: "Generic", calories: 120, protein: 4, carbs: 12, fat: 6, fiber: 1, servingAmount: 200, servingUnit: "ml"),
    const FoodSearchItem(name: "Organic Vegetable Broth", brand: "Generic", calories: 15, protein: 1, carbs: 3, fat: 0, fiber: 0, servingAmount: 240, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Strawberry Banana Smoothie", brand: "Generic", calories: 180, protein: 5, carbs: 35, fat: 2, fiber: 4, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Matcha Green Tea Latte", brand: "Generic", calories: 90, protein: 6, carbs: 10, fat: 3, fiber: 1, servingAmount: 200, servingUnit: "ml"),
    const FoodSearchItem(name: "Kombucha (Ginger Lemon)", brand: "Generic", calories: 35, protein: 0, carbs: 8, fat: 0, fiber: 0, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Pure Orange Juice", brand: "Generic", calories: 90, protein: 2, carbs: 21, fat: 0, fiber: 2, servingAmount: 200, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Chia Seed Pudding Drink", brand: "Generic", calories: 140, protein: 4, carbs: 16, fat: 7, fiber: 5, servingAmount: 200, servingUnit: "ml"),
    const FoodSearchItem(name: "Unsweetened Soy Milk", brand: "Generic", calories: 80, protein: 7, carbs: 4, fat: 4, fiber: 1, servingAmount: 240, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Mint Lemonade", brand: "Generic", calories: 40, protein: 0, carbs: 10, fat: 0, fiber: 0, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Whey Protein Shake", brand: "Generic", calories: 160, protein: 25, carbs: 3, fat: 2, fiber: 0, servingAmount: 300, servingUnit: "ml"),
    const FoodSearchItem(name: "Pomegranate Juice", brand: "Generic", calories: 130, protein: 1, carbs: 32, fat: 0, fiber: 0, servingAmount: 200, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Cucumber Mint Cooler", brand: "Generic", calories: 25, protein: 1, carbs: 5, fat: 0, fiber: 1, servingAmount: 250, servingUnit: "ml"),
    const FoodSearchItem(name: "Recipe: Bone Broth (Chicken)", brand: "Generic", calories: 45, protein: 9, carbs: 1, fat: 1, fiber: 0, servingAmount: 240, servingUnit: "ml"),

    // --- 30 SOLIDS (g) ---
    const FoodSearchItem(name: "Recipe: Greek Yogurt Parfait", brand: "Generic", calories: 150, protein: 15, carbs: 12, fat: 4, fiber: 2, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Tangerine Green Salad", brand: "Generic", calories: 120, protein: 2, carbs: 14, fat: 7, fiber: 3, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Grilled Salmon", brand: "Generic", calories: 180, protein: 22, carbs: 0, fat: 10, fiber: 0, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Avocado Sourdough Toast", brand: "Generic", calories: 260, protein: 7, carbs: 28, fat: 14, fiber: 6, servingAmount: 120, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Quinoa & Black Bean Bowl", brand: "Generic", calories: 210, protein: 8, carbs: 35, fat: 4, fiber: 7, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Scrambled Eggs with Spinach", brand: "Generic", calories: 200, protein: 14, carbs: 2, fat: 15, fiber: 1, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Peanut Butter Oatmeal", brand: "Generic", calories: 280, protein: 9, carbs: 42, fat: 10, fiber: 6, servingAmount: 180, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Chicken Breast with Broccoli", brand: "Generic", calories: 290, protein: 38, carbs: 8, fat: 6, fiber: 4, servingAmount: 200, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Chia Seed Pudding", brand: "Generic", calories: 160, protein: 4, carbs: 19, fat: 9, fiber: 8, servingAmount: 120, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Mixed Roasted Nuts", brand: "Generic", calories: 180, protein: 5, carbs: 6, fat: 16, fiber: 3, servingAmount: 30, servingUnit: "g"),
    const FoodSearchItem(name: "Fresh Tangerines", brand: "Generic", calories: 53, protein: 1, carbs: 13, fat: 0, fiber: 2, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Boiled Large Eggs", brand: "Generic", calories: 155, protein: 13, carbs: 1, fat: 11, fiber: 0, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Apple Slices with Almond Butter", brand: "Generic", calories: 190, protein: 4, carbs: 22, fat: 11, fiber: 4, servingAmount: 120, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Hummus & Baby Carrots", brand: "Generic", calories: 140, protein: 4, carbs: 18, fat: 6, fiber: 5, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Stir-Fry Tofu with Veggies", brand: "Generic", calories: 180, protein: 12, carbs: 14, fat: 9, fiber: 4, servingAmount: 200, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Roasted Sweet Potatoes", brand: "Generic", calories: 135, protein: 2, carbs: 31, fat: 0, fiber: 4, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Turkey & Cheese Roll-ups", brand: "Generic", calories: 140, protein: 18, carbs: 2, fat: 7, fiber: 0, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Garlic Butter Shrimp", brand: "Generic", calories: 170, protein: 20, carbs: 2, fat: 9, fiber: 0, servingAmount: 120, servingUnit: "g"),
    const FoodSearchItem(name: "Cottage Cheese with Pineapple", brand: "Generic", calories: 130, protein: 12, carbs: 15, fat: 3, fiber: 1, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Baked Salmon Fillet", brand: "Generic", calories: 280, protein: 34, carbs: 0, fat: 15, fiber: 0, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Steamed Edamame Pods", brand: "Generic", calories: 120, protein: 11, carbs: 9, fat: 5, fiber: 5, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Tuna Salad Lettuce Cups", brand: "Generic", calories: 160, protein: 22, carbs: 4, fat: 7, fiber: 1, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Dark Chocolate (70% Cocoa)", brand: "Generic", calories: 170, protein: 2, carbs: 15, fat: 12, fiber: 3, servingAmount: 30, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Whole Wheat Pita & Hummus", brand: "Generic", calories: 220, protein: 7, carbs: 34, fat: 6, fiber: 4, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Fresh Mixed Berries", brand: "Generic", calories: 60, protein: 1, carbs: 14, fat: 0, fiber: 3, servingAmount: 120, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Baked Chicken Breast", brand: "Generic", calories: 240, protein: 39, carbs: 0, fat: 5, fiber: 0, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Grilled Tofu Skewers", brand: "Generic", calories: 150, protein: 10, carbs: 8, fat: 9, fiber: 2, servingAmount: 150, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Sautéed Mushrooms", brand: "Generic", calories: 70, protein: 3, carbs: 5, fat: 5, fiber: 2, servingAmount: 100, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Rice Cakes with Peanut Butter", brand: "Generic", calories: 190, protein: 5, carbs: 22, fat: 9, fiber: 2, servingAmount: 50, servingUnit: "g"),
    const FoodSearchItem(name: "Recipe: Beef Jerky (Generic)", brand: "Generic", calories: 140, protein: 16, carbs: 5, fat: 3, fiber: 1, servingAmount: 50, servingUnit: "g"),
  ];

  static const Duration _suggestionTtl = Duration(minutes: 30);
  static const Duration _insightTtl = Duration(hours: 8);

  static void _log(String message) {
    // ignore: avoid_print
    print('[GeminiService] $message');
  }

  // ─────────────────────── Food Search ────────────────────────────────────

  /// Search for food items using Gemini AI.
  /// Returns a list of [FoodSearchItem] with real nutritional data.
  static Future<List<FoodSearchItem>> searchFood(String query) async {
    _log('searchFood requested with query: "$query"');
    if ((_dynamicApiKey ?? _apiKey).isEmpty) {
      _log('WARNING: GEMINI_API_KEY is empty! Please run your app with: --dart-define=GEMINI_API_KEY=your_key');
    }
    if (query.trim().isEmpty) return [];

    final prompt = '''
You are a precise nutritional database. The user is searching for food: "$query"

Return EXACTLY 8 food items matching or related to this search query.

CRITICAL REQUIREMENT:
- You MUST standardise all "servingUnit" and "servingAmount". 
- Do NOT use units like "piece", "serving", "cup", "slice", "container", "box", "pack", "oz", "tbsp", etc.
- If the food is a LIQUID (e.g. water, milk, soup, juice, beverage, oil, honey, dressing), the "servingUnit" MUST be "ml", and "servingAmount" must represent that liquid size.
- For all other foods (solids/recipes), the "servingUnit" MUST be "g", and "servingAmount" must represent the weight in grams.
- Make sure "calories", "protein", "carbs", "fat", and "fiber" are calculated EXACTLY according to that weight size.
  For example, do not say Scrambled Eggs is 3 piece; say Scrambled Eggs has a servingAmount of 150 (grams) with 240 calories, 19 protein, 2 carbs, 16 fat, 0 fiber.

For each food, return ONLY a JSON array (no markdown, no explanation) in this format:

[
  {
    "name": "exact food name",
    "brand": "brand or 'Generic'",
    "calories": <integer per serving>,
    "protein": <integer grams per serving>,
    "carbs": <integer grams per serving>,
    "fat": <integer grams per serving>,
    "fiber": <integer grams per serving>,
    "servingAmount": <number>,
    "servingUnit": "g or ml"
  }
]

Use accurate, real nutritional data. Return ONLY the raw JSON array, nothing else.
''';

    _log('Sending searchFood prompt to Gemini...');
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      _log('Received raw response from Gemini:\n$text');
      final results = _parseJsonToFoodItems(text);
      _log('Parsed ${results.length} items successfully.');
      return results;
    } catch (e) {
      _log('ERROR in searchFood: $e');
      return [];
    }
  }

  // ─────────────────────── Personalized Suggestions ───────────────────────

  /// Generate personalized food & recipe suggestions based on user profile.
  /// Results are cached for [_suggestionTtl] per unique user/meal context.
  static Future<List<FoodSearchItem>> getPersonalizedSuggestions({
    required String goal,
    required String activityLevel,
    required List<String> dietPrefs,
    required int calorieTarget,
    required int caloriesConsumed,
    required String mealType,
    required double weight,
    required String weightUnit,
    required double targetWeight,
  }) async {
    _log('getPersonalizedSuggestions requested for mealType: $mealType');
    if ((_dynamicApiKey ?? _apiKey).isEmpty) {
      _log('WARNING: GEMINI_API_KEY is empty! Please run your app with: --dart-define=GEMINI_API_KEY=your_key');
    }

    // Round consumed calories to nearest 50 to avoid cache misses on tiny changes
    final roundedConsumed = (caloriesConsumed / 50).round() * 50;
    final cacheKey =
        '$goal|$mealType|$roundedConsumed|${dietPrefs.join(",")}';

    final cached = _suggestionCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.cachedAt) < _suggestionTtl) {
      _log('Cache hit! Returning ${cached.items.length} cached suggestions.');
      return cached.items;
    }

    // Launch background generation so cache is primed and ready, but DO NOT await it!
    Future.microtask(() async {
      _log('Background fetch started to prime cache...');
      try {
        final remaining = calorieTarget - caloriesConsumed;
        final dietStr =
            dietPrefs.isNotEmpty ? dietPrefs.join(', ') : 'No specific preference';

        final prompt = '''
You are an expert nutritionist and personal chef AI. Generate personalized food and recipe suggestions for this user.

User Profile:
- Health Goal: $goal
- Activity Level: $activityLevel
- Dietary Preferences: $dietStr
- Daily Calorie Target: $calorieTarget kcal
- Calories Already Consumed Today: $caloriesConsumed kcal
- Remaining Calories for Today: $remaining kcal
- Current Meal: $mealType
- Current Weight: ${weight.toStringAsFixed(1)} $weightUnit
- Target Weight: ${targetWeight.toStringAsFixed(1)} $weightUnit

Based on this profile, suggest EXACTLY 10 highly relevant, nutritious foods or simple recipes.
- Prioritize foods appropriate for their goal ($goal)
- Respect dietary preferences: $dietStr
- Keep calories per item reasonable for a $mealType meal
- Mix real whole foods AND simple recipes (mark recipes with "Recipe:" prefix in the name)
- Use accurate real-world nutritional values

CRITICAL REQUIREMENT:
- You MUST standardise all "servingUnit" and "servingAmount". 
- Do NOT use units like "piece", "serving", "cup", "slice", "container", "box", "pack", "oz", "tbsp", etc.
- If the food is a LIQUID (e.g. water, milk, soup, juice, beverage, oil, honey, dressing), the "servingUnit" MUST be "ml", and "servingAmount" must represent that liquid size.
- For all other foods (solids/recipes), the "servingUnit" MUST be "g", and "servingAmount" must represent the weight in grams.
- Make sure "calories", "protein", "carbs", "fat", and "fiber" are calculated EXACTLY according to that weight size.
  For example, do not say Scrambled Eggs is 3 piece; say Scrambled Eggs has a servingAmount of 150 (grams) with 240 calories, 19 protein, 2 carbs, 16 fat, 0 fiber.

Return ONLY a raw JSON array (no markdown, no explanation):

[
  {
    "name": "food or Recipe: recipe name",
    "brand": "Generic or specific brand",
    "calories": <integer kcal per serving>,
    "protein": <integer grams>,
    "carbs": <integer grams>,
    "fat": <integer grams>,
    "fiber": <integer grams>,
    "servingAmount": <number>,
    "servingUnit": "g or ml"
  }
]
''';

        final response = await _model.generateContent([Content.text(prompt)]);
        final text = response.text ?? '';
        final items = _parseJsonToFoodItems(text);
        if (items.isNotEmpty) {
          _suggestionCache[cacheKey] = (cachedAt: DateTime.now(), items: items);
          _log('Background fetch successfully updated cache with ${items.length} items.');
        }
      } catch (e) {
        _log('ERROR in background suggestions fetch: $e');
      }
    });

    // Instantly return the pre-generated 50 items list (20 liquids + 30 solids)
    _log('Instant return! Giving user pre-generated 50 items (20 liquids, 30 solids).');
    return _instant50Suggestions;
  }

  // ─────────────────────── Daily Insight ──────────────────────────────────

  /// Get a personalized daily insight from Gemini based on user data.
  /// Result is cached per-day (8-hour TTL) keyed by user + date.
  static Future<String> getDailyInsight({
    required String name,
    required String goal,
    required int calorieTarget,
    required int caloriesConsumed,
    required int waterTarget,
    required int waterLogged,
    required double currentWeight,
    required double targetWeight,
    required String weightUnit,
    required String activityLevel,
  }) async {
    _log('getDailyInsight requested for $name');
    if ((_dynamicApiKey ?? _apiKey).isEmpty) {
      _log('WARNING: GEMINI_API_KEY is empty! Please run your app with: --dart-define=GEMINI_API_KEY=your_key');
    }

    final today = DateTime.now();
    final roundedConsumed = (caloriesConsumed / 50).round() * 50;
    final cacheKey =
        '${today.year}-${today.month}-${today.day}|$name|$goal|$roundedConsumed';

    final cached = _insightCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.cachedAt) < _insightTtl) {
      _log('Cache hit! Returning cached insight: "${cached.text}"');
      return cached.text;
    }

    final remainingCalories = calorieTarget - caloriesConsumed;
    final waterPercent =
        waterTarget > 0 ? ((waterLogged / waterTarget) * 100).round() : 0;

    final prompt = '''
You are a personal health coach AI. Give a short, motivating daily health insight for this user.

User Profile:
- Name: $name
- Goal: $goal
- Activity Level: $activityLevel
- Calorie Target: $calorieTarget kcal/day
- Calories Consumed Today: $caloriesConsumed kcal
- Remaining Calories: $remainingCalories kcal
- Water Target: ${waterTarget}ml
- Water Logged: ${waterLogged}ml ($waterPercent% of goal)
- Current Weight: ${currentWeight.toStringAsFixed(1)} $weightUnit
- Target Weight: ${targetWeight.toStringAsFixed(1)} $weightUnit

Write a SHORT (2-3 sentences max), personalized, actionable tip or encouragement for today.
Be specific to their numbers. Be friendly and motivating. 
Do NOT use markdown or bullet points. Plain text only.
''';

    _log('Sending getDailyInsight prompt to Gemini...');
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ??
          'Stay consistent with your goals today! Every healthy choice brings you closer to your target.';
      _log('Received raw response from Gemini:\n$text');
      _insightCache[cacheKey] = (cachedAt: DateTime.now(), text: text);
      return text;
    } catch (e) {
      _log('ERROR in getDailyInsight: $e');
      return 'Stay consistent with your goals today! Every healthy choice brings you closer to your target.';
    }
  }

  // ─────────────────────── Cache Control ──────────────────────────────────

  /// Clears the suggestion cache (e.g. after profile changes).
  static void clearSuggestionCache() => _suggestionCache.clear();

  /// Clears all caches.
  static void clearAllCaches() {
    _suggestionCache.clear();
    _insightCache.clear();
  }

  // ─────────────────────── Helpers ────────────────────────────────────────

  /// Shared JSON parser for food item lists.
  static List<FoodSearchItem> _parseJsonToFoodItems(String text) {
    _log('Parsing JSON from response text of length: ${text.length}');
    final jsonStart = text.indexOf('[');
    final jsonEnd = text.lastIndexOf(']') + 1;
    if (jsonStart == -1 || jsonEnd <= jsonStart) {
      _log('WARNING: Could not find valid JSON array bounds in response text.');
      return [];
    }

    try {
      final jsonStr = text.substring(jsonStart, jsonEnd);
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;

      final results = jsonList.map<FoodSearchItem>((json) {
        final map = json as Map<String, dynamic>;
        return FoodSearchItem(
          name: (map['name'] as String?) ?? 'Unknown Food',
          brand: (map['brand'] as String?) ?? 'Generic',
          calories: _toInt(map['calories']),
          protein: _toInt(map['protein']),
          carbs: _toInt(map['carbs']),
          fat: _toInt(map['fat']),
          fiber: _toInt(map['fiber']),
          servingAmount: _toDouble(map['servingAmount']),
          servingUnit: (map['servingUnit'] as String?) ?? 'g',
        );
      }).toList();
      _log('Successfully parsed ${results.length} food items.');
      return results;
    } catch (e) {
      _log('ERROR while parsing food items JSON: $e');
      return [];
    }
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 100.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 100.0;
    return 100.0;
  }

  // ─────────────────────── Single Item Parser ─────────────────────────────

  /// Parse a single food item JSON object from a text response.
  static FoodSearchItem? _parseSingleFoodItem(String text) {
    _log('Parsing single food item from response of length: ${text.length}');

    // Try JSON object first
    final objStart = text.indexOf('{');
    final objEnd = text.lastIndexOf('}') + 1;
    if (objStart != -1 && objEnd > objStart) {
      try {
        final jsonStr = text.substring(objStart, objEnd);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return FoodSearchItem(
          name: (map['name'] as String?) ?? 'Scanned Food',
          brand: (map['brand'] as String?) ?? 'Scanned',
          calories: _toInt(map['calories']),
          protein: _toInt(map['protein']),
          carbs: _toInt(map['carbs']),
          fat: _toInt(map['fat']),
          fiber: _toInt(map['fiber']),
          servingAmount: _toDouble(map['servingAmount']),
          servingUnit: (map['servingUnit'] as String?) ?? 'g',
        );
      } catch (e) {
        _log('ERROR parsing single food item: $e');
      }
    }

    // Try JSON array and take first
    final items = _parseJsonToFoodItems(text);
    if (items.isNotEmpty) return items.first;

    return null;
  }

  // ─────────────── Food Photo Analysis (Gemini Vision) ────────────────

  /// Analyze a food photo using Gemini Vision to identify the food and estimate nutrition.
  static Future<FoodSearchItem?> analyzeFoodPhoto(Uint8List imageBytes) async {
    _log('analyzeFoodPhoto called with ${imageBytes.length} bytes');
    if ((_dynamicApiKey ?? _apiKey).isEmpty) {
      _log('WARNING: GEMINI_API_KEY is empty!');
      return null;
    }

    const prompt = '''
You are an expert nutritionist and food recognition AI with precise calorie estimation skills.
Carefully analyze this food photo.

STEP 1: Identify exactly what food(s) are visible in the image.
STEP 2: Estimate the portion size in grams (or ml for liquids) based on visual cues like plate size, utensil size, hand size, container volume.
STEP 3: Calculate accurate nutritional values based on USDA/standard food composition databases for the estimated portion.

IMPORTANT ACCURACY RULES:
- Do NOT inflate or deflate calorie counts. Use standard USDA nutritional values.
- Cross-check: calories should roughly equal (protein*4) + (carbs*4) + (fat*9).
- Estimate portion size realistically. A typical dinner plate is 26cm diameter. A typical bowl holds 300-400ml.
- If multiple food items are visible, combine them into a single descriptive entry and sum the nutrition.
- If the image is NOT food (e.g. a person, animal, landscape, object), return the word "null" — do NOT make up food data.
- If it is a liquid, use "ml" for servingUnit. If solid food, use "g" for servingUnit.

Return EXACTLY ONE JSON object (no markdown, no explanation):

{
  "name": "identified food name",
  "brand": "Generic",
  "calories": <integer kcal for the visible portion>,
  "protein": <integer grams>,
  "carbs": <integer grams>,
  "fat": <integer grams>,
  "fiber": <integer grams>,
  "servingAmount": <estimated weight/volume as number>,
  "servingUnit": "g or ml"
}

Return ONLY the raw JSON object, or the word "null" if this is not food.
''';

    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);
      final text = response.text ?? '';
      _log('Food photo analysis response:\n$text');
      if (text.trim().toLowerCase() == 'null') return null;
      return _parseSingleFoodItem(text);
    } catch (e) {
      _log('ERROR in analyzeFoodPhoto: $e');
      return null;
    }
  }

  // ─────────────── Ingredients / Nutrition Label Analysis ──────────────────

  /// Analyze an ingredients or nutrition label photo using Gemini Vision.
  static Future<FoodSearchItem?> analyzeIngredientsPhoto(Uint8List imageBytes) async {
    _log('analyzeIngredientsPhoto called with ${imageBytes.length} bytes');
    if ((_dynamicApiKey ?? _apiKey).isEmpty) {
      _log('WARNING: GEMINI_API_KEY is empty!');
      return null;
    }

    const prompt = '''
You are an expert OCR system specialized in reading food packaging, nutrition facts panels, and ingredient lists.
Carefully analyze this photo and extract ALL nutritional data visible.

READING INSTRUCTIONS:
- Read the EXACT numbers printed on the nutrition label. Do NOT estimate or guess values when they are clearly printed.
- Look for: Calories/Energy, Total Fat, Saturated Fat, Carbohydrates/Total Carbs, Dietary Fiber, Protein.
- Read the serving size from the label (e.g. "Serving Size: 30g" or "Per 100ml").
- Read the product name and brand if visible on the packaging.
- If the label shows values "per 100g" AND "per serving", prefer the "per serving" values.
- If only "per 100g" or "per 100ml" values are shown, use those with servingAmount = 100.

ACCURACY RULES:
- Use EXACTLY the numbers printed on the label — do not round or modify them.
- Cross-check: calories should roughly equal (protein*4) + (carbs*4) + (fat*9). If the label says otherwise, trust the label.
- If this is NOT a nutrition label or food packaging, return the word "null".
- servingUnit must be "g" for solids and "ml" for liquids.

Return EXACTLY ONE JSON object (no markdown, no explanation):

{
  "name": "product name from the label",
  "brand": "brand name if visible, otherwise 'Generic'",
  "calories": <integer kcal per serving>,
  "protein": <integer grams per serving>,
  "carbs": <integer grams per serving>,
  "fat": <integer grams per serving>,
  "fiber": <integer grams per serving>,
  "servingAmount": <serving size number>,
  "servingUnit": "g or ml"
}

Return ONLY the raw JSON object, or the word "null" if this is not a food label.
''';

    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);
      final text = response.text ?? '';
      _log('Ingredients photo analysis response:\n$text');
      if (text.trim().toLowerCase() == 'null') return null;
      return _parseSingleFoodItem(text);
    } catch (e) {
      _log('ERROR in analyzeIngredientsPhoto: $e');
      return null;
    }
  }

  // ──────────────────────── Barcode Lookup ─────────────────────────────────

  /// Look up a food product by barcode using Open Food Facts API (real database).
  /// Falls back to Gemini AI if the barcode is not found in the database.
  static Future<FoodSearchItem?> lookupBarcode(String barcodeValue) async {
    _log('lookupBarcode called with barcode: $barcodeValue');

    // 1. Try Open Food Facts API first (real product database)
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcodeValue.json?fields=product_name,brands,nutriments,serving_quantity,serving_quantity_unit',
      );
      _log('Querying Open Food Facts API: $url');

      final response = await http.get(url, headers: {
        'User-Agent': 'CaloriePal/1.0 (Flutter App)',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as int? ?? 0;

        if (status == 1 && data['product'] != null) {
          final product = data['product'] as Map<String, dynamic>;
          final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
          final productName = (product['product_name'] as String?)?.trim() ?? '';
          final brand = (product['brands'] as String?)?.trim() ?? 'Generic';

          if (productName.isNotEmpty) {
            // Get serving size — default to 100g if not specified
            double servingAmount = 100.0;
            String servingUnit = 'g';

            final servingQty = product['serving_quantity'];
            if (servingQty != null) {
              servingAmount = _toDouble(servingQty);
              if (servingAmount <= 0) servingAmount = 100.0;
            }
            final servingQtyUnit = product['serving_quantity_unit'] as String?;
            if (servingQtyUnit != null && servingQtyUnit.toLowerCase().contains('ml')) {
              servingUnit = 'ml';
            }

            // Prefer per-serving values if available, otherwise use per-100g and scale
            int calories, protein, carbs, fat, fiber;

            if (nutriments.containsKey('energy-kcal_serving')) {
              calories = _toInt(nutriments['energy-kcal_serving']);
              protein = _toInt(nutriments['proteins_serving']);
              carbs = _toInt(nutriments['carbohydrates_serving']);
              fat = _toInt(nutriments['fat_serving']);
              fiber = _toInt(nutriments['fiber_serving']);
            } else {
              // Use per-100g values and scale to serving amount
              final scale = servingAmount / 100.0;
              calories = (_toDouble(nutriments['energy-kcal_100g']) * scale).round();
              protein = (_toDouble(nutriments['proteins_100g']) * scale).round();
              carbs = (_toDouble(nutriments['carbohydrates_100g']) * scale).round();
              fat = (_toDouble(nutriments['fat_100g']) * scale).round();
              fiber = (_toDouble(nutriments['fiber_100g']) * scale).round();
            }

            // If calories is 0 but we have energy in kJ, convert
            if (calories == 0) {
              final energyKj = _toDouble(nutriments['energy_100g']);
              if (energyKj > 0) {
                final scale = servingAmount / 100.0;
                calories = (energyKj * 0.239006 * scale).round();
              }
            }

            final item = FoodSearchItem(
              name: productName,
              brand: brand.isNotEmpty ? brand : 'Generic',
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
              fiber: fiber,
              servingAmount: servingAmount,
              servingUnit: servingUnit,
            );

            _log('✅ Open Food Facts found: ${item.name} by ${item.brand} — ${item.calories} kcal');
            return item;
          }
        }
      }
      _log('Open Food Facts did not find barcode $barcodeValue (status: ${response.statusCode})');
    } catch (e) {
      _log('Open Food Facts API error: $e');
    }

    // 2. Fallback to Gemini AI lookup
    _log('Falling back to Gemini AI for barcode lookup...');
    if ((_dynamicApiKey ?? _apiKey).isEmpty) {
      _log('WARNING: GEMINI_API_KEY is empty!');
      return null;
    }

    final prompt = '''
You are a food product database expert.
Look up the food product with this barcode/EAN/UPC number: "$barcodeValue"

Return EXACTLY ONE JSON object (no markdown, no explanation) with the product's nutritional info:

{
  "name": "product name",
  "brand": "brand name",
  "calories": <integer kcal per serving>,
  "protein": <integer grams per serving>,
  "carbs": <integer grams per serving>,
  "fat": <integer grams per serving>,
  "fiber": <integer grams per serving>,
  "servingAmount": <serving size number>,
  "servingUnit": "g or ml"
}

RULES:
- If you recognize this barcode, return accurate product information
- If you don't recognize the exact barcode, return null — do NOT guess or make up data
- servingUnit must be "g" for solids and "ml" for liquids
- Return ONLY the raw JSON object, or the word "null" if unknown
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      _log('Barcode lookup response:\n$text');
      if (text.trim().toLowerCase() == 'null') return null;
      return _parseSingleFoodItem(text);
    } catch (e) {
      _log('ERROR in lookupBarcode (Gemini fallback): $e');
      return null;
    }
  }
}


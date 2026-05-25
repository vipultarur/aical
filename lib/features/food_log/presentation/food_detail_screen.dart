import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/food_log_provider.dart';
import 'package:calcount/common/widgets/app_snack_bar.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  const FoodDetailScreen({
    required this.foodId,
    super.key,
    this.initialFoodData,
    this.initialMealSlot,
  });

  final String foodId;
  final FoodSearchItem? initialFoodData;
  final MealType? initialMealSlot;

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  static const _fallbackFood = FoodSearchItem(
    name: 'Kale, cooked',
    brand: 'Standard',
    calories: 36,
    protein: 3,
    carbs: 7,
    fat: 1,
    fiber: 4,
    servingAmount: 100,
    servingUnit: 'g',
  );

  String _normalizeUnit(String unit) {
    final u = unit.toLowerCase().trim();
    if (u.contains('ml') ||
        u.contains('fl') ||
        u.contains('glass') ||
        u.contains('liquid') ||
        u.contains('cup') ||
        u.contains('coffee') ||
        u.contains('water')) {
      return 'ml';
    }
    return 'g';
  }

  late FoodSearchItem _foodData;
  late MealType _selectedMealSlot;

  // Bottom interactive state
  bool _isKeyboardVisible = false;
  String _inputAmount = '100.0';
  late String _selectedUnit;
  bool _isStarred = false;

  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final baseFood = widget.initialFoodData ?? _fallbackFood;
    
    final rawUnit = baseFood.servingUnit.toLowerCase().trim();
    double convertedAmount = baseFood.servingAmount;
    String convertedUnit = 'g';
    
    // Check if it is a liquid
    final isLiquid = rawUnit.contains('ml') ||
        rawUnit.contains('fl') ||
        rawUnit.contains('glass') ||
        rawUnit.contains('liquid') ||
        rawUnit.contains('cup') && (baseFood.name.toLowerCase().contains('water') || baseFood.name.toLowerCase().contains('juice') || baseFood.name.toLowerCase().contains('coffee') || baseFood.name.toLowerCase().contains('oil') || baseFood.name.toLowerCase().contains('milk') || baseFood.name.toLowerCase().contains('honey')) ||
        rawUnit.contains('coffee') ||
        rawUnit.contains('water') ||
        rawUnit.contains('juice') ||
        rawUnit.contains('dressing');

    if (isLiquid) {
      convertedUnit = 'ml';
      if (rawUnit == 'cup') {
        convertedAmount = baseFood.servingAmount * 240.0;
      } else if (rawUnit.contains('fl. oz') || rawUnit.contains('oz')) {
        convertedAmount = baseFood.servingAmount * 29.57;
      } else if (rawUnit.contains('glass')) {
        convertedAmount = baseFood.servingAmount * 250.0;
      } else if (rawUnit == 'serving' || rawUnit == 'piece' || baseFood.servingAmount <= 5.0) {
        convertedAmount = baseFood.servingAmount * 200.0; // default 1 serving of drink to 200ml
      }
    } else {
      convertedUnit = 'g';
      if (rawUnit == 'cup') {
        convertedAmount = baseFood.servingAmount * 150.0;
      } else if (rawUnit.contains('oz')) {
        convertedAmount = baseFood.servingAmount * 28.35;
      } else if (rawUnit == 'serving' || rawUnit == 'piece' || baseFood.servingAmount <= 5.0) {
        convertedAmount = baseFood.servingAmount * 100.0; // default 1 serving of solid food to 100g
      }
    }

    _foodData = FoodSearchItem(
      name: baseFood.name,
      brand: baseFood.brand,
      calories: baseFood.calories,
      protein: baseFood.protein,
      carbs: baseFood.carbs,
      fat: baseFood.fat,
      fiber: baseFood.fiber,
      servingAmount: convertedAmount,
      servingUnit: convertedUnit,
    );
    _selectedMealSlot = widget.initialMealSlot ?? MealType.current();
    _selectedUnit = convertedUnit;
    _inputAmount = _foodData.servingAmount.toStringAsFixed(1);

    // Default star state for Kale cooked to match Image 1
    if (_foodData.name.toLowerCase().contains('kale')) {
      _isStarred =
          false; // standard is unstarred by default, user can click to star
    }

    _amountController = TextEditingController(text: _inputAmount);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      _inputAmount = _amountController.text;
    });
  }

  double _getServingsMultiplier() {
    final amount = double.tryParse(_inputAmount) ?? 100.0;
    final baseUnit = _foodData.servingUnit.toLowerCase();
    final targetUnit = _selectedUnit.toLowerCase();

    if (baseUnit == targetUnit) {
      return amount / _foodData.servingAmount;
    }

    double amountInBase = amount;
    if (baseUnit == 'g') {
      if (targetUnit == 'cup') {
        amountInBase = amount * 240.0;
      } else if (targetUnit == 'serving' || targetUnit == 'piece') {
        amountInBase = amount * 100.0;
      } else if (targetUnit == 'oz.') {
        amountInBase = amount * 28.35;
      }
    } else if (baseUnit == 'ml') {
      if (targetUnit == 'glass') {
        amountInBase = amount * 250.0;
      } else if (targetUnit == 'fl. oz.') {
        amountInBase = amount * 29.57;
      }
    }

    return amountInBase / _foodData.servingAmount;
  }

  // Realistic mock nutrient functions based on food item and multiplier
  double _getSugar(double servings) {
    final name = _foodData.name.toLowerCase();
    if (name.contains('kale')) return 1.2 * servings;
    if (name.contains('tangerine')) return 9.9 * servings;
    if (name.contains('greek yogurt')) return 4.0 * servings;
    if (name.contains('salmon')) return 0.0;
    return (_foodData.carbs * 0.25) * servings;
  }

  double _getDietaryFiber(double servings) {
    final name = _foodData.name.toLowerCase();
    if (name.contains('kale')) return 4.0 * servings;
    if (name.contains('tangerine')) return 0.2 * servings;
    if (name.contains('greek yogurt')) return 0.0;
    if (name.contains('salmon')) return 0.0;
    return _foodData.fiber.toDouble() * servings;
  }

  double _getSaturatedFat(double servings) {
    final name = _foodData.name.toLowerCase();
    if (name.contains('kale')) return 0.2 * servings;
    if (name.contains('tangerine')) return 0.05 * servings; // Shows < 0.1g
    if (name.contains('greek yogurt')) return 2.5 * servings;
    if (name.contains('salmon')) return 3.1 * servings;
    return (_foodData.fat * 0.15) * servings;
  }

  double _getMonounsaturatedFat(double servings) {
    final name = _foodData.name.toLowerCase();
    if (name.contains('kale')) return 0.1 * servings;
    if (name.contains('tangerine')) return 0.02 * servings; // Shows < 0.1g
    if (name.contains('greek yogurt')) return 1.0 * servings;
    if (name.contains('salmon')) return 5.2 * servings;
    return (_foodData.fat * 0.6) * servings;
  }

  List<({String name, double baseAmount, String unit})> _getIngredients() {
    final name = _foodData.name.toLowerCase();

    // Determine if food is a recipe or specific food item, and break down its ingredients.
    if (name.contains('yogurt') || name.contains('parfait')) {
      return [
        (name: 'Greek Yogurt (Full-Fat)', baseAmount: 120.0, unit: 'g'),
        (name: 'Mixed Fresh Berries', baseAmount: 20.0, unit: 'g'),
        (name: 'Organic Honey', baseAmount: 10.0, unit: 'ml'), // honey is liquid -> ml
      ];
    }
    if (name.contains('salad') || name.contains('tangerine')) {
      return [
        (name: 'Fresh Tangerine Segments', baseAmount: 50.0, unit: 'g'),
        (name: 'Mixed Baby Greens & Spinach', baseAmount: 35.0, unit: 'g'),
        (name: 'Olive Oil Vinaigrette', baseAmount: 10.0, unit: 'ml'), // dressing -> ml
        (name: 'Feta Cheese Crumbles', baseAmount: 5.0, unit: 'g'),
      ];
    }
    if (name.contains('kale')) {
      return [
        (name: 'Organic Curly Kale Leaves', baseAmount: 85.0, unit: 'g'),
        (name: 'Extra Virgin Olive Oil', baseAmount: 10.0, unit: 'ml'), // liquid -> ml
        (name: 'Lemon Juice & Sea Salt', baseAmount: 5.0, unit: 'ml'),  // liquid -> ml
      ];
    }
    if (name.contains('salmon')) {
      return [
        (name: 'Atlantic Salmon Fillet', baseAmount: 90.0, unit: 'g'),
        (name: 'Cold-Pressed Olive Oil', baseAmount: 8.0, unit: 'ml'),  // liquid -> ml
        (name: 'Freshly Squeezed Lemon Juice', baseAmount: 2.0, unit: 'ml'), // liquid -> ml
      ];
    }

    // Default fallback breakdown: if it is a single food item, list its main ingredient.
    final unit = _normalizeUnit(_foodData.servingUnit);
    return [
      (name: _foodData.name, baseAmount: _foodData.servingAmount, unit: unit),
    ];
  }

  void _onKeyPress(String val) {
    final text = _amountController.text;
    final selection = _amountController.selection;
    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    String newText;
    int newCursorPos;

    if (val == 'backspace') {
      if (start == end) {
        if (start > 0) {
          newText = text.substring(0, start - 1) + text.substring(start);
          newCursorPos = start - 1;
        } else {
          newText = text;
          newCursorPos = 0;
        }
      } else {
        newText = text.substring(0, start) + text.substring(end);
        newCursorPos = start;
      }
      if (newText.isEmpty) {
        newText = '0.0';
        newCursorPos = 3;
      }
    } else if (val == '.') {
      if (!text.contains('.')) {
        newText = '${text.substring(0, start)}.${text.substring(end)}';
        newCursorPos = start + 1;
      } else {
        newText = text;
        newCursorPos = start;
      }
    } else {
      if (text == '0.0' || text == '0') {
        newText = val;
        newCursorPos = val.length;
      } else {
        newText = text.substring(0, start) + val + text.substring(end);
        newCursorPos = start + val.length;
      }
    }

    _amountController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  void _logFood() {
    final amount = double.tryParse(_inputAmount) ?? 100.0;
    final servings = _getServingsMultiplier();
    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _foodData.name,
      brand: _foodData.brand,
      calories: (_foodData.calories * servings).round(),
      protein: (_foodData.protein * servings).round(),
      carbs: (_foodData.carbs * servings).round(),
      fat: (_foodData.fat * servings).round(),
      fiber: (_foodData.fiber * servings).round(),
      servingAmount: amount,
      servingUnit: _selectedUnit,
      mealType: _selectedMealSlot,
      loggedAt: DateTime.now(),
    );

    ref.read(foodLogProvider.notifier).addFood(entry);
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic Servings multiplier based on inputs
    final servings = _getServingsMultiplier();

    // Dynimcally scaled nutrients
    final calories = (_foodData.calories * servings).round();
    final carbs = _foodData.carbs * servings;
    final protein = _foodData.protein * servings;
    final fat = _foodData.fat * servings;

    // Macro Calorie Contributions
    final carbsCal = carbs * 4.0;
    final proteinCal = protein * 4.0;
    final fatCal = fat * 9.0;
    final totalMacroCal = carbsCal + proteinCal + fatCal;

    // Relative percentages
    final double carbsPercent = totalMacroCal > 0
        ? (carbsCal / totalMacroCal) * 100
        : 0;
    final double proteinPercent = totalMacroCal > 0
        ? (proteinCal / totalMacroCal) * 100
        : 0;
    final double fatPercent = totalMacroCal > 0
        ? (fatCal / totalMacroCal) * 100
        : 0;

    // Custom formattings for nutrients
    String formatNutrient(double val) {
      if (val == 0.0) return '0.0g';
      if (val < 0.1) return '< 0.1g';
      return '${val.toStringAsFixed(1)}g';
    }

    return Scaffold(
      backgroundColor: isDark ? colors.surface : const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF64748B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Food facts',
          style: AppTypography.headingLg(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AppSnackBar.show(
                context,
                message: 'Food reported successfully!',
                type: AppSnackBarType.success,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? colors.outline : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 14,
                    color: isDark
                        ? Colors.grey.shade400
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isKeyboardVisible) {
            setState(() {
              _isKeyboardVisible = false;
            });
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PREMIUM MAIN CARD
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isDark
                                ? colors.outline
                                : const Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                        ),
                        color: isDark
                            ? colors.surfaceContainerLowest
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // TOP ROW: Icon + Name + Star
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEFF6FF,
                                      ), // soft light blue background
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      LucideIcons.utensilsCrossed,
                                      color: Color(0xFF3B82F6), // blue icon
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      _foodData.name,
                                      style: AppTypography.headingXl(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isStarred
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: _isStarred
                                          ? Colors.amber
                                          : Colors.grey.shade400,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isStarred = !_isStarred;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // BOTTOM ROW: Ring Chart + Macro Indicators
                              Row(
                                children: [
                                  // RING CHART
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: SizedBox(
                                            width:
                                                130, // slightly larger base to scale down nicely
                                            height: 130,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox.expand(
                                                  child: CustomPaint(
                                                    painter: SegmentedDonutPainter(
                                                      carbsFraction:
                                                          carbsPercent,
                                                      proteinFraction:
                                                          proteinPercent,
                                                      fatFraction: fatPercent,
                                                      carbsColor: const Color(
                                                        0xFF4BAE4F,
                                                      ), // Green
                                                      proteinColor: const Color(
                                                        0xFFEE8A3A,
                                                      ), // Orange
                                                      fatColor: const Color(
                                                        0xFFF9C80E,
                                                      ), // Yellow
                                                      backgroundColor: isDark
                                                          ? colors
                                                                .surfaceContainerHighest
                                                          : const Color(
                                                              0xFFE2E8F0,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '$calories',
                                                      style:
                                                          AppTypography.displayLg(
                                                            color: isDark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF0F172A,
                                                                  ),
                                                          ).copyWith(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 32,
                                                          ),
                                                    ),
                                                    Text(
                                                      'kcal',
                                                      style:
                                                          AppTypography.labelMd(
                                                            color: const Color(
                                                              0xFF64748B,
                                                            ),
                                                          ).copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${(double.tryParse(_inputAmount) ?? 100.0).toStringAsFixed(1)} $_selectedUnit',
                                          style:
                                              AppTypography.bodySm(
                                                color: const Color(0xFF64748B),
                                              ).copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // MACRO INDICATORS
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildMacroIndicatorRow(
                                          label: 'Carbs',
                                          grams: '${carbs.toStringAsFixed(1)}g',
                                          percent:
                                              '${carbsPercent.toStringAsFixed(1)}%',
                                          dotColor: const Color(0xFF4BAE4F),
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 18),
                                        _buildMacroIndicatorRow(
                                          label: 'Protein',
                                          grams:
                                              '${protein.toStringAsFixed(1)}g',
                                          percent:
                                              '${proteinPercent.toStringAsFixed(1)}%',
                                          dotColor: const Color(0xFFEE8A3A),
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 18),
                                        _buildMacroIndicatorRow(
                                          label: 'Fat',
                                          grams: '${fat.toStringAsFixed(1)}g',
                                          percent:
                                              '${fatPercent.toStringAsFixed(1)}%',
                                          dotColor: const Color(0xFFF9C80E),
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // RECIPE INGREDIENTS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recipe Ingredients',
                            style: AppTypography.headingLg(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Scaled to ${(double.tryParse(_inputAmount) ?? 100.0).toStringAsFixed(1)} $_selectedUnit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E60D4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark
                                ? colors.outline
                                : const Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                        ),
                        color: isDark
                            ? colors.surfaceContainerLowest
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: _getIngredients().map((ingredient) {
                              final scaledVal = ingredient.baseAmount * servings;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1E60D4),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          ingredient.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.grey.shade300
                                                : const Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${scaledVal.toStringAsFixed(1)} ${ingredient.unit}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // NUTRIENT SECTION
                      Text(
                        'Nutrient',
                        style: AppTypography.headingLg(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark
                                ? colors.outline
                                : const Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                        ),
                        color: isDark
                            ? colors.surfaceContainerLowest
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              // CARBS
                              _buildNutrientHeaderRow(
                                'Carbs',
                                formatNutrient(carbs),
                                isDark,
                              ),
                              _buildSubNutrientRow(
                                'Sugar',
                                formatNutrient(_getSugar(servings)),
                                isDark,
                              ),
                              _buildSubNutrientRow(
                                'Dietary Fiber',
                                formatNutrient(_getDietaryFiber(servings)),
                                isDark,
                              ),

                              const SizedBox(height: 8),
                              // PROTEIN
                              _buildNutrientHeaderRow(
                                'Protein',
                                formatNutrient(protein),
                                isDark,
                              ),

                              const SizedBox(height: 8),
                              // FAT
                              _buildNutrientHeaderRow(
                                'Fat',
                                formatNutrient(fat),
                                isDark,
                              ),
                              _buildSubNutrientRow(
                                'Saturated Fat',
                                formatNutrient(_getSaturatedFat(servings)),
                                isDark,
                              ),
                              _buildSubNutrientRow(
                                'Monounsaturated Fat',
                                formatNutrient(
                                  _getMonounsaturatedFat(servings),
                                ),
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // PERSISTENT BOTTOM SHEET AREA
              GestureDetector(
                onTap:
                    () {}, // Prevent taps inside bottom sheet from closing the keyboard
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? colors.surface : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Little pull handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),

                      if (!_isKeyboardVisible) ...[
                        // DEFAULT STATE: Row of input buttons (Amount and Unit)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isKeyboardVisible = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colors.surfaceContainerLowest
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? colors.outline
                                            : const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          (double.tryParse(_inputAmount) ??
                                                  100.0)
                                              .toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isKeyboardVisible = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colors.surfaceContainerLowest
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? colors.outline
                                            : const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _selectedUnit,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // EXPANDED STATE: Full Blue Border Text Field + Unit tabs + Keyboard
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF1E60D4),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      textSelectionTheme: const TextSelectionThemeData(
                                        selectionColor: Colors.transparent,
                                        selectionHandleColor: Colors.transparent,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _amountController,
                                      readOnly: false,
                                      showCursor: true,
                                      autofocus: true,
                                      enableInteractiveSelection: true,
                                      keyboardType: TextInputType.none,
                                      cursorColor: const Color(0xFF1E60D4),
                                      cursorWidth: 2.5,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedUnit,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Numeric Grid Keyboard
                        Container(
                          color: isDark
                              ? colors.surfaceContainerLowest
                              : const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              _buildKeyboardRow(['1', '2', '3']),
                              const SizedBox(height: 8),
                              _buildKeyboardRow(['4', '5', '6']),
                              const SizedBox(height: 8),
                              _buildKeyboardRow(['7', '8', '9']),
                              const SizedBox(height: 8),
                              _buildKeyboardRow(['.', '0', 'backspace']),
                            ],
                          ),
                        ),
                      ],

                      // SAVE TO MEAL BUTTON
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF1E60D4,
                            ), // royal blue
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _logFood,
                          child: const Text(
                            'Save to meal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroIndicatorRow({
    required String label,
    required String grams,
    required String percent,
    required Color dotColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        // Colored dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          grams,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            percent,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientHeaderRow(String title, String value, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubNutrientRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 12, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 0.5,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _onKeyPress(key),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: key == 'backspace'
                      ? Icon(
                          Icons.backspace_outlined,
                          size: 18,
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF334155),
                        )
                      : Text(
                          key,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SegmentedDonutPainter extends CustomPainter {
  final double carbsFraction;
  final double proteinFraction;
  final double fatFraction;
  final Color carbsColor;
  final Color proteinColor;
  final Color fatColor;
  final Color backgroundColor;

  SegmentedDonutPainter({
    required this.carbsFraction,
    required this.proteinFraction,
    required this.fatFraction,
    required this.carbsColor,
    required this.proteinColor,
    required this.fatColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 10.0;
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final double total = carbsFraction + proteinFraction + fatFraction;
    if (total <= 0) return;

    final double carbsAngle = (carbsFraction / total) * 2 * pi;
    final double proteinAngle = (proteinFraction / total) * 2 * pi;
    final double fatAngle = (fatFraction / total) * 2 * pi;

    double startAngle = -pi / 2; // Start from top

    final Paint segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw Carbs
    if (carbsAngle > 0.01) {
      segmentPaint.color = carbsColor;
      canvas.drawArc(
        rect,
        startAngle + 0.06,
        carbsAngle - 0.12,
        false,
        segmentPaint,
      );
      startAngle += carbsAngle;
    }

    // Draw Protein
    if (proteinAngle > 0.01) {
      segmentPaint.color = proteinColor;
      canvas.drawArc(
        rect,
        startAngle + 0.06,
        proteinAngle - 0.12,
        false,
        segmentPaint,
      );
      startAngle += proteinAngle;
    }

    // Draw Fat
    if (fatAngle > 0.01) {
      segmentPaint.color = fatColor;
      canvas.drawArc(
        rect,
        startAngle + 0.06,
        fatAngle - 0.12,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedDonutPainter oldDelegate) {
    return oldDelegate.carbsFraction != carbsFraction ||
        oldDelegate.proteinFraction != proteinFraction ||
        oldDelegate.fatFraction != fatFraction ||
        oldDelegate.carbsColor != carbsColor ||
        oldDelegate.proteinColor != proteinColor ||
        oldDelegate.fatColor != fatColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

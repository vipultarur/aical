import 'package:flutter/material.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/common/models/meal_type.dart';

class ServingSizeSheet extends StatefulWidget {
  const ServingSizeSheet({
    super.key,
    required this.item,
    required this.selectedSlot,
    required this.isInitiallyStarred,
    required this.onStarChanged,
    required this.onSave,
  });

  final FoodSearchItem item;
  final MealType selectedSlot;
  final bool isInitiallyStarred;
  final ValueChanged<bool> onStarChanged;
  final void Function(double amount, String unit) onSave;

  @override
  State<ServingSizeSheet> createState() => _ServingSizeSheetState();
}

class _ServingSizeSheetState extends State<ServingSizeSheet> {
  String _inputAmount = '100';
  String _selectedUnit = 'g';
  late bool _isStarred;

  @override
  void initState() {
    super.initState();
    _isStarred = widget.isInitiallyStarred;
  }

  void _onKeyPress(String val) {
    setState(() {
      if (val == 'backspace') {
        if (_inputAmount.isNotEmpty) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        }
        if (_inputAmount.isEmpty) {
          _inputAmount = '0';
        }
      } else if (val == '.') {
        if (!_inputAmount.contains('.')) {
          _inputAmount = _inputAmount.isEmpty ? '0.' : '$_inputAmount.';
        }
      } else {
        if (_inputAmount == '0') {
          _inputAmount = val;
        } else {
          _inputAmount = '$_inputAmount$val';
        }
      }
    });
  }

  double _getProteinDouble() => widget.item.protein.toDouble();
  double _getCarbsDouble() => widget.item.carbs.toDouble();
  double _getFatDouble() => widget.item.fat.toDouble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double amountValue = double.tryParse(_inputAmount) ?? 100.0;

    // Dynamically calculate macros proportionally (default base is 100g)
    final int dynamicCalories = (widget.item.calories * amountValue / 100.0)
        .round();
    final double dynamicCarbs = (_getCarbsDouble() * amountValue / 100.0);
    final double dynamicProtein = (_getProteinDouble() * amountValue / 100.0);
    final double dynamicFat = (_getFatDouble() * amountValue / 100.0);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gray pull indicator
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title + Star Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isStarred ? Icons.star : Icons.star_border,
                    color: _isStarred ? Colors.amber : Colors.grey.shade400,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _isStarred = !_isStarred;
                    });
                    widget.onStarChanged(_isStarred);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // BADGES matching Image 2 perfectly
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildMacroBadge(
                  label: 'Calorie',
                  value: '${dynamicCalories}kcal',
                  bgColor: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 8),
                _buildMacroBadge(
                  label: 'Carbs',
                  value: '${dynamicCarbs.toStringAsFixed(1)}g',
                  bgColor: const Color(0xFFECFDF5),
                  textColor: const Color(0xFF065F46),
                ),
                const SizedBox(width: 8),
                _buildMacroBadge(
                  label: 'Protein',
                  value: '${dynamicProtein.toStringAsFixed(1)}g',
                  bgColor: const Color(0xFFFFF7ED),
                  textColor: const Color(0xFF9A3412),
                ),
                const SizedBox(width: 8),
                _buildMacroBadge(
                  label: 'Fat',
                  value: '${dynamicFat.toStringAsFixed(1)}g',
                  bgColor: const Color(0xFFFEFCE8),
                  textColor: const Color(0xFF854D0E),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Dynamic input display in a rounded blue border box
          Center(
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerLowest : Colors.white,
                border: Border.all(color: const Color(0xFF1E60D4), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _inputAmount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedUnit,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Unit Selectors: g, cup, piece, oz.
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['g', 'cup', 'piece', 'oz.'].map((unit) {
                final isSelected = _selectedUnit == unit;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUnit = unit;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          unit,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF1E60D4)
                                : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isSelected)
                          Container(
                            width: 12,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E60D4),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Custom Grid Keyboard
          Container(
            color: isDark
                ? colors.surfaceContainerLowest
                : const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          // Save to Meal Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60D4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                widget.onSave(amountValue, _selectedUnit);
                Navigator.pop(context);
              },
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
    );
  }

  Widget _buildMacroBadge({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
                  height: 52,
                  alignment: Alignment.center,
                  child: key == 'backspace'
                      ? Icon(
                          Icons.backspace_outlined,
                          size: 20,
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF334155),
                        )
                      : Text(
                          key,
                          style: TextStyle(
                            fontSize: 22,
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

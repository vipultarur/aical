import 'package:flutter/material.dart';

import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';

class QuickAddFoodSheet extends StatefulWidget {
  const QuickAddFoodSheet({super.key});

  @override
  State<QuickAddFoodSheet> createState() => _QuickAddFoodSheetState();
}

class _QuickAddFoodSheetState extends State<QuickAddFoodSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _calorieController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _calorieController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim().isEmpty
        ? 'Quick Added Food'
        : _nameController.text.trim();
    final calories = int.tryParse(_calorieController.text) ?? 200;

    final item = FoodSearchItem(
      name: name,
      brand: 'Quick Add',
      calories: calories,
      protein: ((calories * 0.2) / 4).round(),
      carbs: ((calories * 0.5) / 4).round(),
      fat: ((calories * 0.3) / 9).round(),
      fiber: 0,
      servingAmount: 1,
      servingUnit: 'Serving',
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 32,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quick Add Calories',
            style: AppTypography.headingLg(color: colors.onSurface),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Food Name / Description',
              hintText: 'e.g., Quick lunch',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _calorieController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories (kcal)',
              hintText: 'e.g., 450',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Add to Daily Log'),
          ),
        ],
      ),
    );
  }
}

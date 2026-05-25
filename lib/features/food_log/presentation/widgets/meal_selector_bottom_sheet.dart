import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/common/models/meal_type.dart';

class MealSelectorBottomSheet extends StatelessWidget {
  final MealType selectedSlot;
  final ValueChanged<MealType> onSlotSelected;

  const MealSelectorBottomSheet({
    super.key,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required MealType currentSlot,
    required ValueChanged<MealType> onSlotSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MealSelectorBottomSheet(
        selectedSlot: currentSlot,
        onSlotSelected: onSlotSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetColors = Theme.of(context).colorScheme;
    final sheetIsDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: sheetIsDark ? const Color(0xFF1E293B) : sheetColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull line
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: sheetColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Select a meal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: sheetColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: sheetColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: sheetColors.onSurfaceVariant,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Meal Options
            ...MealType.values.map((slot) {
              final isSelected = selectedSlot == slot;
              return GestureDetector(
                onTap: () {
                  onSlotSelected(slot);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: sheetColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? sheetColors.primary
                          : sheetColors.outlineVariant,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        slot == MealType.breakfast
                            ? LucideIcons.sunrise
                            : slot == MealType.lunch
                                ? LucideIcons.sun
                                : slot == MealType.dinner
                                    ? LucideIcons.moon
                                    : LucideIcons.apple,
                        color: isSelected
                            ? sheetColors.primary
                            : sheetColors.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        slot == MealType.snacks ? 'Snack' : slot.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: sheetColors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.radio_button_checked,
                          color: sheetColors.primary,
                        )
                      else
                        Icon(
                          Icons.radio_button_off,
                          color: sheetColors.outline,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

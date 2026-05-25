import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/features/food_log/presentation/widgets/food_detail_bottom_sheet.dart';

class AddedItemsDialog extends ConsumerStatefulWidget {
  final MealType selectedSlot;
  final List<FoodEntry> addedEntries;
  final void Function(int index) onRemove;
  final void Function(int index, FoodEntry newEntry) onUpdate;

  const AddedItemsDialog({
    super.key,
    required this.selectedSlot,
    required this.addedEntries,
    required this.onRemove,
    required this.onUpdate,
  });

  static Future<void> show({
    required BuildContext context,
    required MealType selectedSlot,
    required List<FoodEntry> addedEntries,
    required void Function(int index) onRemove,
    required void Function(int index, FoodEntry newEntry) onUpdate,
  }) {
    if (addedEntries.isEmpty) return Future.value();

    return showDialog(
      context: context,
      builder: (context) => AddedItemsDialog(
        selectedSlot: selectedSlot,
        addedEntries: addedEntries,
        onRemove: onRemove,
        onUpdate: onUpdate,
      ),
    );
  }

  @override
  ConsumerState<AddedItemsDialog> createState() => _AddedItemsDialogState();
}

class _AddedItemsDialogState extends ConsumerState<AddedItemsDialog> {
  late List<FoodEntry> _localEntries;

  @override
  void initState() {
    super.initState();
    _localEntries = List.from(widget.addedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final dialogScheme = Theme.of(context).colorScheme;
    
    return Dialog(
      backgroundColor: dialogScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.selectedSlot == MealType.breakfast
                          ? LucideIcons.sunrise
                          : widget.selectedSlot == MealType.lunch
                              ? LucideIcons.sun
                              : widget.selectedSlot == MealType.dinner
                                  ? LucideIcons.moon
                                  : LucideIcons.apple,
                      color: Colors.orange.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.selectedSlot == MealType.snacks
                          ? 'Snack'
                          : widget.selectedSlot.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dialogScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: dialogScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: dialogScheme.onSurfaceVariant,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _localEntries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = _localEntries[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: dialogScheme.surfaceContainerLowest,
                      border: Border.all(
                        color: dialogScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: dialogScheme.onSurface,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${entry.calories.toDouble()} kcal, ${entry.servingAmount} ${entry.servingUnit}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      onTap: () async {
                        final originalItem = FoodSearchItem(
                          name: entry.name,
                          brand: entry.brand,
                          calories: entry.calories,
                          protein: entry.protein,
                          carbs: entry.carbs,
                          fat: entry.fat,
                          fiber: entry.fiber,
                          servingAmount: entry.servingAmount,
                          servingUnit: entry.servingUnit,
                        );

                        final newEntry = await FoodDetailBottomSheet.show(
                          context,
                          originalItem,
                          widget.selectedSlot,
                        );
                        if (newEntry != null) {
                          setState(() {
                            _localEntries[index] = newEntry;
                          });
                          widget.onUpdate(index, newEntry);
                        }
                      },
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: dialogScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            LucideIcons.trash,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _localEntries.removeAt(index);
                            });
                            widget.onRemove(index);
                            if (_localEntries.isEmpty) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

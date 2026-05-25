import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_assets.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';

/// Displays a dashboard meal slot and its logged entries.
class DashboardMealSlotCard extends ConsumerWidget {
  const DashboardMealSlotCard({
    required this.colors,
    required this.isDark,
    required this.type,
    required this.title,
    required this.target,
    required this.entries,
    required this.iconBgColor,
    super.key,
  });

  final ColorScheme colors;
  final bool isDark;
  final MealType type;
  final String title;
  final int target;
  final List<FoodEntry> entries;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedCalories = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.calories,
    );

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.md),
      padding: AppDimensions.all(12),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: AppDimensions.circular(18),
        border: Border.all(
          color: isDark ? colors.outline : Colors.grey.shade200,
          width: AppDimensions.width(1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: AppDimensions.width(8),
            offset: Offset(0, AppDimensions.height(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.size(38),
                height: AppDimensions.size(38),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: AppDimensions.circular(19),
                  child: Image.asset(
                    _mealAssetFor(type),
                    fit: BoxFit.cover,
                    width: AppDimensions.size(38),
                    height: AppDimensions.size(38),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        type.icon,
                        color: const Color(0xFF1976D2),
                        size: AppDimensions.iconMd,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingSm(
                        color: isDark ? Colors.white : const Color(0xFF111111),
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: AppDimensions.height(2)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$loggedCalories',
                              style: AppTypography.bodySm(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111111),
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' / $target kcal',
                              style: AppTypography.labelSm(
                                color: Colors.grey.shade400,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.sm),
              GestureDetector(
                onTap: () => context.push(AppRoutes.log(slot: type.name)),
                child: Container(
                  width: AppDimensions.size(34),
                  height: AppDimensions.size(34),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.plus,
                    color: const Color(0xFF1976D2),
                    size: AppDimensions.icon(18),
                  ),
                ),
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            Divider(height: AppDimensions.height(20), thickness: 0.8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            final searchItem = FoodSearchItem(
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
                            context.push(
                              AppRoutes.foodDetail(entry.id, slot: type.name),
                              extra: searchItem,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodySm(
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF111111),
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (entry.brand.isNotEmpty)
                                        Text(
                                          '${entry.brand} - ${entry.servingAmount.round()} ${entry.servingUnit}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.labelSm(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppDimensions.sm),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${entry.calories} kcal',
                                    style: AppTypography.labelMd(
                                      color: const Color(0xFF1976D2),
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.xs),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          LucideIcons.trash2,
                          color: AppColors.coralAlert,
                          size: AppDimensions.icon(15),
                        ),
                        onPressed: () => ref
                            .read(foodLogProvider.notifier)
                            .removeFood(entry.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _mealAssetFor(MealType mealType) {
    return switch (mealType) {
      MealType.breakfast => AppAssets.breakfast,
      MealType.lunch => AppAssets.lunch,
      MealType.dinner => AppAssets.dinner,
      MealType.snacks => AppAssets.snack,
    };
  }
}

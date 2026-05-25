import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/providers/food_log_provider.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_durations.dart';

/// Displays the dashboard week ribbon selector.
class DashboardDayRibbon extends ConsumerWidget {
  const DashboardDayRibbon({
    required this.colors,
    required this.isDark,
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  final ColorScheme colors;
  final bool isDark;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodLogs = ref.watch(foodLogProvider);

    final now = DateTime.now();
    final baseDate = DateTime(now.year, now.month, now.day);
    
    final weekDates = List.generate(
      7,
      (index) => baseDate.add(Duration(days: 1 - index)),
    );

    bool hasCompletedTask(DateTime d) {
      return foodLogs.any((log) =>
          log.loggedAt.year == d.year &&
          log.loggedAt.month == d.month &&
          log.loggedAt.day == d.day);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.tablet;

        if (isCompact) {
          return SizedBox(
            height: AppDimensions.height(88),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              separatorBuilder: (_, _) => SizedBox(width: AppDimensions.sm),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: AppDimensions.width(52),
                  child: _DashboardDayChip(
                    colors: colors,
                    isDark: isDark,
                    date: weekDates[index],
                    selectedDate: selectedDate,
                    weekdayStr: _weekdayLetters[weekDates[index].weekday % 7],
                    hasCompletedTask: hasCompletedTask(weekDates[index]),
                    onTap: () => onDateSelected(weekDates[index]),
                  ),
                );
              },
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(weekDates.length, (index) {
            return Expanded(
              child: _DashboardDayChip(
                colors: colors,
                isDark: isDark,
                date: weekDates[index],
                selectedDate: selectedDate,
                weekdayStr: _weekdayLetters[weekDates[index].weekday % 7],
                hasCompletedTask: hasCompletedTask(weekDates[index]),
                horizontalMargin: AppDimensions.width(4),
                onTap: () => onDateSelected(weekDates[index]),
              ),
            );
          }),
        );
      },
    );
  }
}

class _DashboardDayChip extends StatelessWidget {
  const _DashboardDayChip({
    required this.colors,
    required this.isDark,
    required this.date,
    required this.selectedDate,
    required this.weekdayStr,
    required this.hasCompletedTask,
    required this.onTap,
    this.horizontalMargin = 0,
  });

  final ColorScheme colors;
  final bool isDark;
  final DateTime date;
  final DateTime selectedDate;
  final String weekdayStr;
  final bool hasCompletedTask;
  final VoidCallback onTap;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final isSelected =
        date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;

    final today = DateTime.now();
    final isToday =
        date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: AppDurations.fast,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            padding: AppDimensions.symmetric(vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1976D2)
                  : (isDark ? colors.surface : Colors.white),
              borderRadius: AppDimensions.circular(18),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1976D2)
                    : (isToday
                          ? const Color(0xFF1976D2)
                          : (isDark ? colors.outline : Colors.grey.shade200)),
                width: isToday && !isSelected ? 1.8 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                        blurRadius: AppDimensions.width(8),
                        offset: Offset(0, AppDimensions.height(3)),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdayStr,
                  style: TextStyle(
                    fontSize: AppDimensions.font(11),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: AppDimensions.height(6)),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: AppDimensions.font(15),
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF111111)),
                  ),
                ),
              ],
            ),
          ),
          if (hasCompletedTask)
            Positioned(
              top: AppDimensions.height(2),
              right: AppDimensions.width(6),
              child: Container(
                width: AppDimensions.size(6),
                height: AppDimensions.size(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB300),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const List<String> _weekdayLetters = <String>[
  'S',
  'M',
  'T',
  'W',
  'T',
  'F',
  'S',
];

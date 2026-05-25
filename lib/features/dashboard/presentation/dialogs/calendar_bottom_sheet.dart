import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/common/providers/food_log_provider.dart';
import 'package:calcount/common/providers/user_profile_provider.dart';
import 'package:calcount/core/theme/app_theme.dart';

/// Shows the dashboard calendar picker bottom sheet.
class DashboardCalendarBottomSheet extends ConsumerStatefulWidget {
  const DashboardCalendarBottomSheet({
    super.key,
    required this.initialSelectedDate,
    required this.onDateSelected,
  });

  final DateTime initialSelectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  ConsumerState<DashboardCalendarBottomSheet> createState() =>
      _DashboardCalendarBottomSheetState();
}

class _DashboardCalendarBottomSheetState
    extends ConsumerState<DashboardCalendarBottomSheet> {
  late int _displayMonth;
  late int _displayYear;
  late DateTime _tempSelectedDate;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.initialSelectedDate;
    _displayMonth = widget.initialSelectedDate.month;
    _displayYear = widget.initialSelectedDate.year;
  }

  void _showPreviousMonth() {
    setState(() {
      if (_displayMonth == 1) {
        _displayMonth = 12;
        _displayYear--;
        return;
      }

      _displayMonth--;
    });
  }

  void _showNextMonth() {
    setState(() {
      if (_displayMonth == 12) {
        _displayMonth = 1;
        _displayYear++;
        return;
      }

      _displayMonth++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    final foodLogs = ref.watch(foodLogProvider);
    final targetCalories = ref.watch(userProfileProvider).calorieTarget;

    final firstDayOfMonth = DateTime(_displayYear, _displayMonth, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(_displayYear, _displayMonth + 1, 0).day;
    final totalCells = startingWeekday + daysInMonth;
    final displayMonthStr = _monthNames[_displayMonth - 1];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  final today = DateTime.now();
                  widget.onDateSelected(today);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.outline.withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.chevronLeft,
                  color: Color(0xFF1976D2),
                  size: 28,
                ),
                onPressed: _showPreviousMonth,
              ),
              const SizedBox(width: 12),
              Text(
                '$displayMonthStr $_displayYear',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F2042),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  LucideIcons.chevronRight,
                  color: Color(0xFF1976D2),
                  size: 28,
                ),
                onPressed: _showNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dayLabels.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox();
              }

              final dayNum = index - startingWeekday + 1;
              final cellDate = DateTime(_displayYear, _displayMonth, dayNum);
              final today = DateTime.now();
              final isToday =
                  cellDate.day == today.day &&
                  cellDate.month == today.month &&
                  cellDate.year == today.year;
              final isSelected =
                  cellDate.day == _tempSelectedDate.day &&
                  cellDate.month == _tempSelectedDate.month &&
                  cellDate.year == _tempSelectedDate.year;

              // Calculate progress for cellDate
              double consumed = 0;
              for (final log in foodLogs) {
                if (log.loggedAt.year == cellDate.year &&
                    log.loggedAt.month == cellDate.month &&
                    log.loggedAt.day == cellDate.day) {
                  consumed += log.calories;
                }
              }

              double progress = 0.0;
              bool isOverGoal = false;
              if (targetCalories > 0) {
                progress = consumed / targetCalories;
                if (consumed > targetCalories) {
                  isOverGoal = true;
                  progress = 1.0;
                } else if (progress > 1.0) {
                  progress = 1.0;
                }
              } else if (consumed > 0) {
                progress = 1.0;
                isOverGoal = true;
              }

              return GestureDetector(
                onTap: () {
                  widget.onDateSelected(cellDate);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1976D2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isToday
                        ? Border.all(
                            color: isSelected ? Colors.white : const Color(0xFF1976D2),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF111111)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _DayCellIndicator(
                        isSelected: isSelected,
                        isToday: isToday,
                        isDark: isDark,
                        progress: progress,
                        isOverGoal: isOverGoal,
                      ),
                      if (isOverGoal) ...[
                        const SizedBox(height: 2),
                        Text(
                          '+${(consumed - targetCalories).toInt()}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF87171),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DayCellIndicator extends StatelessWidget {
  const _DayCellIndicator({
    required this.isSelected,
    required this.isToday,
    required this.isDark,
    required this.progress,
    required this.isOverGoal,
  });

  final bool isSelected;
  final bool isToday;
  final bool isDark;
  final double progress;
  final bool isOverGoal;

  @override
  Widget build(BuildContext context) {
    Color trackColor;
    Color ringColor;

    if (isSelected) {
      trackColor = Colors.white.withValues(alpha: 0.3);
      if (isOverGoal) {
        ringColor = const Color(0xFFF87171); // Soft Red
      } else {
        ringColor = Colors.white;
      }
    } else {
      trackColor = isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0);
      if (isOverGoal) {
        ringColor = const Color(0xFFF87171); // Soft Red
      } else {
        ringColor = const Color(0xFF1976D2); // Blue
      }
    }

    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(trackColor),
            strokeCap: StrokeCap.round,
          ),
          // Main progress ring
          if (progress > 0)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
        ],
      ),
    );
  }
}

const List<String> _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _dayLabels = <String>[
  'SUN',
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
];

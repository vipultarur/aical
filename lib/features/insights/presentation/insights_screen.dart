import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/features/dashboard/presentation/widgets/dashboard_day_ribbon.dart';
import 'package:calcount/features/dashboard/presentation/dialogs/calendar_bottom_sheet.dart';
import 'package:calcount/common/providers/food_log_provider.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/core/constants/app_assets.dart';

class CalorieTask {
  final String id;
  final String title; // "Breakfast", "Lunch", "Dinner", or "Snack"
  final String description; // Actual food logged/planned
  final String timeRange; // e.g. "08.00 - 08.30"
  final String amPm; // "AM" or "PM"
  final IconData icon;
  final Color iconBgColor;
  final bool isCompulsory; // true for Breakfast, Lunch, Dinner
  final bool isChecked;
  final int itemCount;
  final List<FoodEntry> entries;

  CalorieTask({
    required this.id,
    required this.title,
    required this.description,
    required this.timeRange,
    required this.amPm,
    required this.icon,
    required this.iconBgColor,
    required this.isCompulsory,
    required this.isChecked,
    required this.itemCount,
    this.entries = const [],
  });
}

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  DateTime _selectedDate =
      DateTime.now(); // Default to today's date dynamically

  void _toggleTask(CalorieTask task) {
    // 1. Get corresponding MealType
    final MealType type = switch (task.title.toLowerCase()) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => MealType.snacks,
    };

    // Always trigger GoRouter route to add food screen for this meal slot!
    context.push(AppRoutes.log(slot: type.name));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= AppBreakpoints.tablet; // 600

    // Check if the selected date is today to toggle interactivity
    final today = DateTime.now();
    final isToday =
        _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    // Read logged foods from global state notifier
    final foodEntries = ref.watch(foodLogProvider);

    // Filter food logs for the selected date
    final currentDayEntries = foodEntries.where((entry) {
      final date = entry.loggedAt;
      return date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
    }).toList();

    // Group entries by type
    final breakfastEntries = currentDayEntries
        .where((e) => e.mealType == MealType.breakfast)
        .toList();
    final lunchEntries = currentDayEntries
        .where((e) => e.mealType == MealType.lunch)
        .toList();
    final dinnerEntries = currentDayEntries
        .where((e) => e.mealType == MealType.dinner)
        .toList();
    final snackEntries = currentDayEntries
        .where((e) => e.mealType == MealType.snacks)
        .toList();

    final List<CalorieTask> displayTasks = [];

    // 1. Breakfast (Compulsory)
    if (breakfastEntries.isNotEmpty) {
      final first = breakfastEntries.first;
      final hour = first.loggedAt.hour;
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final min = first.loggedAt.minute.toString().padLeft(2, '0');
      final timeStr = '${hour12.toString().padLeft(2, '0')}.$min';
      final amPm = hour >= 12 ? 'PM' : 'AM';

      displayTasks.add(
        CalorieTask(
          id: 'breakfast_logged',
          title: 'Breakfast',
          description: breakfastEntries.map((e) => e.name).join(', '),
          timeRange: '$timeStr - $timeStr',
          amPm: amPm,
          icon: LucideIcons.chefHat,
          iconBgColor: AppColors.blueInfo,
          isCompulsory: true,
          isChecked: true,
          itemCount: breakfastEntries.length,
          entries: breakfastEntries,
        ),
      );
    } else {
      displayTasks.add(
        CalorieTask(
          id: 'breakfast_missing',
          title: 'Breakfast',
          description: 'No breakfast logged yet',
          timeRange: '08.00 - 08.30',
          amPm: 'AM',
          icon: LucideIcons.chefHat,
          iconBgColor: AppColors.blueInfo,
          isCompulsory: true,
          isChecked: false,
          itemCount: 0,
        ),
      );
    }

    // 2. Lunch (Compulsory)
    if (lunchEntries.isNotEmpty) {
      final first = lunchEntries.first;
      final hour = first.loggedAt.hour;
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final min = first.loggedAt.minute.toString().padLeft(2, '0');
      final timeStr = '${hour12.toString().padLeft(2, '0')}.$min';
      final amPm = hour >= 12 ? 'PM' : 'AM';

      displayTasks.add(
        CalorieTask(
          id: 'lunch_logged',
          title: 'Lunch',
          description: lunchEntries.map((e) => e.name).join(', '),
          timeRange: '$timeStr - $timeStr',
          amPm: amPm,
          icon: LucideIcons.chefHat,
          iconBgColor: AppColors.blueInfo,
          isCompulsory: true,
          isChecked: true,
          itemCount: lunchEntries.length,
          entries: lunchEntries,
        ),
      );
    } else {
      displayTasks.add(
        CalorieTask(
          id: 'lunch_missing',
          title: 'Lunch',
          description: 'No lunch logged yet',
          timeRange: '01.00 - 01.45',
          amPm: 'PM',
          icon: LucideIcons.chefHat,
          iconBgColor: AppColors.blueInfo,
          isCompulsory: true,
          isChecked: false,
          itemCount: 0,
        ),
      );
    }

    // 3. Snacks (Flexible - only shown in timeline if added!)
    for (int i = 0; i < snackEntries.length; i++) {
      final snack = snackEntries[i];
      final hour = snack.loggedAt.hour;
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final min = snack.loggedAt.minute.toString().padLeft(2, '0');
      final timeStr = '${hour12.toString().padLeft(2, '0')}.$min';
      final amPm = hour >= 12 ? 'PM' : 'AM';

      displayTasks.add(
        CalorieTask(
          id: 'snack_${snack.id}',
          title: 'Snack',
          description: snack.name,
          timeRange: '$timeStr - $timeStr',
          amPm: amPm,
          icon: LucideIcons.apple,
          iconBgColor: AppColors.greenFresh,
          isCompulsory: false,
          isChecked: true,
          itemCount: 1,
          entries: [snack],
        ),
      );
    }

    // 4. Dinner (Compulsory)
    if (dinnerEntries.isNotEmpty) {
      final first = dinnerEntries.first;
      final hour = first.loggedAt.hour;
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final min = first.loggedAt.minute.toString().padLeft(2, '0');
      final timeStr = '${hour12.toString().padLeft(2, '0')}.$min';
      final amPm = hour >= 12 ? 'PM' : 'AM';

      displayTasks.add(
        CalorieTask(
          id: 'dinner_logged',
          title: 'Dinner',
          description: dinnerEntries.map((e) => e.name).join(', '),
          timeRange: '$timeStr - $timeStr',
          amPm: amPm,
          icon: LucideIcons.chefHat,
          iconBgColor: AppColors.blueInfo,
          isCompulsory: true,
          isChecked: true,
          itemCount: dinnerEntries.length,
          entries: dinnerEntries,
        ),
      );
    } else {
      displayTasks.add(
        CalorieTask(
          id: 'dinner_missing',
          title: 'Dinner',
          description: 'No dinner logged yet',
          timeRange: '08.00 - 08.30',
          amPm: 'PM',
          icon: LucideIcons.chefHat,
          iconBgColor: AppColors.blueInfo,
          isCompulsory: true,
          isChecked: false,
          itemCount: 0,
        ),
      );
    }

    // Chronologically sort all planned/logged meals by start times
    displayTasks.sort((a, b) {
      return a.timeRange.compareTo(b.timeRange);
    });

    Widget bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Week Days" Label
        Padding(
          padding: AppDimensions.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Week Days',
            style: TextStyle(
              fontSize: AppDimensions.font(15),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8), // slate-400
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Horizontal Week Selector (Reuses Dashboard week day ribbon calendar)
        Padding(
          padding: AppDimensions.symmetric(horizontal: 16.0),
          child: DashboardDayRibbon(
            colors: colors,
            isDark: isDark,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
        SizedBox(height: AppDimensions.height(20)),

        // Timeline Schedule Title (Add Snack button removed!)
        Padding(
          padding: AppDimensions.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            'Meal Schedule',
            style: TextStyle(
              fontSize: AppDimensions.font(18),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A), // slate-900
            ),
          ),
        ),
        SizedBox(height: AppDimensions.height(12)),

        // Timeline Card Container
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLowest
                  : const Color(0xFFF8FAFC),
              borderRadius: isWide
                  ? AppDimensions.circular(36)
                  : BorderRadius.only(
                      topLeft: AppDimensions.radiusOnly(36),
                      topRight: AppDimensions.radiusOnly(36),
                    ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: AppDimensions.radius(20),
                  offset: Offset(0, -AppDimensions.height(4)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: isWide
                  ? AppDimensions.circular(36)
                  : BorderRadius.only(
                      topLeft: AppDimensions.radiusOnly(36),
                      topRight: AppDimensions.radiusOnly(36),
                    ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppDimensions.only(
                  left: 24,
                  top: 32,
                  right: 24,
                  bottom: 100,
                ),
                child: Column(
                  children: [
                    ...displayTasks.map((task) {
                      // Extract display hour & am/pm dynamically
                      final parts = task.timeRange.split(' - ');
                      final startPart = parts[0];

                      // Convert 24-hour hour string to 12-hour format
                      String displayTime = startPart.replaceAll('.', ':');
                      try {
                        final timeParts = startPart.split('.');
                        int hour = int.parse(timeParts[0]);
                        final minute = timeParts[1];
                        int displayHour = hour % 12;
                        if (displayHour == 0) displayHour = 12;
                        displayTime =
                            '${displayHour.toString().padLeft(2, '0')}:$minute';
                      } catch (_) {}

                      return _buildTimelineSlot(
                        time: displayTime,
                        amPm: task.amPm,
                        task: task,
                        onTaskToggle: _toggleTask,
                        isToday: isToday,
                      );
                    }),
                    if (displayTasks.isEmpty)
                      Padding(
                        padding: AppDimensions.symmetric(vertical: 80.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: AppDimensions.size(64),
                              height: AppDimensions.size(64),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colors.surface
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.calendarX2,
                                size: AppDimensions.icon(32),
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            SizedBox(height: AppDimensions.height(16)),
                            Text(
                              'No meals planned for this day',
                              style: TextStyle(
                                fontSize: AppDimensions.font(16),
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? colors.surface : Colors.white,
      appBar: AppBar(
        title: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: AppDimensions.width(800)),
            padding: AppDimensions.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'History',
                  style: AppTypography.headingXl(color: colors.onSurface)
                      .copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: AppDimensions.font(28),
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: AppDimensions.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? colors.surfaceContainerHighest
                    : const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                icon: Icon(
                  LucideIcons.calendar,
                  color: Colors.black,
                  size: AppDimensions.icon(20),
                ),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (dialogContext) {
                      return DashboardCalendarBottomSheet(
                        initialSelectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: AppDimensions.width(800)),
            padding: isWide ? AppDimensions.all(16.0) : EdgeInsets.zero,
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  void _showAddedItemsDialog(CalorieTask task, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Consumer(
            builder: (context, ref, _) {
              // Re-fetch entries dynamically for this specific date and meal type
              final allEntries = ref.watch(foodLogProvider);
              final currentDayEntries = allEntries.where((entry) {
                final date = entry.loggedAt;
                return date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
              }).toList();

              final MealType mealType = switch (task.title.toLowerCase()) {
                'breakfast' => MealType.breakfast,
                'lunch' => MealType.lunch,
                'dinner' => MealType.dinner,
                _ => MealType.snacks,
              };

              final currentEntries = currentDayEntries
                  .where((e) => e.mealType == mealType)
                  .toList();

              return Padding(
                padding: AppDimensions.all(20),
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
                              mealType == MealType.breakfast
                                  ? LucideIcons.sunrise
                                  : mealType == MealType.lunch
                                  ? LucideIcons.sun
                                  : mealType == MealType.dinner
                                  ? LucideIcons.moon
                                  : LucideIcons.apple,
                              color: Colors.orange.shade400,
                              size: AppDimensions.icon(20),
                            ),
                            SizedBox(width: AppDimensions.width(8)),
                            Text(
                              mealType == MealType.snacks
                                  ? 'Snack'
                                  : mealType.displayName,
                              style: TextStyle(
                                fontSize: AppDimensions.font(18),
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            padding: AppDimensions.all(4),
                            child: Icon(
                              Icons.close,
                              size: AppDimensions.icon(16),
                              color: Colors.grey,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.height(16)),
                    // List
                    if (currentEntries.isEmpty)
                      Padding(
                        padding: AppDimensions.all(20),
                        child: Text(
                          "No items logged.",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: currentEntries.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppDimensions.height(12)),
                          itemBuilder: (context, index) {
                            final entry = currentEntries[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: AppDimensions.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: AppDimensions.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  entry.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: AppDimensions.only(top: 4),
                                  child: Text(
                                    '${entry.calories.toDouble()} kcal, ${entry.servingAmount} ${entry.servingUnit}',
                                    style: TextStyle(
                                      fontSize: AppDimensions.font(13),
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
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
                                  Navigator.pop(context);
                                  context.push(
                                    AppRoutes.foodDetail(
                                      entry.id,
                                      slot: mealType.name,
                                    ),
                                    extra: searchItem,
                                  );
                                },
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      LucideIcons.trash,
                                      size: AppDimensions.icon(16),
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(foodLogProvider.notifier)
                                          .removeFood(entry.id);
                                      if (currentEntries.length <= 1) {
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTimelineSlot({
    required String time,
    required String amPm,
    required CalorieTask task,
    required Function(CalorieTask task) onTaskToggle,
    required bool isToday,
  }) {
    // Determine Bullet Color: Red if it's Breakfast, Lunch, Dinner and NOT checked.
    final bool showRedBullet = task.isCompulsory && !task.isChecked;
    final Color bulletColor = showRedBullet
        ? const Color(0xFFEF4444)
        : const Color(0xFF5850EC);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Column (Proper aligned & bold typography)
          SizedBox(
            width: AppDimensions.width(58),
            child: Padding(
              padding: AppDimensions.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: AppDimensions.font(17),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A), // slate-900
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    amPm,
                    style: TextStyle(
                      fontSize: AppDimensions.font(11),
                      color: const Color(0xFF94A3B8), // slate-400
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppDimensions.width(16)),
          // Timeline Axis (Glowing halo bullet + slate line)
          Column(
            children: [
              // Outer Halo bullet point (dynamically turns RED or PURPLE)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: AppDimensions.size(14),
                height: AppDimensions.size(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: bulletColor,
                    width: AppDimensions.width(3.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bulletColor.withValues(alpha: 0.25),
                      blurRadius: AppDimensions.radius(6),
                      spreadRadius: AppDimensions.radius(2),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: AppDimensions.width(2.2),
                  color: const Color(0xFFE2E8F0), // slate-200 line
                ),
              ),
            ],
          ),
          SizedBox(width: AppDimensions.width(16)),
          // Task Card
          Expanded(
            child: Padding(
              padding: AppDimensions.only(bottom: 20.0),
              child: _buildTaskCard(task, onTaskToggle, isToday),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    CalorieTask task,
    Function(CalorieTask) onTaskToggle,
    bool isToday,
  ) {
    final MealType mealType = switch (task.title.toLowerCase()) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => MealType.snacks,
    };

    String mealAssetFor(MealType type) {
      return switch (type) {
        MealType.breakfast => AppAssets.breakfast,
        MealType.lunch => AppAssets.lunch,
        MealType.dinner => AppAssets.dinner,
        MealType.snacks => AppAssets.snack,
      };
    }

    return GestureDetector(
      onTap: isToday ? () => onTaskToggle(task) : null,
      child: Container(
        padding: AppDimensions.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimensions.circular(
            48,
          ), // Pill shape matching UI screenshot!
          border: Border.all(
            color: const Color(0xFFF1F5F9), // slate-100
            width: AppDimensions.width(1.2),
          ),
        ),
        child: Row(
          children: [
            // Icon with perfect solid circular backing and top-right item count badge!
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: AppDimensions.size(50),
                    height: AppDimensions.size(50),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.iconBgColor, // Solid deep color!
                    ),
                    child: ClipRRect(
                      borderRadius: AppDimensions.circular(25),
                      child: Image.asset(
                        mealAssetFor(mealType),
                        fit: BoxFit.cover,
                        width: AppDimensions.size(50),
                        height: AppDimensions.size(50),
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            task.icon,
                            color: Colors.white,
                            size: AppDimensions.icon(24),
                          );
                        },
                      ),
                    ),
                  ),
                if (task.itemCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: AppDimensions.all(4),
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFFEF4444,
                        ), // Vibrant red notification badge!
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: AppDimensions.width(18),
                        minHeight: AppDimensions.height(18),
                      ),
                      child: Center(
                        child: Text(
                          '${task.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppDimensions.font(9.5),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: AppDimensions.width(16)),
            // Task Title, Description & Clock Duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: AppDimensions.font(16),
                      fontWeight: FontWeight.w800,
                      color: task.isChecked
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration: task.isChecked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  SizedBox(height: AppDimensions.height(4)),
                  if (task.entries.isNotEmpty)
                    Padding(
                      padding: AppDimensions.only(bottom: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          _showAddedItemsDialog(task, isDark);
                        },
                        child: Container(
                          padding: AppDimensions.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: AppDimensions.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: AppDimensions.width(1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View ${task.entries.length} ${task.entries.length == 1 ? 'item' : 'items'}',
                                style: TextStyle(
                                  fontSize: AppDimensions.font(10),
                                  color: const Color(
                                    0xFF1E60D4,
                                  ), // royal blue text
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: AppDimensions.width(2)),
                              Icon(
                                LucideIcons.chevronRight,
                                size: AppDimensions.icon(10),
                                color: const Color(
                                  0xFF1E60D4,
                                ), // royal blue icon
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Custom Right Button (Always a Plus button to add food)
            GestureDetector(
              onTap: isToday ? () => onTaskToggle(task) : null,
              child: _buildRightButton(task, const Color(0xFF5850EC), isToday),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightButton(CalorieTask task, Color activeColor, bool isToday) {
    // Always show Circular Plus button to add meals
    return Container(
      width: AppDimensions.size(32),
      height: AppDimensions.size(32),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.plus,
        color: isToday ? const Color(0xFF1976D2) : Colors.grey.shade400,
        size: AppDimensions.icon(18),
      ),
    );
  }
}

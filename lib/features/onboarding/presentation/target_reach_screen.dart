import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class TargetReachScreen extends ConsumerStatefulWidget {
  const TargetReachScreen({super.key});

  @override
  ConsumerState<TargetReachScreen> createState() => _TargetReachScreenState();
}

class _TargetReachScreenState extends ConsumerState<TargetReachScreen> {
  late DateTime _selectedDate;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  int _selectedYearIndex = 0;
  int _selectedMonthIndex = 0;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default selected date is 12 weeks (84 days) from now
    _selectedDate = DateTime.now().add(const Duration(days: 84));

    final currentYear = DateTime.now().year;
    _selectedYearIndex = _selectedDate.year - currentYear;
    _selectedMonthIndex = _selectedDate.month - 1;
    _selectedDayIndex = _selectedDate.day - 1;

    _yearController = FixedExtentScrollController(
      initialItem: _selectedYearIndex,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonthIndex,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDayIndex,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateSelectedDate({int? year, int? month, int? day}) {
    final y = year ?? _selectedDate.year;
    final m = month ?? _selectedDate.month;
    final d = day ?? _selectedDate.day;

    // Clamp day to max days in month
    final maxDays = _daysInMonth(y, m);
    final finalD = d > maxDays ? maxDays : d;

    setState(() {
      _selectedDate = DateTime(y, m, finalD);
    });
  }

  void _onNext() {
    final profile = ref.read(userProfileProvider);

    final today = DateTime.now();
    final difference = _selectedDate.difference(
      DateTime(today.year, today.month, today.day),
    );
    final double daysDiff = difference.inDays.toDouble();
    final double weeks = daysDiff > 7 ? (daysDiff / 7.0) : 1.0;

    // --- Mifflin-St Jeor BMR Formula ---
    final double weightKg = profile.weight;
    final double heightCm = profile.height;
    final int age = today.year - profile.dateOfBirth.year;

    double bmr;
    if (profile.gender == 'Female') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    }

    // --- TDEE Activity Multipliers ---
    final double activityMultiplier = switch (profile.activityLevel) {
      'No Active' => 1.2,
      'Lightly Active' => 1.375,
      'Moderately Active' => 1.55,
      'Highly Active' => 1.725,
      _ => 1.375,
    };

    final double tdee = bmr * activityMultiplier;

    // --- Calorie Target based on Goal ---
    final weightDiff = (profile.weight - profile.targetWeight).abs();
    final double weeklyRateKg = weeks > 0 ? weightDiff / weeks : 0;

    // Safe deficit: max 750 kcal/day deficit (about 0.5-1kg/week)
    double dailyDeficit = weeklyRateKg * 1000; // 1kg fat ≈ 7000 kcal → 1000/week
    if (dailyDeficit > 750) dailyDeficit = 750;
    if (dailyDeficit < 0) dailyDeficit = 0;

    double finalCalorieTarget;
    if (profile.mainGoal == 'Lose Weight') {
      finalCalorieTarget = tdee - dailyDeficit;
    } else if (profile.mainGoal == 'Gain Muscle') {
      finalCalorieTarget = tdee + 300; // lean bulk surplus
    } else {
      // Maintain Weight or Improve Health
      finalCalorieTarget = tdee;
    }

    // Clamp to safe boundaries (never below 1200 for women, 1500 for men)
    final double minCalories = profile.gender == 'Female' ? 1200.0 : 1500.0;
    if (finalCalorieTarget < minCalories) finalCalorieTarget = minCalories;
    if (finalCalorieTarget > 4000) finalCalorieTarget = 4000;

    final int totalCals = finalCalorieTarget.round();

    // --- Macro Split: 30% Protein, 45% Carbs, 25% Fat ---
    final int pGrams = ((totalCals * 0.30) / 4).round();
    final int cGrams = ((totalCals * 0.45) / 4).round();
    final int fGrams = ((totalCals * 0.25) / 9).round();

    // --- Water Target: 35ml per kg body weight (clamped 2000–3500ml) ---
    int waterTarget = (weightKg * 35).round();
    if (waterTarget < 2000) waterTarget = 2000;
    if (waterTarget > 3500) waterTarget = 3500;

    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          profile.copyWith(
            calorieTarget: totalCals,
            proteinTarget: pGrams,
            carbsTarget: cGrams,
            fatTarget: fGrams,
            waterTarget: waterTarget,
            targetDate: _selectedDate,
          ),
        );

    context.go(AppRoutes.onboardingPrediction);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = ref.watch(userProfileProvider);

    final currentWeight = profile.weight;
    final targetWeight = profile.targetWeight;
    final weightDiff = (currentWeight - targetWeight).abs();

    final today = DateTime.now();
    final difference = _selectedDate.difference(
      DateTime(today.year, today.month, today.day),
    );
    final double daysDiff = difference.inDays.toDouble();
    final double weeks = daysDiff > 7 ? (daysDiff / 7.0) : 1.0;

    final double rateKg = weightDiff / weeks;
    final double rateLbs = rateKg * 2.20462;

    final bool isMaintenance =
        profile.mainGoal == 'Maintain Weight' ||
        profile.mainGoal == 'Improve Health' ||
        weightDiff < 0.5;
    final bool isGaining = targetWeight > currentWeight;

    // Determine target pace tier and display color (Warm Yellow/Gold for Moderate Goal per Mockup)
    String paceTitle = "Moderate goal";
    Color paceColor = const Color(
      0xFFE2A925,
    ); // Sleek gold/yellow color matching mockup perfectly

    if (isMaintenance) {
      paceTitle = "Maintain weight";
      paceColor = colors.primary;
    } else if (rateKg < 0.35) {
      paceTitle = "Comfortable goal";
      paceColor = colors.primary;
    } else if (rateKg >= 0.75) {
      paceTitle = "Intense goal";
      paceColor = colors.error;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingGoals),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (index) {
            final isCurrent = index == 3;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCurrent ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCurrent
                    ? colors.primary
                    : colors.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'When do you want to reach the goal?',
                style: AppTypography.headingXl(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'The time you expect to reach your goal will affect your calorie budget.',
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Date Picker Headers Row
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Year',
                          style: AppTypography.labelMd(color: colors.onSurface)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Month',
                          style: AppTypography.labelMd(color: colors.onSurface)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Day',
                          style: AppTypography.labelMd(color: colors.onSurface)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Cupertino Three-Column Wheel Picker Container
              Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    // Highlight center indicator line
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(
                            alpha: 0.04,
                          ), // soft green tint
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.primary, // Solid green border!
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Year Column
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _yearController,
                            itemExtent: 46.0,
                            diameterRatio: 1.1,
                            selectionOverlay: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(
                                      alpha: 0.5,
                                    ), // soft light grey box
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedYearIndex = index;
                              });
                              _updateSelectedDate(
                                year: DateTime.now().year + index,
                              );
                            },
                            children: List.generate(10, (index) {
                              final year = DateTime.now().year + index;
                              final isSelected = index == _selectedYearIndex;
                              return Center(
                                child: AnimatedScale(
                                  scale: isSelected ? 1.15 : 0.9,
                                  duration: const Duration(milliseconds: 150),
                                  child: Text(
                                    year.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurface.withValues(
                                              alpha: 0.65,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // Month Column
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _monthController,
                            itemExtent: 46.0,
                            diameterRatio: 1.1,
                            selectionOverlay: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(
                                      alpha: 0.5,
                                    ), // soft light grey box
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedMonthIndex = index;
                              });
                              _updateSelectedDate(month: index + 1);
                            },
                            children: List.generate(12, (index) {
                              final month = index + 1;
                              final isSelected = index == _selectedMonthIndex;
                              return Center(
                                child: AnimatedScale(
                                  scale: isSelected ? 1.15 : 0.9,
                                  duration: const Duration(milliseconds: 150),
                                  child: Text(
                                    month.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurface.withValues(
                                              alpha: 0.65,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // Day Column
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _dayController,
                            itemExtent: 46.0,
                            diameterRatio: 1.1,
                            selectionOverlay: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(
                                      alpha: 0.5,
                                    ), // soft light grey box
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedDayIndex = index;
                              });
                              _updateSelectedDate(day: index + 1);
                            },
                            children: List.generate(31, (index) {
                              final day = index + 1;
                              final isSelected = index == _selectedDayIndex;
                              return Center(
                                child: AnimatedScale(
                                  scale: isSelected ? 1.15 : 0.9,
                                  duration: const Duration(milliseconds: 150),
                                  child: Text(
                                    day.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurface.withValues(
                                              alpha: 0.65,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pacing Feedback Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: paceColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isMaintenance
                                ? LucideIcons.checkCircle2
                                : LucideIcons.trendingUp,
                            color: paceColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          paceTitle,
                          style: AppTypography.headingSm(
                            color: paceColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isMaintenance) ...[
                      Text(
                        'You will maintain your current weight perfectly.',
                        style: AppTypography.bodyMd(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      RichText(
                        text: TextSpan(
                          style: AppTypography.bodyMd(
                            color: colors.onSurfaceVariant,
                          ).copyWith(height: 1.4),
                          children: [
                            const TextSpan(text: 'You will '),
                            TextSpan(text: isGaining ? 'gain ' : 'lose '),
                            TextSpan(
                              text: '${rateLbs.toStringAsFixed(1)}lbs',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const TextSpan(text: ' per week'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onNext,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(LucideIcons.arrowRight, size: 24),
      ),
    );
  }
}

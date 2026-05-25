import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_snack_bar.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _nameController = TextEditingController();
  String _selectedGender = 'Male';
  DateTime _selectedDob = DateTime(1995, 5, 17);

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  int _selectedYearIndex = 0;
  int _selectedMonthIndex = 0;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-populate from existing profile if available
    final profile = ref.read(userProfileProvider);
    _nameController.text = profile.name;
    _selectedGender = profile.gender;
    _selectedDob = profile.dateOfBirth;

    // Initialize picker controllers based on birth year starting at 1930
    _selectedYearIndex = _selectedDob.year - 1930;
    _selectedMonthIndex = _selectedDob.month - 1;
    _selectedDayIndex = _selectedDob.day - 1;

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
    _nameController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateSelectedDate({int? year, int? month, int? day}) {
    final y = year ?? _selectedDob.year;
    final m = month ?? _selectedDob.month;
    final d = day ?? _selectedDob.day;

    // Clamp day to max days in month
    final maxDays = _daysInMonth(y, m);
    final finalD = d > maxDays ? maxDays : d;

    setState(() {
      _selectedDob = DateTime(y, m, finalD);
    });
  }

  void _onNext() {
    if (_nameController.text.trim().isEmpty) {
      AppSnackBar.showError(
        context,
        message: 'Please enter your name to proceed',
      );
      return;
    }

    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          currentProfile.copyWith(
            name: _nameController.text.trim(),
            gender: _selectedGender,
            dateOfBirth: _selectedDob,
          ),
        );
    context.go(AppRoutes.onboardingHeightWeight);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingWelcome),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (index) {
            final isCurrent = index == 0;
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
                'Let\'s build your profile',
                style: AppTypography.headingXl(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                "First, tell us your basic info to begin your personalized health journey.",
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 36),

              // Name Field
              Text(
                'Your Name',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTypography.bodyLg(color: colors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(LucideIcons.user, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Date of Birth Field
              Text(
                'Date of Birth',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),

              // Date Picker Headers Row
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
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
              const SizedBox(height: 8),

              // Cupertino Three-Column Wheel Picker Container
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                        height: 44,
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
                            itemExtent: 40.0,
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
                              _updateSelectedDate(year: 1930 + index);
                            },
                            children: List.generate(
                              DateTime.now().year - 1930 + 1,
                              (index) {
                                final year = 1930 + index;
                                final isSelected = index == _selectedYearIndex;
                                return Center(
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.15 : 0.9,
                                    duration: const Duration(milliseconds: 150),
                                    child: Text(
                                      year.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
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
                              },
                            ),
                          ),
                        ),
                        // Month Column
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _monthController,
                            itemExtent: 40.0,
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
                                      fontSize: 16,
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
                            itemExtent: 40.0,
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
                                      fontSize: 16,
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
              const SizedBox(height: 28),

              // Gender Selector
              Text(
                'Gender Identity',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Male', 'Female', 'Other'].map((gender) {
                  final isSelected = _selectedGender == gender;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedGender = gender);
                          if (_nameController.text.trim().isNotEmpty) {
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                if (mounted) {
                                  _onNext();
                                }
                              },
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primaryContainer.withValues(
                                    alpha: 0.25,
                                  )
                                : colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              gender,
                              style: AppTypography.bodyLg(
                                color: isSelected
                                    ? colors.primary
                                    : colors.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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

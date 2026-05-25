import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'widgets/ruler_picker.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String _selectedGoal = 'Lose Weight';

  // Target Weight States
  String _targetWeightUnit = 'kg'; // 'kg' or 'lbs'
  double _targetWeightKg = 65.0;
  double _targetWeightLbs = 143.0;

  @override
  void initState() {
    super.initState();
    // Default target weight based on current profile weight
    final profile = ref.read(userProfileProvider);
    _selectedGoal = profile.mainGoal;
    if (profile.weightUnit.isNotEmpty) {
      _targetWeightUnit = profile.weightUnit;
    }

    // Set default target weight slightly lower than current weight as standard
    if (profile.weight > 0) {
      _targetWeightKg = profile.weight - 5.0;
      if (_targetWeightKg < 30.0) _targetWeightKg = 60.0;
      _targetWeightLbs = _targetWeightKg * 2.20462;
    } else {
      _targetWeightKg = 68.0;
      _targetWeightLbs = 150.0;
    }
  }

  void _onNext() {
    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          currentProfile.copyWith(
            mainGoal: _selectedGoal,
            targetWeight: _targetWeightKg,
            weightUnit: _targetWeightUnit,
          ),
        );
    context.go(AppRoutes.onboardingTargetReach);
  }

  String _formattedTargetWeight() {
    if (_targetWeightUnit == 'kg') {
      return "${_targetWeightKg.toStringAsFixed(1)} kg";
    } else {
      return "${_targetWeightLbs.toStringAsFixed(1)} lbs";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final goals = [
      {
        'title': 'Lose Weight',
        'subtitle': 'Burn fat, slim down and feel lighter',
        'icon': '🔥',
      },
      {
        'title': 'Maintain Weight',
        'subtitle': 'Stabilize current weight & shape',
        'icon': '⚖️',
      },
      {
        'title': 'Gain Muscle',
        'subtitle': 'Build physical strength and size',
        'icon': '💪',
      },
      {
        'title': 'Improve Health',
        'subtitle': 'Better nutrition, energy & digestion',
        'icon': '🥗',
      },
    ];

    final isTargetDriven =
        _selectedGoal == 'Lose Weight' || _selectedGoal == 'Gain Muscle';

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.onboardingHeightWeight),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 18,
                color: colors.onSurface,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (index) {
            final isCurrent = index == 2;
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
                "What's your main goal?",
                style: AppTypography.headingXl(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your tracking experience so it matches your targets.',
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // Goals List Cards
              ...goals.map((goal) {
                final title = goal['title']!;
                final subtitle = goal['subtitle']!;
                final icon = goal['icon']!;
                final isSelected = _selectedGoal == title;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedGoal = title);
                    final targetDriven =
                        title == 'Lose Weight' || title == 'Gain Muscle';
                    if (!targetDriven) {
                      Future.delayed(const Duration(milliseconds: 250), () {
                        if (mounted) {
                          _onNext();
                        }
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primaryContainer.withValues(alpha: 0.15)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isSelected ? 0.03 : 0.01,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary.withValues(alpha: 0.15)
                                : colors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.headingSm(
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: AppTypography.bodySm(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            LucideIcons.checkCircle2,
                            color: colors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Horizontal Weight Picker for Target Weight
              if (isTargetDriven) ...[
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.target,
                                color: colors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Target Weight',
                                style: AppTypography.headingMd(
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          // Unit Toggle
                          Container(
                            height: 32,
                            width: 90,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: ['kg', 'lbs'].map((unit) {
                                final isSelected = _targetWeightUnit == unit;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _targetWeightUnit = unit;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colors.surface
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        unit,
                                        style: AppTypography.bodySm(
                                          color: isSelected
                                              ? colors.primary
                                              : colors.onSurfaceVariant,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Weight Readout
                      Text(
                        _formattedTargetWeight(),
                        style: AppTypography.numeralLg(color: colors.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Horizontal Ruler Picker for Weight
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: HorizontalRulerPicker(
                          key: ValueKey("TargetWeightRuler_$_targetWeightUnit"),
                          minValue: _targetWeightUnit == 'kg' ? 30.0 : 66.0,
                          maxValue: _targetWeightUnit == 'kg' ? 220.0 : 480.0,
                          initialValue: _targetWeightUnit == 'kg'
                              ? _targetWeightKg
                              : _targetWeightLbs,
                          tickSpacing: 10.0,
                          majorTickInterval: 10,
                          mediumTickInterval: 5,
                          unit: _targetWeightUnit,
                          onChanged: (val) {
                            if (_targetWeightUnit == 'kg') {
                              _targetWeightKg = val;
                              _targetWeightLbs = val * 2.20462;
                            } else {
                              _targetWeightLbs = val;
                              _targetWeightKg = val / 2.20462;
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: isTargetDriven
          ? FloatingActionButton(
              onPressed: _onNext,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 4,
              shape: const CircleBorder(),
              child: Icon(LucideIcons.arrowRight, size: 24),
            )
          : null,
    );
  }
}

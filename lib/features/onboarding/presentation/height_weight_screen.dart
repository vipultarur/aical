import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'widgets/ruler_picker.dart';

class HeightWeightScreen extends ConsumerStatefulWidget {
  const HeightWeightScreen({super.key});

  @override
  ConsumerState<HeightWeightScreen> createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends ConsumerState<HeightWeightScreen> {
  // Height State
  String _heightUnit = 'cm'; // 'cm' or 'ft'
  double _heightCm = 175.0;
  double _heightInches = 69.0; // 5'9" is 69 inches

  // Weight State
  String _weightUnit = 'kg'; // 'kg' or 'lbs'
  double _weightKg = 70.0;
  double _weightLbs = 154.0;

  @override
  void initState() {
    super.initState();
    // Load from existing profile if available
    final profile = ref.read(userProfileProvider);
    if (profile.height > 0) {
      _heightCm = profile.height;
      _heightInches = profile.height / 2.54;
    }
    if (profile.weight > 0) {
      _weightKg = profile.weight;
      _weightLbs = profile.weight * 2.20462;
    }
  }

  void _onNext() {
    final currentProfile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          currentProfile.copyWith(
            height: _heightCm,
            weight: _weightKg,
            weightUnit: _weightUnit,
          ),
        );
    context.go(AppRoutes.onboardingGoals);
  }

  // Format height display text
  String _formattedHeight() {
    if (_heightUnit == 'cm') {
      return "${_heightCm.round()} cm";
    } else {
      final int ft = _heightInches.round() ~/ 12;
      final int inches = _heightInches.round() % 12;
      return "$ft'$inches\"";
    }
  }

  // Format weight display text
  String _formattedWeight() {
    if (_weightUnit == 'kg') {
      return "${_weightKg.toStringAsFixed(1)} kg";
    } else {
      return "${_weightLbs.toStringAsFixed(1)} lbs";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.onboardingBasicInfo),
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
            final isCurrent = index == 1;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Body Metrics',
                style: AppTypography.headingXl(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                "Scroll the rulers to input your current height and weight.",
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Column(
                  children: [
                    // --- HEIGHT CARD (Top) ---
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left side: Height Label, Readout, and Unit Switch
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.arrowUpDown,
                                          color: colors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Height',
                                          style: AppTypography.headingMd(
                                            color: colors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _formattedHeight(),
                                      style: AppTypography.numeralLg(
                                        color: colors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Height Unit Toggle inside the card
                                    Container(
                                      height: 38,
                                      width: 110,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: ['cm', 'ft'].map((unit) {
                                          final isSelected =
                                              _heightUnit == unit;
                                          return Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _heightUnit = unit;
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? colors.surface
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  unit,
                                                  style: AppTypography.bodySm(
                                                    color: isSelected
                                                        ? colors.primary
                                                        : colors
                                                              .onSurfaceVariant,
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
                              ),
                            ),
                            // Right side: Vertical Ruler Picker
                            Expanded(
                              flex: 5,
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: VerticalRulerPicker(
                                  key: ValueKey("HeightRuler_$_heightUnit"),
                                  minValue: _heightUnit == 'cm' ? 100.0 : 36.0,
                                  maxValue: _heightUnit == 'cm' ? 240.0 : 96.0,
                                  initialValue: _heightUnit == 'cm'
                                      ? _heightCm
                                      : _heightInches,
                                  tickSpacing: 10.0,
                                  majorTickInterval: _heightUnit == 'cm'
                                      ? 10
                                      : 12,
                                  mediumTickInterval: _heightUnit == 'cm'
                                      ? 5
                                      : 6,
                                  unit: _heightUnit,
                                  onChanged: (val) {
                                    if (_heightUnit == 'cm') {
                                      _heightCm = val;
                                      _heightInches = val / 2.54;
                                    } else {
                                      _heightInches = val;
                                      _heightCm = val * 2.54;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- WEIGHT CARD (Bottom) ---
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.scale,
                                      color: colors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Weight',
                                      style: AppTypography.headingMd(
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                // Weight Unit Toggle
                                Container(
                                  height: 38,
                                  width: 110,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: ['kg', 'lbs'].map((unit) {
                                      final isSelected = _weightUnit == unit;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _weightUnit = unit;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colors.surface
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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

                            // Weight Readout
                            Column(
                              children: [
                                Text(
                                  _formattedWeight(),
                                  style: AppTypography.numeralLg(
                                    color: colors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Current Weight',
                                  style: AppTypography.labelMd(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                            // Horizontal Ruler Picker for Weight
                            Container(
                              height: 110,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: HorizontalRulerPicker(
                                key: ValueKey("WeightRuler_$_weightUnit"),
                                minValue: _weightUnit == 'kg' ? 30.0 : 66.0,
                                maxValue: _weightUnit == 'kg' ? 220.0 : 480.0,
                                initialValue: _weightUnit == 'kg'
                                    ? _weightKg
                                    : _weightLbs,
                                tickSpacing: 10.0,
                                majorTickInterval: 10,
                                mediumTickInterval: 5,
                                unit: _weightUnit,
                                onChanged: (val) {
                                  if (_weightUnit == 'kg') {
                                    _weightKg = val;
                                    _weightLbs = val * 2.20462;
                                  } else {
                                    _weightLbs = val;
                                    _weightKg = val / 2.20462;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

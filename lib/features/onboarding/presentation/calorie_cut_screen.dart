import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/onboarding/models/calorie_cut_config.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_back_button.dart';
import 'package:calcount/common/widgets/app_progress_dots.dart';

/// Visual onboarding step showing a suggested calorie cut target.
class CalorieCutScreen extends ConsumerStatefulWidget {
  const CalorieCutScreen({super.key});

  @override
  ConsumerState<CalorieCutScreen> createState() => _CalorieCutScreenState();
}

class _CalorieCutScreenState extends ConsumerState<CalorieCutScreen> {
  void _onNext() {
    context.go(AppRoutes.onboardingEatingStyle);
  }

  Widget _buildHabitChip({
    required IconData icon,
    required String label,
    required String value,
    double leftOffset = 0,
    bool valueFirst = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: leftOffset),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.height(10),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFF8A3D), size: 20),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                children: valueFirst
                    ? [
                        TextSpan(
                          text: '$value ',
                          style: const TextStyle(
                            color: AppColors.onboardingBrandBlueText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: label,
                          style: const TextStyle(
                            color: AppColors.onboardingLabel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    : [
                        TextSpan(
                          text: label,
                          style: const TextStyle(
                            color: AppColors.onboardingLabel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: value,
                          style: const TextStyle(
                            color: AppColors.onboardingBrandBlueText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = ref.watch(userProfileProvider);
    final config = CalorieCutConfig.forActivityLevel(profile.activityLevel);
    final cutValue = config.cutValue;

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          onPressed: () => context.go(AppRoutes.onboardingActivityLevel),
        ),
        title: const AppProgressDots(totalSteps: 9, currentStep: 6),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppDimensions.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
                child: Text(
                  'Cut $cutValue kcal a day\neffortlessly',
                  style:
                      AppTypography.headingXl(
                        color: AppColors.onboardingTitle,
                      ).copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.8,
                        height: 1.25,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppDimensions.xxl),
              SizedBox(
                height: AppDimensions.height(330),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -60,
                      top: 15,
                      width: 300,
                      height: 300,
                      child: CustomPaint(painter: CentralDiscPainter()),
                    ),
                    Positioned(
                      right: 10,
                      top: 85,
                      width: 160,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.onboardingBrandBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onboardingBrandBlue.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$cutValue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Inter',
                                letterSpacing: -1.0,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '≈',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Inter',
                                height: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHabitChip(
                            icon: LucideIcons.waves,
                            label: 'Swimming ',
                            value: '83 min',
                          ),
                          SizedBox(height: AppDimensions.lg),
                          _buildHabitChip(
                            icon: LucideIcons.activity,
                            label: 'Running ',
                            value: '69 min',
                            leftOffset: 12,
                          ),
                          SizedBox(height: AppDimensions.lg),
                          _buildHabitChip(
                            icon: LucideIcons.cake,
                            label: 'piece of cake',
                            value: '1',
                            valueFirst: true,
                          ),
                          SizedBox(height: AppDimensions.lg),
                          _buildHabitChip(
                            icon: LucideIcons.utensilsCrossed,
                            label: 'bites of fried chicken',
                            value: '3',
                            leftOffset: 14,
                            valueFirst: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.xxxl),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.xxxl),
                child: Text(
                  "WiseMeal reduces users' daily intake by $cutValue kcal on average.",
                  style: const TextStyle(
                    color: AppColors.onboardingMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppDimensions.jumbo),
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
        child: const Icon(LucideIcons.arrowRight, size: 24),
      ),
    );
  }
}

// Custom Painter for segmented background rings matching mockup.
class CentralDiscPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paintGreen = Paint()
      ..color = AppColors.onboardingDiscGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    final paintYellow = Paint()
      ..color = AppColors.onboardingDiscYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    final paintOrange = Paint()
      ..color = AppColors.onboardingDiscOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    final paintBlue = Paint()
      ..color = AppColors.onboardingDiscBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    canvas.drawArc(rect, 0.0, 1.4, false, paintGreen);
    canvas.drawArc(rect, 1.6, 1.2, false, paintYellow);
    canvas.drawArc(rect, 3.0, 1.2, false, paintOrange);
    canvas.drawArc(rect, 4.4, 1.6, false, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';

class CalorieRing extends StatefulWidget {
  final int eaten;
  final int goal;
  final int burned;
  final double size;

  const CalorieRing({
    required this.eaten,
    required this.goal,
    this.burned = 0,
    this.size = 220.0,
    super.key,
  });

  @override
  State<CalorieRing> createState() => _CalorieRingState();
}

class _CalorieRingState extends State<CalorieRing>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _breatheController;
  late Animation<double> _sweepAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    // Sweep-in animation on load
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _sweepAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeOutBack),
    );

    // Idle breathing animation
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _sweepController.forward();
  }

  @override
  void didUpdateWidget(covariant CalorieRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eaten != widget.eaten || oldWidget.goal != widget.goal) {
      _sweepController.reset();
      _sweepController.forward();
    }
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final ringSize = AppDimensions.size(widget.size);

    final remaining = widget.goal + widget.burned - widget.eaten;
    final isOverGoal = remaining < 0;

    // Percent calculated
    final double percent = widget.goal > 0
        ? (widget.eaten / (widget.goal + widget.burned))
        : 0.0;
    final cappedPercent = percent.clamp(0.0, 1.0);

    return ScaleTransition(
      scale: _breatheAnimation,
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Custom painter drawing tracks
            AnimatedBuilder(
              animation: _sweepAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _CalorieRingPainter(
                    percent: cappedPercent * _sweepAnimation.value,
                    isOverGoal: isOverGoal,
                    isDark: isDark,
                    trackColor: colors.surfaceContainerHighest,
                    progressColor: isOverGoal ? colors.error : colors.primary,
                    progressGradientColor: isOverGoal
                        ? colors.errorContainer
                        : AppColors.greenLeaf,
                  ),
                );
              },
            ),

            // Text values placed in center
            Padding(
              padding: AppDimensions.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CALORIES',
                    style: AppTypography.labelSm(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppDimensions.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${remaining.abs()}',
                      style: AppTypography.numeralHero(
                        color: isOverGoal ? colors.error : colors.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.xxs),
                  Text(
                    isOverGoal ? 'over budget' : 'remaining',
                    style: AppTypography.bodySm(
                      color: isOverGoal
                          ? colors.error
                          : colors.onSurfaceVariant,
                      fontWeight: isOverGoal
                          ? FontWeight.bold
                          : FontWeight.normal,
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
}

class _CalorieRingPainter extends CustomPainter {
  final double percent;
  final bool isOverGoal;
  final bool isDark;
  final Color trackColor;
  final Color progressColor;
  final Color progressGradientColor;

  _CalorieRingPainter({
    required this.percent,
    required this.isOverGoal,
    required this.isDark,
    required this.trackColor,
    required this.progressColor,
    required this.progressGradientColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - AppDimensions.width(20)) / 2;
    final strokeWidth = AppDimensions.width(16);

    // 1. Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (percent <= 0) return;

    // 2. Draw progress line
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2; // top center
    final sweepAngle = 2 * math.pi * percent;

    // Soft glow shadow in dark mode
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isDark) {
      progressPaint.shadowUnderPath(
        color: progressColor.withValues(alpha: 0.4),
        blur: AppDimensions.width(12),
      );
    }

    // Set linear shader gradient
    progressPaint.shader = SweepGradient(
      colors: [progressColor, progressGradientColor, progressColor],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(startAngle),
    ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CalorieRingPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.isOverGoal != isOverGoal ||
        oldDelegate.isDark != isDark ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// Helper expansion to inject path shadow glows safely
extension _ShadowGlowPaint on Paint {
  void shadowUnderPath({required Color color, required double blur}) {
    maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
  }
}

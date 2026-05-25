import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';

class WeightPredictionScreen extends ConsumerStatefulWidget {
  const WeightPredictionScreen({super.key});

  @override
  ConsumerState<WeightPredictionScreen> createState() =>
      _WeightPredictionScreenState();
}

class _WeightPredictionScreenState extends ConsumerState<WeightPredictionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chartProgressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _chartProgressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatMonth(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  void _onNext() {
    context.go(AppRoutes.onboardingActivityLevel);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = ref.watch(userProfileProvider);

    final currentWeightKg = profile.weight;
    final targetWeightKg = profile.targetWeight;
    final unitLabel = profile.weightUnit.isNotEmpty ? profile.weightUnit : 'kg';

    final double currentWeight = unitLabel == 'lbs'
        ? (currentWeightKg * 2.20462)
        : currentWeightKg;
    final double targetWeight = unitLabel == 'lbs'
        ? (targetWeightKg * 2.20462)
        : targetWeightKg;

    final targetDate = profile.targetDate;
    final formattedDate = "${_formatMonth(targetDate)} ${targetDate.day}";
    final isLosing = targetWeightKg < currentWeightKg;
    final isGaining = targetWeightKg > currentWeightKg;

    return Scaffold(
      backgroundColor: const Color(
        0xFFEDF3FA,
      ), // Premium soft baby-blue/gray mockup background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go(AppRoutes.onboardingTargetReach),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(9, (index) {
            final isCurrent = index == 4;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 2),
            // Header predictions text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "We predict that you'll be",
                    style:
                        AppTypography.headingMd(
                          color: const Color(0xFF1A1A1A),
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: -0.2,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style:
                          AppTypography.headingXl(
                            color: const Color(0xFF1A1A1A),
                          ).copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                      children: [
                        TextSpan(
                          text:
                              "${targetWeight.toStringAsFixed(1)} $unitLabel ",
                          style: const TextStyle(
                            color: Color(
                              0xFF2686F5,
                            ), // Vibrant brand blue matching mockup perfectly
                          ),
                        ),
                        TextSpan(
                          text: "by $formattedDate",
                          style: const TextStyle(
                            color: Color(
                              0xFF1A1A1A,
                            ), // Rich solid charcoal black
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Main Interactive Chart Canvas with layout positioning
            Expanded(
              child: AnimatedBuilder(
                animation: _chartProgressAnimation,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final W = constraints.maxWidth;
                      final H = constraints.maxHeight;

                      // Exact alignment ratios matching the original mockup image
                      final xToday = W * 0.18;
                      final xTarget = W * 0.72;
                      final xEnd = W;

                      // Y coordinates depending on loss vs gain
                      double yToday;
                      double yTarget;
                      if (isLosing) {
                        yToday = H * 0.24;
                        yTarget = H * 0.65;
                      } else if (isGaining) {
                        yToday = H * 0.65;
                        yTarget = H * 0.24;
                      } else {
                        yToday = H * 0.45;
                        yTarget = H * 0.45;
                      }

                      // Exact pill badge alignment
                      final targetXOffset = xTarget;
                      final targetYOffset = yTarget;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Custom Paint Chart
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PredictionChartPainter(
                                progress: _chartProgressAnimation.value,
                                isLosing: isLosing,
                                isGaining: isGaining,
                                todayWeightText:
                                    "${currentWeight.toStringAsFixed(1)} $unitLabel",
                                W: W,
                                H: H,
                                xToday: xToday,
                                xTarget: xTarget,
                                xEnd: xEnd,
                                yToday: yToday,
                                yTarget: yTarget,
                                strokeColor: const Color(0xFF2686F5),
                                baselineColor: colors.outline.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),

                          // Target Floating Pill Widget positioned exactly at target point!
                          Positioned(
                            left:
                                targetXOffset -
                                34, // Center-align pill (pill width is 68)
                            top:
                                targetYOffset -
                                52, // Vertically center around yTarget so curve passes through center
                            child: Opacity(
                              opacity: _chartProgressAnimation.value,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  (1 - _chartProgressAnimation.value) * 15,
                                ),
                                child: Container(
                                  width: 68,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(34),
                                    border: Border.all(
                                      color: const Color(0xFF2686F5),
                                      width: 3.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2686F5,
                                        ).withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatMonth(targetDate),
                                        style:
                                            AppTypography.labelSm(
                                              color: colors.onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                            ).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${targetDate.day}",
                                        style:
                                            AppTypography.headingMd(
                                              color: colors.onSurface,
                                            ).copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 22,
                                              height: 1.0,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: Color(
                                            0xFFFA8725,
                                          ), // Vibrant orange flag circle from mockup
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            LucideIcons.flag,
                                            color: Colors.white,
                                            size: 13,
                                          ),
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
                    },
                  );
                },
              ),
            ),

            // Card at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFFEF0F0,
                        ), // Soft red background for target
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFCDADA),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.crosshair, // Bullseye icon
                        color: Color(0xFFE84E4E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Still on track!",
                            style: AppTypography.headingSm(
                              color: colors.onSurface,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "We'll incorporate your goal into your personalized plan.",
                            style: AppTypography.bodyMd(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.8,
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
            const SizedBox(height: 32),
          ],
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

// Custom Painter for weight path curve rendering
class PredictionChartPainter extends CustomPainter {
  final double progress;
  final bool isLosing;
  final bool isGaining;
  final String todayWeightText;
  final double W;
  final double H;
  final double xToday;
  final double xTarget;
  final double xEnd;
  final double yToday;
  final double yTarget;
  final Color strokeColor;
  final Color baselineColor;

  PredictionChartPainter({
    required this.progress,
    required this.isLosing,
    required this.isGaining,
    required this.todayWeightText,
    required this.W,
    required this.H,
    required this.xToday,
    required this.xTarget,
    required this.xEnd,
    required this.yToday,
    required this.yTarget,
    required this.strokeColor,
    required this.baselineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw dashed grid lines (vertical today and target lines)
    final dashedPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.20)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedVerticalLine(canvas, xToday, yToday, H, dashedPaint);
    _drawDashedVerticalLine(canvas, xTarget, yTarget, H, dashedPaint);

    // 2. Draw standard pace baseline (Premium wavy gray dashed curve matching mockup exactly)
    final baselinePaint = Paint()
      ..color =
          const Color(0xFFD2D6DC) // Soft mockup gray
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final baselinePath = Path();
    baselinePath.moveTo(xToday, yToday);

    // Precise mockup curve wave formula (goes up slightly forming a gentle hill, then declines smoothly)
    final bx1 = xToday + (xEnd - xToday) * 0.35;
    final by1 = yToday - 28; // Beautiful upward curve hill
    final bx2 = xToday + (xEnd - xToday) * 0.70;
    final by2 = yToday + (yTarget - yToday) * 0.45;
    final bxEnd = xEnd;
    final byEnd = yToday + (yTarget - yToday) * 0.62; // Wavy trailing end

    baselinePath.cubicTo(bx1, by1, bx2, by2, bxEnd, byEnd);
    _drawDashedPath(
      canvas,
      baselinePath,
      baselinePaint,
      7.0,
      5.0,
    ); // Exact dashed look

    // 3. Draw primary prediction curve (vibrant sky-blue curve curving smoothly from left edge)
    final path = Path();
    final double yStart = yToday - 22; // Start slightly higher at left edge
    path.moveTo(0, yStart);

    // Curve smoothly from left edge to the Today dot
    final startCtrlX = xToday * 0.55;
    path.cubicTo(startCtrlX, yStart, startCtrlX, yToday, xToday, yToday);

    // S-curve from Today dot down to Target Pill
    final xCtrl1 = xToday + (xTarget - xToday) * 0.35;
    final yCtrl1 = yToday + (yTarget - yToday) * 0.12;
    final xCtrl2 = xToday + (xTarget - xToday) * 0.65;
    final yCtrl2 = yTarget - (yTarget - yToday) * 0.08;

    path.cubicTo(xCtrl1, yCtrl1, xCtrl2, yCtrl2, xTarget, yTarget);
    path.lineTo(xEnd, yTarget);

    // Slice path based on progress animation
    final animatedPath = _extractPathSegment(path, progress);

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the gradient filled area beneath the main prediction curve starting from left edge
    if (progress > 0) {
      // Create a solid fill path by starting with the animated curve and appending bottom bounds
      final fillPath = _extractPathSegment(path, progress);
      final lastPoint = _getEndpointOfPath(fillPath);

      fillPath.lineTo(lastPoint.dx, H); // Line down to bottom right boundary
      fillPath.lineTo(0, H); // Line left along bottom edge to x=0
      fillPath.close(); // Form solid rectangular shape

      final fillGradient = LinearGradient(
        colors: [
          strokeColor.withValues(alpha: 0.28), // Bright rich blue top
          strokeColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      final fillPaint = Paint()
        ..shader = fillGradient.createShader(
          Rect.fromLTRB(0, yToday - 40, W, H),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw the solid blue curve stroke on top
    canvas.drawPath(animatedPath, strokePaint);

    // 4. Draw Today starting point marker (solid dot with white border and outer halo)
    // A. Outer translucent glow
    final glowPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(xToday, yToday), 15.0, glowPaint);

    // B. White thick ring/border
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(xToday, yToday), 8.5, ringPaint);

    // C. Solid vibrant blue center dot
    final centerPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(xToday, yToday), 5.5, centerPaint);

    // Draw Today text label below
    const textStyleGray = TextStyle(
      color: Color(0xFF888888),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'Roboto',
    );
    final todayTextPainter = TextPainter(
      text: const TextSpan(text: "Today", style: textStyleGray),
      textDirection: TextDirection.ltr,
    )..layout();
    todayTextPainter.paint(
      canvas,
      Offset(xToday - todayTextPainter.width / 2, H - 56),
    );

    // Draw starting weight text label
    final weightTextPainter = TextPainter(
      text: TextSpan(
        text: todayWeightText,
        style: const TextStyle(
          color: Color(0xFF2A2A2A),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    weightTextPainter.paint(
      canvas,
      Offset(xToday - weightTextPainter.width / 2, H - 38),
    );
  }

  void _drawDashedVerticalLine(
    Canvas canvas,
    double x,
    double yStart,
    double yEnd,
    Paint paint,
  ) {
    const dashHeight = 6.0;
    const dashSpace = 4.0;
    double startY = yStart;

    startY += 12.0; // Offset to clear marker circles

    while (startY < yEnd - 60) {
      canvas.drawLine(Offset(x, startY), Offset(x, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  // Draw beautiful dashed path matching mockup exactly
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + dashLength);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  Path _extractPathSegment(Path sourcePath, double progressFraction) {
    final path = Path();
    final metrics = sourcePath.computeMetrics().toList();
    for (final metric in metrics) {
      final limit = metric.length * progressFraction;
      path.addPath(metric.extractPath(0.0, limit), Offset.zero);
    }
    return path;
  }

  Offset _getEndpointOfPath(Path path) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return Offset.zero;
    final lastMetric = metrics.last;
    return lastMetric.getTangentForOffset(lastMetric.length)?.position ??
        Offset.zero;
  }

  @override
  bool shouldRepaint(covariant PredictionChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isLosing != isLosing ||
        oldDelegate.isGaining != isGaining ||
        oldDelegate.todayWeightText != todayWeightText;
  }
}

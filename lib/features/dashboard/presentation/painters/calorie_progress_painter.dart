import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the circular calorie progress ring on the dashboard.
final class CalorieProgressPainter extends CustomPainter {
  const CalorieProgressPainter({
    required this.percent,
    required this.progressColor,
    required this.trackColor,
  });

  final double percent;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 9.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (percent <= 0) {
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percent;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    final endAngle = startAngle + sweepAngle;
    final thumbX = center.dx + radius * math.cos(endAngle);
    final thumbY = center.dy + radius * math.sin(endAngle);

    final thumbShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 6.5, thumbShadowPaint);

    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, thumbY), 5.0, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant CalorieProgressPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}

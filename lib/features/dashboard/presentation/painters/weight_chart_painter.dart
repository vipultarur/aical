import 'package:flutter/material.dart';

import 'package:calcount/common/models/weight_entry.dart';

/// Paints the weight trend curve on the dashboard card using real history data.
final class WeightChartPainter extends CustomPainter {
  const WeightChartPainter({
    required this.lineColor,
    required this.dotColor,
    this.weightHistory = const [],
  });

  final Color lineColor;
  final Color dotColor;

  /// Sorted list of weight entries (oldest → newest). If empty, a placeholder
  /// curve is drawn so the card always looks complete.
  final List<WeightEntry> weightHistory;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    if (weightHistory.length >= 2) {
      _paintRealData(canvas, size, linePaint);
    } else {
      _paintPlaceholder(canvas, size, linePaint);
    }
  }

  void _paintRealData(Canvas canvas, Size size, Paint linePaint) {
    // Sorted entries (should already be sorted, but guard anyway)
    final sorted = List<WeightEntry>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    final weights = sorted.map((e) => e.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW).abs();
    // Add 10% padding so points don't sit on the very edge
    final effectiveRange = range < 0.5 ? 2.0 : range * 1.2;

    final path = Path();
    for (int i = 0; i < sorted.length; i++) {
      final x = (i / (sorted.length - 1)) * size.width * 0.9;
      final normalised = range < 0.5
          ? 0.5
          : (sorted[i].weight - minW) / effectiveRange;
      // Invert: heavier = lower on canvas
      final y = size.height * (1.0 - normalised.clamp(0.1, 0.9));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Start dot (oldest)
    final startX = 0.0;
    final startNorm = range < 0.5
        ? 0.5
        : (sorted.first.weight - minW) / effectiveRange;
    final startY = size.height * (1.0 - startNorm.clamp(0.1, 0.9));
    _drawDot(canvas, Offset(startX, startY), dotColor);

    // End dot + goal flag (newest)
    final endX = size.width * 0.9;
    final endNorm = range < 0.5
        ? 0.5
        : (sorted.last.weight - minW) / effectiveRange;
    final endY = size.height * (1.0 - endNorm.clamp(0.1, 0.9));
    _drawFlag(canvas, size, Offset(endX, endY));
    _drawEndDot(canvas, Offset(endX, endY));
  }

  void _paintPlaceholder(Canvas canvas, Size size, Paint linePaint) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.38,
        size.width * 0.6,
        size.height * 0.8,
        size.width * 0.9,
        size.height * 0.85,
      );
    canvas.drawPath(path, linePaint);
    _drawDot(canvas, Offset(0, size.height * 0.35), dotColor);
    _drawFlag(canvas, size, Offset(size.width * 0.9, size.height * 0.85));
    _drawEndDot(canvas, Offset(size.width * 0.9, size.height * 0.85));
  }

  void _drawDot(Canvas canvas, Offset center, Color color) {
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.5, outline);
    canvas.drawCircle(center, 3.5, fill);
  }

  void _drawEndDot(Canvas canvas, Offset center) {
    final endPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.5, endPaint);
  }

  void _drawFlag(Canvas canvas, Size size, Offset tip) {
    final flagPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    final flagPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx, tip.dy - size.height * 0.4)
      ..lineTo(tip.dx + size.width * 0.08, tip.dy - size.height * 0.32)
      ..lineTo(tip.dx, tip.dy - size.height * 0.2)
      ..close();
    canvas.drawPath(flagPath, flagPaint);
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.weightHistory != weightHistory;
  }
}

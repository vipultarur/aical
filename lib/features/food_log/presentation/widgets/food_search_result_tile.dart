import 'package:flutter/material.dart';

import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';

class FoodSearchResultTile extends StatelessWidget {
  const FoodSearchResultTile({
    required this.item,
    required this.onTap,
    required this.onAdd,
    super.key,
  });

  final FoodSearchItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerLowest
            : const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A), // Slate 900
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.calories} kcal, ${item.servingAmount.toStringAsFixed(1)} ${item.servingUnit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF64748B), // Slate 500
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  behavior: HitTestBehavior.opaque,
                  child: const DashedAddIcon(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedAddIcon extends StatelessWidget {
  const DashedAddIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey.shade500 : const Color(0xFFCBD5E1);

    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(painter: _DashedAddPainter(color: color)),
    );
  }
}

class _DashedAddPainter extends CustomPainter {
  final Color color;

  _DashedAddPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = (size.width - borderPaint.strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw dashed circle
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    final double circumference = 2 * 3.141592653589793 * radius;
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final double sweepAngle =
        (dashWidth / circumference) * 2 * 3.141592653589793;
    final double anglePerDash = (2 * 3.141592653589793) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * anglePerDash,
        sweepAngle,
        false,
        borderPaint,
      );
    }

    // Draw thin rounded plus
    final Paint plusPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double thickness = 2.0;
    const double length = 18;

    // Horizontal rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: length, height: thickness),
        const Radius.circular(thickness / 2),
      ),
      plusPaint,
    );
    // Vertical rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: thickness, height: length),
        const Radius.circular(thickness / 2),
      ),
      plusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

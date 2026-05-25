import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints a high-fidelity 3D glass cup with thick glass walls, a solid base, and animated fluid physics + overflow cascading droplets.
/// Utilizes a generous padded layout leaving margins on all sides so all spill animations are 100% visible.
final class WaterCupPainter extends CustomPainter {
  const WaterCupPainter({
    required this.fillPercent,
    required this.animationValue,
  });

  final double fillPercent;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Define outer glass shell U-shape shape (leaves a safe 22% margin on sides, 15% on top)
    final glassPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.15) // top left corner
      ..lineTo(size.width * 0.31, size.height * 0.86) // down to bottom left
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.90,
        size.width * 0.69,
        size.height * 0.86,
      ) // bottom curve
      ..lineTo(size.width * 0.78, size.height * 0.15); // up to top right corner

    // Path closed for glass body color backing
    final fillPath = Path.from(glassPath)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.20, // Matches bottom edge of top rim
        size.width * 0.22,
        size.height * 0.15,
      );

    // 2. Define inner cup cavity (where water is contained)
    // Closed straight across the top Y=0.17 to prevent top-center clipping!
    final innerPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.17)
      ..lineTo(size.width * 0.33, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.85,
        size.width * 0.67,
        size.height * 0.82,
      )
      ..lineTo(size.width * 0.75, size.height * 0.17)
      ..close();

    // 3. Draw subtle solid glass background backing (gives the glass container body)
    final glassBodyPaint = Paint()
      ..color = Colors.blue.shade50.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, glassBodyPaint);

    // 4. Draw outer glass outline shell
    final glassOutlinePaint = Paint()
      ..color = Colors.blue.shade100.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawPath(glassPath, glassOutlinePaint);

    // 5. Draw 3D elliptical top rim (opening rim)
    final rimPaint = Paint()
      ..color = Colors.blue.shade100.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawOval(
      Rect.fromLTRB(
        size.width * 0.22,
        size.height * 0.10,
        size.width * 0.78,
        size.height * 0.20,
      ),
      rimPaint,
    );

    // 6. Draw dual-layered liquid sine-waves clipped inside the glass cavity!
    if (fillPercent > 0.0) {
      canvas
        ..save()
        ..clipPath(innerPath);

      // Waves naturally flatten as the glass becomes completely full or empty
      final double waveFactor = (fillPercent > 0.0 && fillPercent < 1.0)
          ? 1.0
          : 0.0;

      // Determine the water height relative to the inner cavity
      final double innerTopY = size.height * 0.17;
      final double innerBottomY = size.height * 0.82;
      final double innerHeight = innerBottomY - innerTopY;
      final double baseHeight = innerBottomY - (innerHeight * fillPercent);

      // Draw BACK WAVE (Deep cyan water)
      final backWavePath = Path();
      backWavePath.moveTo(0, baseHeight);
      for (double x = 0; x <= size.width; x++) {
        final double angle =
            (x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi);
        final double amplitude = size.height * 0.05 * waveFactor;
        final double y = baseHeight + (math.sin(angle) * amplitude);
        backWavePath.lineTo(x, y);
      }
      backWavePath.lineTo(size.width, size.height);
      backWavePath.lineTo(0, size.height);
      backWavePath.close();

      final backWaterPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(
              0xFF00D2FF,
            ).withValues(alpha: 0.65), // Vibrant translucent cyan
            const Color(
              0xFF0078FF,
            ).withValues(alpha: 0.85), // Rich translucent blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect)
        ..style = PaintingStyle.fill;
      canvas.drawPath(backWavePath, backWaterPaint);

      // Draw FRONT WAVE (Bright translucent turquoise)
      final frontWavePath = Path();
      frontWavePath.moveTo(0, baseHeight);
      for (double x = 0; x <= size.width; x++) {
        final double angle =
            (x / size.width * 2 * math.pi) -
            (animationValue * 2 * math.pi) +
            math.pi;
        final double amplitude = size.height * 0.035 * waveFactor;
        final double y = baseHeight + (math.sin(angle) * amplitude);
        frontWavePath.lineTo(x, y);
      }
      frontWavePath.lineTo(size.width, size.height);
      frontWavePath.lineTo(0, size.height);
      frontWavePath.close();

      final frontWaterPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(
              0xFFE0F7FA,
            ).withValues(alpha: 0.75), // Sparkling light top cap
            const Color(
              0xFF00B0FF,
            ).withValues(alpha: 0.90), // Glowing cyan water
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect)
        ..style = PaintingStyle.fill;
      canvas.drawPath(frontWavePath, frontWaterPaint);

      canvas.restore();
    }

    // 7. Draw outer glass gloss/sheen highlights
    final sheenPaint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final sheenPath1 = Path()
      ..moveTo(size.width * 0.28, size.height * 0.22)
      ..lineTo(size.width * 0.34, size.height * 0.76);
    canvas.drawPath(sheenPath1, sheenPaint1);

    final sheenPaint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final sheenPath2 = Path()
      ..moveTo(size.width * 0.72, size.height * 0.22)
      ..lineTo(size.width * 0.67, size.height * 0.76);
    canvas.drawPath(sheenPath2, sheenPaint2);

    // 8. Draw physical cascading water droplets overflow animation when glass is 100% full!
    if (fillPercent >= 1.0) {
      final double y1 = size.height * 0.15;
      final double y2 = size.height * 0.86;
      final double yHeight = y2 - y1;

      // Draw left cascading droplets
      final leftDropPositions = [
        (animationValue + 0.0) % 1.0,
        (animationValue + 0.35) % 1.0,
        (animationValue + 0.7) % 1.0,
      ];

      for (double progress in leftDropPositions) {
        final double opacity = 1.0 - progress;
        if (opacity > 0.05) {
          final double y = y1 + (yHeight * progress);
          // Coordinates follow exact left wall slope
          final double x = (size.width * 0.22) + (size.width * 0.09 * progress);
          final double radius = 3.5 * opacity;

          final dropPaint = Paint()
            ..color = const Color(0xFF00B0FF).withValues(alpha: 0.8 * opacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x - 2.0, y), radius, dropPaint);

          final reflectPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.9 * opacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(x - 2.0 - (radius * 0.3), y - (radius * 0.3)),
            radius * 0.35,
            reflectPaint,
          );
        }
      }

      // Draw right cascading droplets
      final rightDropPositions = [
        (animationValue + 0.18) % 1.0,
        (animationValue + 0.52) % 1.0,
        (animationValue + 0.85) % 1.0,
      ];

      for (double progress in rightDropPositions) {
        final double opacity = 1.0 - progress;
        if (opacity > 0.05) {
          final double y = y1 + (yHeight * progress);
          // Coordinates follow exact right wall slope
          final double x = (size.width * 0.78) - (size.width * 0.09 * progress);
          final double radius = 3.5 * opacity;

          final dropPaint = Paint()
            ..color = const Color(0xFF00B0FF).withValues(alpha: 0.8 * opacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x + 2.0, y), radius, dropPaint);

          final reflectPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.9 * opacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(x + 2.0 - (radius * 0.3), y - (radius * 0.3)),
            radius * 0.35,
            reflectPaint,
          );
        }
      }

      // Draw top rim overflow spills
      final spillPaint = Paint()
        ..color = const Color(0xFF00B0FF).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      // Left rim spill bulge (100% visible inside margins)
      final leftSpill = Path()
        ..moveTo(size.width * 0.21, size.height * 0.15)
        ..quadraticBezierTo(
          size.width * 0.18,
          size.height * 0.19,
          size.width * 0.22,
          size.height * 0.25,
        )
        ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.20,
          size.width * 0.24,
          size.height * 0.15,
        )
        ..close();
      canvas.drawPath(leftSpill, spillPaint);

      // Right rim spill bulge (100% visible inside margins)
      final rightSpill = Path()
        ..moveTo(size.width * 0.79, size.height * 0.15)
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.19,
          size.width * 0.78,
          size.height * 0.25,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.20,
          size.width * 0.76,
          size.height * 0.15,
        )
        ..close();
      canvas.drawPath(rightSpill, spillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaterCupPainter oldDelegate) {
    return oldDelegate.fillPercent != fillPercent ||
        oldDelegate.animationValue != animationValue;
  }
}

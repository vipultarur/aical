import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 80,
    this.frameColor,
    this.shellColor,
    this.yolkColor,
    this.glowColor,
    this.showGlow = true,
  });

  final double size;
  final Color? frameColor;
  final Color? shellColor;
  final Color? yolkColor;
  final Color? glowColor;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = AppDimensions.size(size);

    return SizedBox.square(
      dimension: resolvedSize,
      child: CustomPaint(
        painter: _BrandLogoPainter(
          frameColor: frameColor ?? AppColors.platinum400,
          shellColor: shellColor ?? AppColors.neutral0,
          yolkColor: yolkColor ?? AppColors.yolk500,
          glowColor: glowColor ?? AppColors.yolk500.withValues(alpha: 0.18),
          showGlow: showGlow,
        ),
      ),
    );
  }
}

class _BrandLogoPainter extends CustomPainter {
  _BrandLogoPainter({
    required this.frameColor,
    required this.shellColor,
    required this.yolkColor,
    required this.glowColor,
    required this.showGlow,
  });

  final Color frameColor;
  final Color shellColor;
  final Color yolkColor;
  final Color glowColor;
  final bool showGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = shortest * 0.065;
    final cornerRadius = Radius.circular(shortest * 0.12);
    final left = size.width * 0.1;
    final right = size.width * 0.9;
    final top = size.height * 0.1;
    final bottom = size.height * 0.9;
    final span = shortest * 0.2;

    if (showGlow) {
      final glowPaint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
        ..color = glowColor;
      canvas.drawCircle(center, shortest * 0.22, glowPaint);
    }

    final framePaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final framePath = Path()
      ..moveTo(left + span, top)
      ..lineTo(left + cornerRadius.x, top)
      ..arcToPoint(Offset(left, top + cornerRadius.y), radius: cornerRadius)
      ..lineTo(left, top + span)
      ..moveTo(right - span, top)
      ..lineTo(right - cornerRadius.x, top)
      ..arcToPoint(Offset(right, top + cornerRadius.y), radius: cornerRadius)
      ..lineTo(right, top + span)
      ..moveTo(left, bottom - span)
      ..lineTo(left, bottom - cornerRadius.y)
      ..arcToPoint(Offset(left + cornerRadius.x, bottom), radius: cornerRadius)
      ..lineTo(left + span, bottom)
      ..moveTo(right, bottom - span)
      ..lineTo(right, bottom - cornerRadius.y)
      ..arcToPoint(Offset(right - cornerRadius.x, bottom), radius: cornerRadius)
      ..lineTo(right - span, bottom);
    canvas.drawPath(framePath, framePaint);

    final eggRect = Rect.fromCenter(
      center: center.translate(0, shortest * 0.02),
      width: shortest * 0.35,
      height: shortest * 0.5,
    );

    final eggPath = Path()
      ..moveTo(eggRect.center.dx, eggRect.top)
      ..cubicTo(
        eggRect.right,
        eggRect.top + eggRect.height * 0.12,
        eggRect.right,
        eggRect.bottom - eggRect.height * 0.18,
        eggRect.center.dx,
        eggRect.bottom,
      )
      ..cubicTo(
        eggRect.left,
        eggRect.bottom - eggRect.height * 0.18,
        eggRect.left,
        eggRect.top + eggRect.height * 0.12,
        eggRect.center.dx,
        eggRect.top,
      );

    final eggShadow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = Colors.black.withValues(alpha: 0.08);
    canvas.save();
    canvas.translate(0, shortest * 0.015);
    canvas.drawPath(eggPath, eggShadow);
    canvas.restore();

    final eggPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          shellColor,
          Color.lerp(shellColor, AppColors.eggshell100, 0.35) ?? shellColor,
        ],
      ).createShader(eggRect);
    canvas.drawPath(eggPath, eggPaint);

    final yolkRect = Rect.fromCircle(
      center: center.translate(0, shortest * 0.12),
      radius: shortest * 0.11,
    );
    final yolkPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(yolkColor, Colors.white, 0.12) ?? yolkColor,
          yolkColor,
        ],
      ).createShader(yolkRect);
    canvas.drawCircle(yolkRect.center, yolkRect.width / 2, yolkPaint);
  }

  @override
  bool shouldRepaint(covariant _BrandLogoPainter oldDelegate) {
    return frameColor != oldDelegate.frameColor ||
        shellColor != oldDelegate.shellColor ||
        yolkColor != oldDelegate.yolkColor ||
        glowColor != oldDelegate.glowColor ||
        showGlow != oldDelegate.showGlow;
  }
}

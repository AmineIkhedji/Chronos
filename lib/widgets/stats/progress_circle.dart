// lib/widgets/stats/progress_circle.dart
import 'dart:math';
import 'package:flutter/material.dart';

class ProgressCircle extends StatelessWidget {
  final double progress; // 0.0 à 1.0
  final double size;
  final Color color;
  final Color? trackColor;
  final Widget? centerChild;

  const ProgressCircle({
    super.key,
    required this.progress,
    required this.size,
    required this.color,
    this.trackColor,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTrackColor = trackColor ?? color.withValues(alpha: 0.15);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Piste de fond
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: 1.0,
              color: effectiveTrackColor,
              strokeWidth: size * 0.08,
            ),
          ),
          // Progression
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              strokeWidth: size * 0.08,
              startAngle: -pi / 2,
            ),
          ),
          // Contenu central
          if (centerChild != null) Center(child: centerChild),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double startAngle;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.startAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(rect, startAngle, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

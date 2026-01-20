import 'package:flutter/material.dart';

enum BorderType {
  rect,
  rRect,
  oval,
}

class CustomDottedBorder extends StatelessWidget {
  final Color color;
  final BorderType borderType;
  final Radius radius;
  final EdgeInsets padding;
  final Widget child;

  const CustomDottedBorder({
    super.key,
    required this.color,
    this.borderType = BorderType.rRect,
    this.radius = const Radius.circular(8),
    this.padding = const EdgeInsets.all(6),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        color: color,
        borderType: borderType,
        radius: radius,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final BorderType borderType;
  final Radius radius;

  _DottedBorderPainter({
    required this.color,
    required this.borderType,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 1.5;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final adjustedRect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final path = Path();

    switch (borderType) {
      case BorderType.rect:
        path.addRect(adjustedRect);
        break;
      case BorderType.rRect:
        path.addRRect(RRect.fromRectAndRadius(adjustedRect, radius));
        break;
      case BorderType.oval:
        path.addOval(adjustedRect);
        break;
    }

    final dashPath = Path();
    const dashWidth = 4.0;
    const dashSpace = 4.0;

    for (final pathMetric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < pathMetric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(
          pathMetric.extractPath(distance, next),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint if color or size changes
  }
}

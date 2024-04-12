import 'dart:math';

import 'package:flutter/material.dart';

class CustomBorderContainer extends StatelessWidget {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double distance;

  CustomBorderContainer({
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: 130,
        height: 130,
        
        child: CustomPaint(foregroundPainter: CircleBlurPainter(circleWidth: 30, blurSigma: 10.0, distance: distance))
      ),
    );
  }
}

class CircleBlurPainter extends CustomPainter {
  CircleBlurPainter(
      {required this.circleWidth,
      required this.blurSigma,
      required this.distance});

  double circleWidth;
  double blurSigma;
  double distance;

// TODO increase distance
  // max Distance for orange
  double maxDistance = 1;
  // min distance for red
  double minDistance = 0.5;

  checkColor() {
    if (distance <= minDistance) {
      return Color.fromARGB(144, 253, 85, 73);
    } else if (distance <= maxDistance) {
      return Color.fromARGB(204, 255, 169, 41);
    } else {
      return Colors.transparent;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = checkColor()
      // ..strokeCap = StrokeCap.round
      // ..style = PaintingStyle.stroke
      ..strokeWidth = circleWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

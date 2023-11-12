import 'package:flutter/cupertino.dart';

class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    required this.size,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    this.strokeWidth = 1,
  });
  final Size size;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: DashedLinePainter(dashWidth: dashWidth, dashSpace: dashSpace, color: color),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    this.strokeWidth = 1,
  });
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final double strokeWidth;
  @override
  void paint(Canvas canvas, Size size) {
    double start = 0.0;
    double center;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    if (size.height > size.width) {
      /// Draw vertical line
      while (start < size.height) {
        center = size.width / 2;
        canvas.drawLine(Offset(center, start), Offset(center, start + dashWidth), paint);
        start += dashWidth + dashSpace;
      }
    } else {
      /// Draw horizontal line
      while (start < size.width) {
        center = size.height / 2;
        canvas.drawLine(Offset(start, center), Offset(start + dashWidth, center), paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

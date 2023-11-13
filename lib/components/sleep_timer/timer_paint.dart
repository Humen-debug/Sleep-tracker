import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/image.dart';
import 'package:sleep_tracker/utils/style.dart';

/// [reversed] is for the clock drawing in anti-clockwise way.
/// In default, [progress] in [reversed] means it has been already minus 1.
class TimerPaint extends StatelessWidget {
  const TimerPaint({
    Key? key,
    this.canvasSize,
    this.radius = 100,
    required this.progress,
    this.backgroundColor,
    this.activeColor,
    this.strokeWidth = 40,
    this.reversed = false,
    this.showIndicator = true,
  })  : assert(radius >= strokeWidth, 'strokeWidth $strokeWidth should be smaller than radius $radius'),
        super(key: key);

  /// [canvasSize] determines the size of widget.
  ///
  /// In default, it is the same as the diameter by the provided [radius]
  final Size? canvasSize;

  /// [radius] determines the size of outmost circle.
  final double radius;

  /// [progress] determines the active arc.
  ///
  /// It only accepts 0 - 1;
  final double progress;

  /// [strokeWidth] determines the border width of outmost circle.
  final double strokeWidth;

  /// [backgroundColor] determines the color of circle.
  final Color? backgroundColor;

  /// [activeColor] determines the color of active arc.
  final Color? activeColor;
  final bool reversed;

  /// [showIndicator] determines whether showing the arrow on the active arc.
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: showIndicator
            ? loadImage(
                '<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="m20.001 12 12 12 -12 12V12Z" fill="#E0E2D5"/><path fill-rule="evenodd" clip-rule="evenodd" d="M18.468 8.304a3.999 3.999 0 0 1 4.359 0.87l12 12a3.996 3.996 0 0 1 0 5.655l-12 12A3.999 3.999 0 0 1 15.999 36V12c0 -1.62 0.975 -3.075 2.469 -3.696ZM24 21.66v4.686l2.343 -2.34L24 21.654Z" fill="#E0E2D5"/></svg>',
                48,
              )
            : null,
        builder: (BuildContext context, AsyncSnapshot<ui.Image?> snapshot) {
          return CustomPaint(
            size: canvasSize ?? Size.square(radius * 2 + strokeWidth),
            painter: _TimerPainter(
                progress: progress,
                backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.tertiary,
                activeColor: activeColor ?? Style.highlightGold,
                strokeWidth: strokeWidth,
                radius: radius,
                indicatorIcon: showIndicator ? snapshot.data : null,
                reversed: reversed,
                indicatorSize: 12),
          );
        });
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.activeColor,
    this.strokeWidth = 40,
    this.radius = 100,
    required this.indicatorSize,
    this.indicatorIcon,
    this.reversed = false,
  });

  /// It is a 0 - 1 range double
  final double progress;
  final double strokeWidth;
  final double radius;
  final Color backgroundColor;
  final Color activeColor;
  final ui.Image? indicatorIcon;
  final double indicatorSize;
  final bool reversed;

  late double capSize = strokeWidth / 2;

  void paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    Offset center = Offset(radius + capSize, radius + capSize);
    canvas.drawCircle(center, radius, paint);
  }

  void paintProgress(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = activeColor;

    // double capToDegree = capSize / radius;

    double startAngle = _degreeToRad(270);
    double sweepAngle = (_degreeToRad(360)) * progress;
    if (reversed) {
      startAngle = (_degreeToRad(360) * (1 - progress)) - _degreeToRad(90);
      sweepAngle = _degreeToRad(270) - startAngle;
    }

    Rect rect = Offset(capSize, capSize) & Size(radius * 2, radius * 2);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void paintIndicator(Canvas canvas, Size size) {
    if (indicatorIcon == null) return;

    final Offset centerOffset = Offset(radius + capSize, radius + capSize);

    double radian = (_degreeToRad(360)) * (reversed ? (1 - progress) : (progress));

    // translate the canvas to the center of chart
    canvas
      ..save()
      ..translate(centerOffset.dx, centerOffset.dy);

    final x = math.sin(radian) * radius;
    final y = math.cos(radian) * radius;
    final offset = Offset(x, -y);
    Rect rect = Rect.fromCircle(center: offset, radius: indicatorSize);

    // Rect rect = offset & Size(indicatorSize * 2, indicatorSize * 2);
    paintImage(
      canvas: canvas,
      rect: rect,
      image: rotatedImage(radian, indicatorIcon!),
      filterQuality: FilterQuality.high,
      fit: BoxFit.contain,
    );

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);
    paintProgress(canvas, size);
    if (progress > 0) paintIndicator(canvas, size);
  }

  double _degreeToRad(double degree) => degree * math.pi / 180;

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) => oldDelegate.progress != progress;
}

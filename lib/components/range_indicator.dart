import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/image.dart';
import 'package:sleep_tracker/utils/style.dart';

/// [RangeIndicator] renders box-plot alike chart.
///
/// It takes the [max], [min] as its bar limitation;
/// [upperLimit] and [lowerLimit] as its highlighted area; and
/// [value] to its indicator.
class RangeIndicator extends StatelessWidget {
  const RangeIndicator({
    super.key,
    required this.value,
    required this.max,
    required this.min,
    required this.upperLimit,
    required this.lowerLimit,
    this.size = const Size(12, 72),
    this.canvasSize,
    this.backgroundColor = Style.highlightDarkPurple,
    this.highlightColor = Style.highlightPurple,
    this.indicatorColor = Style.grey1,
  })  : assert(min < max, 'min $min must be smaller than max $max.'),
        assert(value >= min, 'value $value must be equal to or larger than min $min.'),
        assert(value <= max, 'value $value must be equal to or smaller than max $max.'),
        assert(lowerLimit >= min, 'lowerLimit $lowerLimit must be equal to or larger than min $min.'),
        assert(upperLimit <= max, 'upperLimit $upperLimit must be equal to or smaller than max $max.'),
        assert(lowerLimit <= upperLimit,
            'lowerLimit $lowerLimit must be equal to or smaller than upperLimit $upperLimit.');

  /// [value] determines the position of indicator.
  final double value;

  /// [max] is the maximum value of the range
  final double max;

  /// [min] is the minium value of the range
  final double min;

  /// [upperLimit] is the upper limit of the recommended range.
  /// It determines the top position in vertical or
  /// left-most position in horizontal of the highlighted range.
  final double upperLimit;

  /// [upperLimit] is the lower limit of the recommended range.
  /// It determines the bottom position in vertical or
  /// right-most position in horizontal of the highlighted range.
  final double lowerLimit;

  /// [size] determines the bar rendering size.
  ///
  /// If width of [size] is longer than length, the bar will be drawn in horizontal.
  /// Otherwise, it will be drawn in vertical.
  final Size size;

  /// [backgroundColor] determines the background color of the bar.
  final Color backgroundColor;

  /// [highlightColor] determines the color of recommended range.
  final Color highlightColor;

  /// [indicatorColor] determines the color of indicator.
  final Color indicatorColor;

  /// [canvasSize] determines the size of whole widget.
  /// In default, it equals to the size.
  ///
  final Size? canvasSize;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadImage(
            '<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="m20.001 12 12 12 -12 12V12Z" fill="#E0E2D5"/><path fill-rule="evenodd" clip-rule="evenodd" d="M18.468 8.304a3.999 3.999 0 0 1 4.359 0.87l12 12a3.996 3.996 0 0 1 0 5.655l-12 12A3.999 3.999 0 0 1 15.999 36V12c0 -1.62 0.975 -3.075 2.469 -3.696ZM24 21.66v4.686l2.343 -2.34L24 21.654Z" fill="#E0E2D5"/></svg>',
            48),
        builder: (context, snapshot) {
          return CustomPaint(
            size: canvasSize ?? size,
            painter: _RangeIndicatorPainter(
              value: value,
              max: max,
              min: min,
              upperLimit: upperLimit,
              lowerLimit: lowerLimit,
              barSize: size,
              backgroundColor: backgroundColor,
              highlightColor: highlightColor,
              indicatorColor: indicatorColor,
              indicatorIcon: snapshot.data,
              indicatorSize: 24.0,
            ),
          );
        });
  }
}

class _RangeIndicatorPainter extends CustomPainter {
  _RangeIndicatorPainter({
    required this.value,
    required this.max,
    required this.min,
    required this.upperLimit,
    required this.lowerLimit,
    required this.barSize,
    required this.backgroundColor,
    required this.highlightColor,
    required this.indicatorColor,
    this.indicatorIcon,
    this.indicatorSize = 12.0,
  });

  /// [value] determines the position of indicator.
  final double value;

  /// [max] is the maximum value of the range
  final double max;

  /// [min] is the minium value of the range
  final double min;

  /// [upperLimit] is the upper limit of the recommended range.
  /// It determines the top position in vertical or
  /// left-most position in horizontal of the highlighted range.
  final double upperLimit;

  /// [upperLimit] is the lower limit of the recommended range.
  /// It determines the bottom position in vertical or
  /// right-most position in horizontal of the highlighted range.
  final double lowerLimit;

  /// [barSize] determines the bar rendering size.
  ///
  /// If width of [barSize] is longer than length, the bar will be drawn in horizontal.
  /// Otherwise, it will be drawn in vertical.
  final Size barSize;

  /// [backgroundColor] determines the background color of the bar.
  final Color backgroundColor;

  /// [highlightColor] determines the color of recommended range.
  final Color highlightColor;

  /// [indicatorColor] determines the color of indicator.
  final Color indicatorColor;

  final ui.Image? indicatorIcon;
  final double indicatorSize;

  late final bool _isHorizontal = barSize.width >= barSize.height;
  late final double _longestSize = barSize.longestSide;
  late final double _shortestSize = barSize.shortestSide;

  void paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = _shortestSize
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    Offset start;
    Offset end;
    if (_isHorizontal) {
      final startX = size.width - _longestSize;
      final endX = startX + _longestSize;
      final centerY = size.height / 2;
      start = Offset(startX, centerY);
      end = Offset(endX, centerY);
    } else {
      final startY = size.height - _longestSize;
      final endY = startY + _longestSize;
      final centerX = size.width / 2;
      start = Offset(centerX, startY);
      end = Offset(centerX, endY);
    }
    canvas.drawLine(start, end, paint);
  }

  void paintRange(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = _shortestSize
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..color = highlightColor;
    Offset start;
    Offset end;
    // the delta width/height of highlight range;
    double delta = _longestSize * _percent(upperLimit - lowerLimit);
    if (_isHorizontal) {
      final startX = size.width + (_percent(lowerLimit) - 1) * _longestSize;
      final endX = startX + delta;

      final centerY = size.height / 2;
      start = Offset(startX, centerY);
      end = Offset(endX, centerY);
    } else {
      final startY = size.height + (_percent(max - upperLimit) - 1) * _longestSize;
      final endY = startY + delta;

      final centerX = size.width / 2;
      start = Offset(centerX, startY);
      end = Offset(centerX, endY);
    }
    canvas.drawLine(start, end, paint);
  }

  void paintIndicator(Canvas canvas, Size size) {
    if (indicatorIcon == null) return;

    // offset of the indicator so that the indicator can be drawn nearer to
    // the bar.
    final double offset = indicatorSize / 1.5;

    final double left = _isHorizontal
        ? (size.width + (_percent(value) - 1) * _longestSize) - indicatorSize / 2
        : ((size.width - _shortestSize) / 2 - offset);
    final double top = _isHorizontal
        ? (size.height - _shortestSize) / 2 - offset
        : size.height + (_percent(max - value) - 1) * _longestSize - indicatorSize / 2;
    final Rect rect = Rect.fromLTWH(left, top, indicatorSize, indicatorSize);

    ui.Image image = indicatorIcon!;
    // rotate 90 degree
    if (_isHorizontal) {
      image = rotatedImage(degreeToRadian(90), image);
    }
    paintImage(canvas: canvas, rect: rect, image: image, filterQuality: FilterQuality.high, fit: BoxFit.contain);
  }

  double _percent(double value) => (value - min) / (max - min);

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);
    paintRange(canvas, size);
    paintIndicator(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _RangeIndicatorPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.indicatorIcon != indicatorIcon;
}

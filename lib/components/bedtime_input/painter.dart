import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sleep_tracker/components/bedtime_input/utils.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/image.dart';

import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

const double _iconButtonSpacing = Style.spacingXs;
const double _iconSize = 16.0;
const double _buttonSize = _iconSize + _iconButtonSpacing * 2;
const double _minutesInDay = 24 * 60;

class BedtimeInputPaint extends StatefulWidget {
  BedtimeInputPaint({
    super.key,
    required DateTimeRange initialRange,
    this.radius = 131.5,
    this.strokeWidth = 12.0,
    this.backgroundColor,
    this.gradientColors,
    this.graduationColor,
    Size? canvasSize,
    required this.onChanged,
  })  : initialRange = DateTimeRange(
          start: DateUtils.dateOnly(initialRange.start).copyWith(
            hour: initialRange.start.hour,
            minute: initialRange.start.minute,
          ),
          end: DateUtils.dateOnly(initialRange.end).copyWith(
            hour: initialRange.end.hour,
            minute: initialRange.end.minute,
          ),
        ),
        canvasSize = canvasSize ?? Size.square(radius * 2) {
    assert(this.initialRange.duration.inMinutes < 24 * 60,
        'initialRange\'s duration ${initialRange.duration} must be smaller than the duration of one day.');
  }

  /// [initialRange] determines the initial position of two input buttons.
  final DateTimeRange initialRange;

  /// [radius] determines the size of outmost circle.
  final double radius;

  /// [strokeWidth] determines the border width of outmost circle.
  final double strokeWidth;

  /// [backgroundColor] determines the color of circle.
  final Color? backgroundColor;

  /// [gradientColors] determines the colors of selection arc
  final List<Color>? gradientColors;

  /// [graduationColor] determines the color of lines that represents
  /// each hour on clock.
  ///
  /// The color of other graduations that represents every 12 minutes equals
  /// [graduationColor] with opacity of 0.5.
  final Color? graduationColor;

  /// [canvasSize] determines the size of widget.
  ///
  /// In default, it is the same as the diameter by the provided [radius]
  final Size canvasSize;

  final ValueChanged<DateTimeRange> onChanged;

  @override
  State<BedtimeInputPaint> createState() => _BedtimeInputPaintState();
}

class _BedtimeInputPaintState extends State<BedtimeInputPaint> {
  /// [_canvasKey] is used to obtain the local positions of buttons based on the
  /// canvas size.
  final GlobalKey _canvasKey = GlobalKey();
  late final Offset _center = Offset(
    math.min(widget.canvasSize.width, widget.radius * 2) / 2,
    math.min(widget.canvasSize.height, widget.radius * 2) / 2,
  );
  // late DateTimeRange _selectedRange = widget.initialRange;
  late DateTime _selectedStart = widget.initialRange.start;
  late DateTime _selectedEnd = widget.initialRange.end;
  late final DateTime _startTime = DateUtils.dateOnly(widget.initialRange.start);

  bool _isSelectingStart = false;
  bool _isSelectingEnd = false;

  void _handleDragToDateTime(DragUpdateDetails details) {
    final RenderBox? box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset localPos = box.globalToLocal(details.globalPosition);
    // It starts at the 90 degree, just like the Flutter's canvas [drawArc].
    // So, it needs to be added 90 degree
    final double radian = math.atan2(localPos.dy - _center.dy, localPos.dx - _center.dx) + degreeToRadian(90);
    double degree = radian * 180 / math.pi;
    if (degree < 0.0) degree += 360;
    final double percent = degree / 360.0;

    const int minuteFactor = 5;
    final int delta = roundUp(_minutesInDay * percent, minuteFactor);

    setState(() {
      DateTime start = _selectedStart;
      DateTime end = _selectedEnd;
      if (_isSelectingStart) {
        start = _startTime.add(Duration(minutes: delta));

        if (DateTimeUtils.isAtSameMomentAs(start, end)) {
          start = start.subtract(const Duration(minutes: minuteFactor));
        }
      } else if (_isSelectingEnd) {
        end = _startTime.add(Duration(minutes: delta));
        if (DateTimeUtils.isAtSameMomentAs(start, end)) {
          end = end.subtract(const Duration(minutes: minuteFactor));
        }
      }
      // If the duration between start and end is larger than a day,
      if (end.difference(start).inMinutes > _minutesInDay) {
        // Subtract end by a day.
        end = end.subtract(const Duration(days: 1));
      }
      // Ensure end is after start.
      if (!end.isAfter(start)) {
        end = end.add(const Duration(days: 1));
      }

      if (!_selectedEnd.isAtSameMomentAs(end)) _selectedEnd = end;
      if (!_selectedStart.isAtSameMomentAs(start)) _selectedStart = start;
    });
  }

  Widget _buildButton(DateTime time, bool isStart) {
    final String iconAssetName = isStart ? 'moon' : 'sun-fog';

    final Duration diff = time.difference(_startTime);
    final double radian = degreeToRadian(360 * (diff.inMinutes / _minutesInDay));

    final x = math.sin(radian) * (widget.radius);
    final y = math.cos(radian) * (widget.radius);
    final offsetDiff = Offset(x, -y);
    const buttonOffset = Offset(_buttonSize / 2, _buttonSize / 2);
    final offset = _center + offsetDiff - buttonOffset;

    void handleTriggerStart([Object? details]) {
      setState(() {
        _isSelectingStart = isStart;
        _isSelectingEnd = !isStart;
      });
    }

    void handleTriggerEnd([Object? details]) {
      setState(() {
        _isSelectingStart = false;
        _isSelectingEnd = false;
      });

      widget.onChanged(DateTimeRange(start: _selectedStart, end: _selectedEnd));
    }

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTapDown: handleTriggerStart,
        onTapUp: handleTriggerEnd,
        onPanStart: handleTriggerStart,
        onPanUpdate: _handleDragToDateTime,
        onPanEnd: handleTriggerEnd,
        child: Container(
          padding: const EdgeInsets.all(_iconButtonSpacing),
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
          child: SvgPicture.asset('assets/icons/$iconAssetName.svg',
              color: Style.grey1, width: _iconSize, height: _iconSize),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _canvasKey,
      constraints: BoxConstraints(maxWidth: widget.canvasSize.width, maxHeight: widget.canvasSize.height),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/moon.svg',
                      color: Theme.of(context).primaryColor,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: Style.spacingXxs),
                    Text(DateFormat.Hm().format(_selectedStart), style: dataTextTheme.headlineMedium)
                  ],
                ),
                const SizedBox(height: Style.spacingXl),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/sun-fog.svg',
                      color: Theme.of(context).primaryColor,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: Style.spacingXxs),
                    Text(DateFormat.Hm().format(_selectedEnd), style: dataTextTheme.headlineMedium)
                  ],
                )
              ],
            ),
          ),
          CustomPaint(
            size: widget.canvasSize,
            painter: _TimerPainter(
              selectedRange: DateTimeRange(start: _selectedStart, end: _selectedEnd),
              radius: widget.radius,
              strokeWidth: widget.strokeWidth,
              backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.tertiary,
              graduationColor: widget.graduationColor ?? Style.grey3,
              gradientColors: widget.gradientColors ?? [Theme.of(context).primaryColor, Style.highlightGold],
              circleSpacing: 24.0,
              graduationLength: 5.0,
            ),
          ),
          // bedtime (start)
          _buildButton(_selectedStart, true),
          // bedtime (end)
          _buildButton(_selectedEnd, false)
        ],
      ),
    );
  }
}

/// [_TimerPainter] renders a timer with [selectedRange] as the highlighted arc and
/// 24-hour graduations with 12 minutes as every slot.
class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.selectedRange,
    required this.radius,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.gradientColors,
    required this.graduationColor,
    required this.circleSpacing,
    required this.graduationLength,
    this.graduationTextStyle,
  });

  /// [selectedRange] determines the initial position of two input buttons.
  final DateTimeRange selectedRange;

  /// [radius] determines the size of outmost circle.
  final double radius;

  /// [circleSpacing] determines the spacing between outmost circle and
  /// the inner circle that holds the graduations.
  final double circleSpacing;

  /// [graduationLength] determines the rendering length of graduation.
  final double graduationLength;

  final TextStyle? graduationTextStyle;

  /// [strokeWidth] determines the border width of outmost circle.
  final double strokeWidth;

  /// [backgroundColor] determines the color of circle.
  final Color backgroundColor;

  /// [gradientColors] determines the colors of selection arc
  final List<Color> gradientColors;

  /// [graduationColor] determines the color of lines that represents
  /// each hour on clock.
  ///
  /// The color of other graduations that represents every 12 minutes equals
  /// [graduationColor] with opacity of 0.35.
  final Color graduationColor;

  late final DateTime _startTime = DateUtils.dateOnly(selectedRange.start);
  // late final DateTime _endTime = DateUtils.dateOnly(selectedRange.start.add(const Duration(days: 1)));

  void paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;
    final Offset c = Offset(math.min(size.width, radius * 2) / 2, math.min(size.height, radius * 2) / 2);
    canvas.drawCircle(c, radius, paint);
  }

  void paintSelectedArc(Canvas canvas, Size size) {
    final Offset center = Offset(math.min(size.width, radius * 2) / 2, math.min(size.height, radius * 2) / 2);
    final Duration diff = selectedRange.start.difference(_startTime);
    final double startAngle = degreeToRadian(270) + degreeToRadian(360) * (diff.inMinutes / _minutesInDay);
    final double duration = (selectedRange.duration.inMinutes / _minutesInDay) % 1;
    final double sweepAngle = degreeToRadian(360) * duration;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.sweep(
        center,
        gradientColors,
        List<double>.generate(
            gradientColors.length, (index) => index == 0 ? index.toDouble() : (index + 1) / gradientColors.length),
        TileMode.mirror,
        startAngle,
        startAngle + sweepAngle,
      );

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void paintGraduations(Canvas canvas, Size size) {
    // hour paint
    final Paint hourPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..color = graduationColor;

    // 12 minutes paint
    final Paint minutePaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..color = graduationColor.withOpacity(0.35);

    final double centerX = math.min(size.width, radius * 2) / 2;
    final double centerY = math.min(size.height, radius * 2) / 2;

    final double centerSpaceRadius = radius - circleSpacing;

    const int numberOfDots = 120;
    final double radiantStep = degreeToRadian(360) / numberOfDots;
    // Draw graduations from bottom to right in anti-clockwise.
    // That is in order of 6 -> 3 -> 12 -> 9 on a clock.
    for (int i = 0; i < numberOfDots; i++) {
      final double step = i * radiantStep;
      final double radianX = math.sin(step);
      final double radianY = math.cos(step);
      final p1 = Offset(centerX + radianX * centerSpaceRadius, centerY + radianY * centerSpaceRadius);
      final p2 = Offset(
        centerX + radianX * (centerSpaceRadius - graduationLength),
        centerY + radianY * (centerSpaceRadius - graduationLength),
      );
      if (i % 30 == 0) {
        // Draw hour on canvas.

        final TextStyle textStyle = graduationTextStyle ?? TextStyle(fontSize: 14, color: graduationColor);
        final fontSize = textStyle.fontSize ?? 14.0;
        final double textScale = fontSize / 14.0;
        double size = 24.0 * textScale;

        final textPainter = TextPainter(
          text: TextSpan(text: ((24 - i ~/ 5 + 12) % 24).toString(), style: textStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(minWidth: size, maxWidth: size);

        textPainter.paint(canvas, Offset(p1.dx - size / 2, p1.dy - fontSize / 2));
      } else if (i % 5 == 0) {
        canvas.drawLine(p1, p2, hourPaint);
      } else {
        canvas.drawLine(p1, p2, minutePaint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintBackground(canvas, size);
    paintGraduations(canvas, size);
    paintSelectedArc(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.selectedRange.start != selectedRange.start || oldDelegate.selectedRange.end != selectedRange.end;
  }
}

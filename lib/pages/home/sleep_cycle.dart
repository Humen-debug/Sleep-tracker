import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/components/period_picker/period_picker.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sleep_tracker/utils/num.dart';

import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/components/charts/line_chart.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/components/sleep_timer.dart';
import 'package:sleep_tracker/providers/sleep_records_provider.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

@RoutePage()
class SleepCyclePage extends ConsumerStatefulWidget {
  const SleepCyclePage({super.key});

  @override
  ConsumerState<SleepCyclePage> createState() => _SleepCyclePageState();
}

// context.pushRoute<DateTimeRange?>(const EnterBedtimeRoute());
class _SleepCyclePageState extends ConsumerState<SleepCyclePage> {
  late DateTime _firstDate;
  late final DateTime _lastDate;
  late DateTimeRange selectedRange;
  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime first = ref.read(authStateProvider).sleepRecords.firstOrNull?.start ?? now;
    final DateTime last = ref.read(authStateProvider).sleepRecords.lastOrNull?.start ?? now;

    _firstDate = DateTimeUtils.mostRecentWeekday(first, 0);
    _lastDate = DateTimeUtils.mostNearestWeekday(last, 6);
    selectedRange =
        DateTimeRange(start: DateTimeUtils.mostRecentWeekday(now, 0), end: DateTimeUtils.mostNearestWeekday(now, 6));

    _dayIndex = now.difference(selectedRange.start).inDays;
  }

  bool get _isDisplayingFirstDate => !selectedRange.start.isAfter(_firstDate);
  bool get _isDisplayingLastDate => !selectedRange.end.isBefore(_lastDate);

  void _handlePreviousWeek() {
    DateTimeRange range = DateTimeUtils.shiftDaysToRange(selectedRange, -DateTime.daysPerWeek);
    if (range.end.isAfter(_lastDate)) {
      return;
    }
    setState(() => selectedRange = range);
  }

  void _handleNextWeek() {
    DateTimeRange range = DateTimeUtils.shiftDaysToRange(selectedRange, DateTime.daysPerWeek);

    if (range.end.isAfter(_lastDate)) {
      return;
    }
    setState(() => selectedRange = range);
  }

  /// Returns the sleepRecords by given dayIndex.
  Iterable<SleepRecord> getDayRecords(int dayIndex) {
    final date = DateUtils.addDaysToDate(selectedRange.start, dayIndex);
    return ref.watch(daySleepRecordsProvider(date));
  }

  Widget _buildWeekdayButton(int index) {
    final DateTime day = DateUtils.addDaysToDate(selectedRange.start, index);
    final Iterable<SleepRecord> dayRecords = getDayRecords(index);
    final DateTime now = DateTime.now();

    final double totalSleepSeconds = dayRecords.fold(0.0, (previousValue, record) {
      final DateTime? wakeUpAt = record.wakeUpAt;
      final DateTime start = record.start;
      DateTime end = record.end;
      end = wakeUpAt ?? (end.isAfter(now) ? now : end);
      return previousValue + end.difference(start).inSeconds;
    });

    final double progress = math.min(totalSleepSeconds / (24 * 3600), 1.0);
    final bool isDisabled = !(now.isAfter(day));
    final bool isSelected = _dayIndex == index;
    final ThemeData themeData = Theme.of(context);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() => _dayIndex = index);
            },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              DateFormat.E().format(day).substring(0, 1),
              style: themeData.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? themeData.colorScheme.onSurface : themeData.colorScheme.secondary),
            ),
          ),
          TimerPaint(progress: progress, radius: 16.0, strokeWidth: 8, showIndicator: false),
        ],
      ),
    );
  }

  final Color awakeColor = Style.highlightGold;
  late final Color asleepColor = Theme.of(context).primaryColor;
  final Color deepSleepColor = Style.highlightPurple;

  @override
  Widget build(BuildContext context) {
    final List<Point<DateTime, double>> sleepEventType = [];
    final Iterable<SleepRecord> records = getDayRecords(_dayIndex);
    final sleepEvents = records.expand((record) => record.events);
    final List<DateTimeRange> slots = records
        .where((record) => record.wakeUpAt != null)
        .map((record) => DateTimeRange(start: record.start, end: record.wakeUpAt!))
        .toList();
    final DateTime? end = sleepEvents.lastOrNull?.time;
    Duration interval = const Duration(minutes: 5);
    if (end != null) {
      DateTime start = sleepEvents.first.time;
      if (end.difference(start).inHours > 6) {
        interval = const Duration(hours: 1);
      } else if (end.difference(start).inHours > 2) {
        interval = const Duration(minutes: 30);
      } else if (end.difference(start).inMinutes > 59) {
        interval = const Duration(minutes: 15);
      }

      /// Returns sleep events for every record. Only return event per 30 minutes so that the
      /// line chart is not packed with data.
      for (start; true; start = start.add(interval)) {
        if (start.isAfter(end)) break;
        final next = start.add(interval);
        final events = sleepEvents
            .skipWhile((event) => event.time.isBefore(start))
            .takeWhile((event) => !event.time.isAfter(next));
        SleepType type =
            sleepEvents.any((event) => !start.isBefore(event.time)) ? SleepType.deepSleep : SleepType.awaken;
        double meanType = type.value.toDouble();

        if (events.isNotEmpty) {
          meanType = events.map((e) => e.type.value).average;
        }
        sleepEventType.add(Point(start, meanType));
      }
    }

    final DateTime? earliest = records.firstOrNull?.start;

    double awakenMinutes = 0.0;
    double deepSleepMinutes = 0.0;

    for (int i = 0; i < sleepEvents.length - 1; i++) {
      final log = sleepEvents.elementAt(i);
      final nextLog = sleepEvents.elementAt(i + 1);
      final time = nextLog.time.difference(log.time).inMilliseconds / (60 * 1000);
      // According to our sleep-wake classification algorithm, type is divided into
      // SleepType.awaken and SleepType.deepSleep;
      if (log.type == SleepType.awaken) {
        awakenMinutes += time;
      } else if (log.type == SleepType.deepSleep) {
        deepSleepMinutes += time;
      }
    }

    if (sleepEvents.isNotEmpty) {
      final last = sleepEvents.last;
      final time = (records.last.wakeUpAt!.difference(last.time).inMilliseconds).abs() / (60 * 1000);
      if (last.type == SleepType.deepSleep) {
        deepSleepMinutes += time;
      }
    }
    double minutesInBed = slots.fold(0.0, (previousValue, slot) => previousValue + slot.duration.inMinutes);

    double sleepMinutes = minutesInBed - awakenMinutes - deepSleepMinutes;
    double asleepMinutes = minutesInBed - awakenMinutes;

    final double diameter = MediaQuery.of(context).size.width / 3;

    final periodPicker = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isDisplayingFirstDate ? null : _handlePreviousWeek,
          child: SvgPicture.asset('assets/icons/chevron-left.svg',
              color: _isDisplayingFirstDate ? Style.grey3 : Style.grey1),
        ),
        PeriodPicker(
          maxWidth: 100,
          mode: PeriodPickerMode.weeks,
          selectedRange: selectedRange,
          firstDate: _firstDate,
          lastDate: _lastDate,
          onDateChanged: (value) {
            if (value != null && value != selectedRange.start) {
              setState(() {
                selectedRange =
                    DateTimeRange(start: value, end: value.add(const Duration(days: DateTime.daysPerWeek - 1)));
              });
            }
          },
        ),
        GestureDetector(
          onTap: _isDisplayingLastDate ? null : _handleNextWeek,
          child: SvgPicture.asset('assets/icons/chevron-right.svg',
              color: _isDisplayingLastDate ? Style.grey3 : Style.grey1),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Cycle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  7,
                  (index) => Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text('${_firstDate.day + index}'),
                      )),
            ),
            const SizedBox(height: Style.spacingXs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(DateTime.daysPerWeek, _buildWeekdayButton),
            ),
            const SizedBox(height: Style.spacingMd),
            periodPicker,
            const SizedBox(height: Style.spacingMd),
            LineChart<DateTime, num>(
              data: sleepEventType,
              getSpot: (x, y) {
                final int min = earliest?.millisecondsSinceEpoch ?? 0;
                return Point((x.millisecondsSinceEpoch - min).toDouble(), y.toDouble());
              },
              gradientColors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.1),
              ],
              getYTitles: (value) {
                int index = value.round();

                if (index >= 9) {
                  return 'Awake';
                } else if (index == 3) {
                  return 'Sleep';
                } else if (index == 1) {
                  return 'Deep Sleep';
                }
                return '';
              },
              getXTitles: (value) {
                // value here is the difference of millisecondSinceEpoch between earliest and data.
                // Restore and return the millisecondSinceEpoch of data.
                final int milliSecond = value.toInt() + (earliest?.millisecondsSinceEpoch ?? 0);
                return DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(milliSecond));
              },
              getTooltipLabels: (x, y) {
                final int milliSecond = x.toInt() + (earliest?.millisecondsSinceEpoch ?? 0);
                final String time = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(milliSecond));
                int index = y.round();
                if (index >= 9) {
                  return '$time, Awake';
                } else if (index >= 2) {
                  return '$time, Sleep';
                } else {
                  return '$time, Deep Sleep';
                }
              },
              minY: 0,
              maxY: 9,
              chartHeight: 203,
              intervalY: 1.0,
              intervalX: interval.inMilliseconds.toDouble(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (records.isNotEmpty && records.last.wakeUpAt != null)
                            ? '${DateFormat.jm().format(records.first.start)} - ${DateFormat.jm().format(records.last.wakeUpAt!)}'
                            : 'No record found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Style.grey3),
                      ),
                      Text(
                        '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}min asleep',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sleep Efficiency',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Style.grey3),
                      ),
                      Text(
                        '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}min asleep',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size.fromRadius(diameter / 2),
                        painter: PercentagePainter(
                          radius: diameter / 2,
                          strokeWidth: 10,
                          asleepColor: asleepColor,
                          deepSleepColor: deepSleepColor,
                          awakeColor: awakeColor,
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          awake: awakenMinutes,
                          asleep: sleepMinutes,
                          deepSleep: asleepMinutes,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Total Time'),
                            const SizedBox(height: Style.spacingXxs),
                            Text(
                              "${minutesInBed ~/ 60 > 0 ? '${minutesInBed ~/ 60}hr ' : ''}${minutesInBed.remainder(60) > 0 ? '${minutesInBed.remainder(60).toInt()}min' : ''}",
                              style: dataTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: awakeColor),
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Awake",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
                              Text(
                                  '${awakenMinutes ~/ 60}hr ${awakenMinutes.remainder(60).toInt()}min (${NumFormat.toPercentWithTotal(awakenMinutes, minutesInBed)})',
                                  style: dataTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Style.spacingXs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: asleepColor),
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sleep",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
                              Text(
                                  '${sleepMinutes ~/ 60}hr ${sleepMinutes.remainder(60).toInt()}min (${NumFormat.toPercentWithTotal(sleepMinutes, minutesInBed)})',
                                  style: dataTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Style.spacingXs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: deepSleepColor),
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Deep Sleep",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
                              Text(
                                  '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}min (${NumFormat.toPercentWithTotal(deepSleepMinutes, minutesInBed)})',
                                  style: dataTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PercentagePainter extends CustomPainter {
  PercentagePainter({
    required this.radius,
    required this.strokeWidth,
    required this.asleepColor,
    required this.deepSleepColor,
    required this.awakeColor,
    required this.backgroundColor,
    required this.awake,
    required this.asleep,
    required this.deepSleep,
  });
  final double radius, strokeWidth, awake, asleep, deepSleep;
  final Color asleepColor, deepSleepColor, awakeColor, backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(math.min(size.width, radius * 2) / 2, math.min(size.height, radius * 2) / 2);
    final Rect container = Rect.fromCircle(center: c, radius: radius);

    final total = awake + asleep + deepSleep;

    if (total == 0) {
      paintBackground(canvas, size, container, backgroundColor, 0, math.pi * 2);
    } else {
      final awakeP = awake / total;
      final asleepP = asleep / total;
      final deepSleepP = deepSleep / total;
      paintBackground(canvas, size, container, awakeColor, 0, math.pi * 2 * awakeP);
      paintBackground(canvas, size, container, asleepColor, math.pi * 2 * awakeP, math.pi * 2 * asleepP);
      paintBackground(
          canvas, size, container, deepSleepColor, math.pi * 2 * (awakeP + asleepP), math.pi * 2 * deepSleepP);
    }
  }

  void paintBackground(Canvas canvas, Size size, Rect container, Color color, double startAngle, double endAngle) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..color = color;
    canvas.drawArc(container, startAngle - math.pi / 2, endAngle, false, paint);
  }

  @override
  bool shouldRepaint(PercentagePainter oldDelegate) =>
      oldDelegate.awake != awake || oldDelegate.deepSleep != deepSleep || oldDelegate.asleep != asleep;
}

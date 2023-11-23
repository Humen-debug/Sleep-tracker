import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _firstDate = DateTimeUtils.mostRecentWeekday(now, 0);
    _dayIndex = now.difference(_firstDate).inDays;
  }

  void _handleBack() {
    context.popRoute();
  }

  /// Returns the sleepRecords by given dayIndex.
  Iterable<SleepRecord> getDayRecords(int dayIndex) {
    final date = DateUtils.addDaysToDate(_firstDate, dayIndex);
    return ref.watch(daySleepRecordsProvider(date));
  }

  Widget _buildWeekdayButton(int index) {
    final DateTime day = DateUtils.addDaysToDate(_firstDate, index);
    final Iterable<SleepRecord> dayRecords = getDayRecords(index);
    final DateTime now = DateTime.now();

    final double totalSleepSeconds =
        dayRecords.fold(0.0, (previousValue, record) {
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
                  color: isSelected
                      ? themeData.colorScheme.onSurface
                      : themeData.colorScheme.secondary),
            ),
          ),
          TimerPaint(
              progress: progress,
              radius: 16.0,
              strokeWidth: 8,
              showIndicator: false),
        ],
      ),
    );
  }

  final Color awakeColor = Colors.orange;
  final Color asleepColor = Colors.lightBlueAccent;
  final Color deepSleepColor = Colors.purpleAccent;

  @override
  Widget build(BuildContext context) {
    final List<Point<DateTime, double>> sleepEventType = [];
    final Iterable<SleepRecord> records = getDayRecords(_dayIndex);
    final sleepEvents = records.expand((record) => record.events);
    final List<DateTimeRange> slots = records
        .map((record) =>
            DateTimeRange(start: record.start, end: record.wakeUpAt!))
        .toList();

    final DateTime? earliest = records.firstOrNull?.start;

    double awakenMinutes = 0.0;
    double deepSleepMinutes = 0.0;

    for (int i = 0; i < sleepEvents.length - 1; i++) {
      final log = sleepEvents.elementAt(i);
      final nextLog = sleepEvents.elementAt(i + 1);
      final time =
          nextLog.time.difference(log.time).inMilliseconds / (60 * 1000);
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
      final time =
          (records.last.wakeUpAt!.difference(last.time).inMilliseconds).abs() /
              (60 * 1000);
      if (last.type == SleepType.deepSleep) {
        deepSleepMinutes += time;
      }
    }
    double minutesInBed = slots.fold(
        0.0, (previousValue, slot) => previousValue + slot.duration.inMinutes);

    double sleepMinutes = minutesInBed - awakenMinutes - deepSleepMinutes;
    double asleepMinutes = minutesInBed - awakenMinutes;

    final double diameter = MediaQuery.of(context).size.width / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Cycle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _firstDate = _firstDate.add(const Duration(days: -7));
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_left)),
                  Container(
                    width: 120,
                    alignment: Alignment.center,
                    child: Text(
                        '${_firstDate.day}/${_firstDate.month} - ${_firstDate.add(const Duration(days: 7)).day}/${_firstDate.month}'),
                  ),
                  IconButton(
                      onPressed: _firstDate
                              .add(const Duration(days: 7))
                              .isBefore(DateTime.now())
                          ? () {
                              setState(() {
                                if (_firstDate
                                    .add(const Duration(days: 7))
                                    .isBefore(DateTime.now())) {
                                  _firstDate =
                                      _firstDate.add(const Duration(days: 7));
                                }
                              });
                            }
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_right)),
                ],
              ),
            ),
            const SizedBox(height: Style.spacingMd),
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
              children:
                  List.generate(DateTime.daysPerWeek, _buildWeekdayButton),
            ),
            const SizedBox(height: Style.spacingMd),
            const SizedBox(height: Style.spacingMd),
            LineChart<DateTime, num>(
              data: sleepEventType,
              getSpot: (x, y) {
                final int min = earliest?.millisecondsSinceEpoch ?? 0;
                return Point(
                    (x.millisecondsSinceEpoch - min).toDouble(), y.toDouble());
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
                final int milliSecond =
                    value.toInt() + (earliest?.millisecondsSinceEpoch ?? 0);
                return DateFormat.Hm()
                    .format(DateTime.fromMillisecondsSinceEpoch(milliSecond));
              },
              minY: 0,
              maxY: 9,
              chartHeight: 203,
              intervalY: 1.0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (records.isNotEmpty && records.last.wakeUpAt != null)
                            ? '${records.first.start}  ${records.last.wakeUpAt}'
                            : 'No record found',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Style.grey3),
                      ),
                      Text(
                          '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}min asleep',
                          style: dataTextTheme.bodyLarge),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sleep Efficiency',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Style.grey3),
                      ),
                      Text(
                          '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}min asleep',
                          style: dataTextTheme.bodyLarge),
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
                  CustomPaint(
                    // TODO
                    size: Size.fromRadius(diameter / 2),
                    painter: PercentagePainter(
                      radius: diameter / 2,
                      strokeWidth: 10,
                      asleepColor: asleepColor,
                      deepSleepColor: deepSleepColor,
                      awakeColor: awakeColor,
                      awakeP: awakenMinutes / minutesInBed,
                      asleepP: sleepMinutes / minutesInBed,
                      deepSleepP: asleepMinutes / minutesInBed,
                    ),
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
                          Text("\u2022",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(height: 0.6, color: awakeColor)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Awake",
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text(
                                  '${awakenMinutes ~/ 60}hr ${awakenMinutes.remainder(60).toInt()}(${(awakenMinutes / minutesInBed * 100).toStringAsFixed(0)}%)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("\u2022",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(height: 0.6, color: asleepColor)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sleep",
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text(
                                  '${sleepMinutes ~/ 60}hr ${sleepMinutes.remainder(60).toInt()}(${(sleepMinutes / minutesInBed * 100).toStringAsFixed(0)}%)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("\u2022",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                      height: 0.6, color: deepSleepColor)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Deep Sleep",
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text(
                                  '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}(${(asleepMinutes / minutesInBed * 100).toStringAsFixed(0)}%)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold))
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
    required this.awakeP,
    required this.asleepP,
    required this.deepSleepP,
  });
  double radius, strokeWidth, awakeP, asleepP, deepSleepP;
  final Color asleepColor, deepSleepColor, awakeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(math.min(size.width, radius * 2) / 2,
        math.min(size.height, radius * 2) / 2);
    final Rect container = Rect.fromCircle(center: c, radius: radius);

    paintBackground(
        canvas, size, container, awakeColor, 0, math.pi * 2 * awakeP);
    paintBackground(canvas, size, container, asleepColor, math.pi * 2 * awakeP,
        math.pi * 2 * asleepP);
    paintBackground(canvas, size, container, deepSleepColor,
        math.pi * 2 * (awakeP + asleepP), math.pi * 2 * deepSleepP);
  }

  void paintBackground(Canvas canvas, Size size, Rect container, Color color,
      double startAngle, double endAngle) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..color = color;
    canvas.drawArc(container, startAngle - math.pi / 2, endAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

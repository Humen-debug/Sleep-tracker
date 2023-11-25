import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sleep_tracker/components/dash_line.dart';
import 'package:sleep_tracker/components/charts/line_chart.dart';
import 'package:sleep_tracker/components/moods/daily_mood.dart';
import 'package:sleep_tracker/components/moods/mood_picker.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/components/sleep_phase_block.dart';
import 'package:sleep_tracker/components/sleep_timer.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sleep_tracker/providers/sleep_records_provider.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/num.dart';
import 'package:sleep_tracker/utils/string.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

const double _buttonMinimumWidth = 210.0;

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // dev use
  bool alarmOn = true;

  final DateTime _now = DateTime.now();
  late final SleepTimerController _sleepTimerCont = SleepTimerController(displayMode: SleepTimerDisplayMode.remained);

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initTimer() {
    final auth = ref.read(authStateProvider);
    SleepStatus sleepStatus = auth.sleepStatus;
    final SleepRecord? record = auth.sleepRecords.firstOrNull;
    switch (sleepStatus) {
      case SleepStatus.awaken:
        // if there is previous wake up time, start timer from it.

        if (record?.wakeUpAt != null &&
            (record?.wakeUpAt?.isBefore(_now) ?? false)) {
          _sleepTimerCont.start(startTime: record!.wakeUpAt!);
        }
        break;
      case SleepStatus.goToBed:
        _sleepTimerCont.start(startTime: _now, endTime: record!.start);
        break;
      case SleepStatus.sleeping:
        _sleepTimerCont.start(startTime: record!.start, endTime: record.end);
        break;
    }
  }

  Future<void> _setBedtime() async {
    final SleepStatus sleepStatus = ref.read(authStateProvider).sleepStatus;
    DateTimeRange? initialRange;
    if (sleepStatus != SleepStatus.awaken) {
      final last = ref.read(authStateProvider).sleepRecords.first;
      initialRange = DateTimeRange(start: last.start, end: last.end);
    }
    final DateTimeRange? range = await context.pushRoute<DateTimeRange?>(
        EnterBedtimeRoute(initialRange: initialRange));
    if (range == null) return;

    final DateTime now = DateTime.now();
    final bool isBeforeNow = (range.start).isBefore(now);

    // Break start and end time by now, if the start is after now.
    final DateTime start = isBeforeNow ? range.start : now;
    final DateTime end = isBeforeNow ? range.end : range.start;

    // Put the current range.start and range.end into next turn of timer,
    // if start is after now.
    final DateTime? nextStart = isBeforeNow ? null : range.start;
    final DateTime? nextEnd = isBeforeNow ? null : range.end;

    try {
      if (sleepStatus != SleepStatus.awaken) {
        // Edit the latest sleep record, if the user hasn't slept yet or is sleeping.
        await ref
            .read(authStateProvider.notifier)
            .updateSleepRecord(range: range);
      } else {
        await ref
            .read(authStateProvider.notifier)
            .createSleepRecord(range: range);
      }
      _sleepTimerCont.start(
          startTime: start,
          endTime: end,
          nextStart: nextStart,
          nextEnd: nextEnd);
    } catch (e, s) {
      AppLogger.I.e('Setup Bedtime Error', error: e, stackTrace: s);
    }
  }

  Future<void> _wakeUp() async {
    final DateTime now = DateTime.now();
    _sleepTimerCont.start(startTime: now);
    final double? sleepQuality =
        await context.pushRoute(const EnterFeelingRoute());
    await ref
        .read(authStateProvider.notifier)
        .updateSleepRecord(wakeUpAt: now, sleepQuality: sleepQuality);
  }

  Future<void> _snooze() async {}

  void _handleMoodChanged(double? value) async {
    await ref
        .read(authStateProvider.notifier)
        .updateSleepRecord(sleepQuality: value);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final DateTime firstDate =
        (auth.sleepRecords.lastOrNull?.start ?? _now).copyWith(day: 1);

    Widget divider = Padding(
      padding:
          const EdgeInsets.only(top: Style.spacingXxl, bottom: Style.spacingLg),
      child: Divider(color: Theme.of(context).colorScheme.tertiary),
    );

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ProfileStatusBar(),
            const SizedBox(height: Style.spacingXl),
            // Timer
            ListenableBuilder(
              listenable: _sleepTimerCont,
              builder: (BuildContext context, Widget? child) {
                String titleText;
                Widget mainButton;
                Widget? secondaryButton;
                switch (auth.sleepStatus) {
                  case SleepStatus.awaken:
                    titleText = 'Awaken Time';
                    mainButton = ElevatedButton(
                        onPressed: _setBedtime,
                        child: const Text('Start to sleep'));
                    break;
                  case SleepStatus.goToBed:
                    titleText = 'Go To Bed';
                    mainButton = OutlinedButton(
                        onPressed: _setBedtime,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'BEDTIME - ${DateFormat.Hm().format(auth.sleepRecords.first.start)}'),
                            const SizedBox(width: Style.radiusXs),
                            SvgPicture.asset('assets/icons/edit.svg',
                                color: Theme.of(context).primaryColor)
                          ],
                        ));
                    break;
                  case SleepStatus.sleeping:
                    titleText = 'Sleeping Time';
                    mainButton = ElevatedButton(
                        onPressed: _wakeUp, child: const Text('Wake up'));
                    if (auth.sleepRecords.firstOrNull?.end
                            .isBefore(DateTime.now()) ??
                        false) {
                      secondaryButton = OutlinedButton(
                          onPressed: _snooze,
                          child: const Text('Snooze for 5 minutes'));
                    }
                    break;
                }
                final Color primaryColor = Theme.of(context).primaryColor;
                const BoxConstraints columnConstraints =
                    BoxConstraints(maxWidth: 263, minWidth: 220);
                const double iconSize = 16.0;

                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  // Timer
                  if (child != null)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: Style.spacingSm),
                      child: child,
                    ),
                  const SizedBox(height: Style.spacingXxl),
                  ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: _buttonMinimumWidth),
                      child: mainButton),
                  if (secondaryButton != null)
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: _buttonMinimumWidth),
                      margin: const EdgeInsets.only(top: Style.spacingSm),
                      child: secondaryButton,
                    ),
                  const SizedBox(height: Style.spacingMd),
                  // alarm switch
                  ConstrainedBox(
                    constraints: columnConstraints,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/icons/alarm.svg',
                                color: primaryColor,
                                height: iconSize,
                                width: iconSize),
                            Text(
                              'Alarm',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: primaryColor),
                            )
                          ],
                        ),
                        CupertinoSwitch(
                          applyTheme: true,
                          value: alarmOn,
                          onChanged: (value) => setState(() => alarmOn = value),
                        )
                      ],
                    ),
                  ),
                  // Edit went to bed and wake up time
                  if (auth.sleepStatus == SleepStatus.sleeping) ...[
                    ConstrainedBox(
                      constraints: columnConstraints,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            left: iconSize / 2,
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: DashedLine(
                                  size: const Size(1, 16),
                                  dashWidth: 4,
                                  dashSpace: 2,
                                  color: primaryColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/zzz.svg',
                                      color: primaryColor,
                                      width: iconSize,
                                      height: iconSize),
                                  const SizedBox(width: Style.spacingXxs),
                                  Text('Went to Bed',
                                      style: TextStyle(color: primaryColor)),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: _setBedtime,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            DateFormat.jm().format(
                                                auth.sleepRecords.first.start),
                                            style: dataTextTheme.bodyMedium
                                                ?.copyWith(color: Style.grey1),
                                          ),
                                          const SizedBox(
                                              width: Style.spacingXxs),
                                          SvgPicture.asset(
                                              'assets/icons/edit.svg',
                                              color: Style.grey1,
                                              width: 12.0,
                                              height: 12.0)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Style.spacingMd),
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/clock.svg',
                                      color: primaryColor,
                                      width: iconSize,
                                      height: iconSize),
                                  const SizedBox(width: Style.spacingXxs),
                                  Text('Wake up',
                                      style: TextStyle(color: primaryColor)),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: _setBedtime,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            DateFormat.jm().format(
                                                auth.sleepRecords.first.end),
                                            style: dataTextTheme.bodyMedium
                                                ?.copyWith(color: Style.grey1),
                                          ),
                                          const SizedBox(
                                              width: Style.spacingXxs),
                                          SvgPicture.asset(
                                              'assets/icons/edit.svg',
                                              color: Style.grey1,
                                              width: 12.0,
                                              height: 12.0)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ]
                ]);
              },
              child: SleepTimer(controller: _sleepTimerCont),
            ),

            divider,
            // Mood
            ListenableBuilder(
              listenable: _sleepTimerCont,
              builder: (BuildContext context, Widget? child) {
                if (auth.sleepStatus != SleepStatus.sleeping) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TodayMoodBoard(
                        initialValue:
                            auth.sleepRecords.firstOrNull?.sleepQuality,
                        onChanged: _handleMoodChanged,
                      ),
                      if (child != null) child
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              child: divider,
            ),

            const _SleepCycleChart(),
            divider,
            DailyMood(firstDate: firstDate, monthlyMoods: auth.monthlyMoods),
            divider,

            const SizedBox(height: kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatusBar extends ConsumerWidget {
  const _ProfileStatusBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(authStateProvider).user;
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Style.spacingXs, horizontal: Style.spacingMd),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Style.grey3, maxRadius: 24),
          const SizedBox(width: Style.spacingXs),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back, ${user?.name}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat.yMMMEd().format(DateTime.now()),
                  style: dataTextTheme.labelSmall,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TodayMoodBoard extends StatefulWidget {
  const _TodayMoodBoard({this.initialValue, this.onChanged});
  final double? initialValue;
  final ValueChanged<double?>? onChanged;

  @override
  State<_TodayMoodBoard> createState() => __TodayMoodBoardState();
}

class __TodayMoodBoardState extends State<_TodayMoodBoard> {
  late double? _value = widget.initialValue;

  bool isSliding = false;

  void _handleChanged(double? value) {
    setState(() => _value = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    Mood? mood = _value != null ? valueToMood(_value!) : null;
    bool onFocused = (_value == null) || isSliding;

    Widget header = // Header
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(onFocused ? 'How Are You Today?' : 'Today Mood',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        if (!onFocused)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: ElevatedButton(
              onPressed: () => _handleChanged(null),
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.5);
                        }
                        return Theme.of(context).colorScheme.tertiary;
                      },
                    ),
                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(
                            vertical: Style.spacingXs,
                            horizontal: Style.spacingSm)),
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reset',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: Style.spacingXxs),
                  SvgPicture.asset(
                    'assets/icons/reset.svg',
                    height: 16,
                    width: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          )
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Style.spacingMd, 0, Style.spacingMd, Style.spacingXs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          !onFocused
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Style.spacingSm),
                    SvgPicture.asset('assets/moods/${mood?.name}.svg',
                        height: 85),
                    const SizedBox(height: Style.spacingXs),
                    Text(
                      mood?.name.capitalize() ?? '',
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                )
              : MoodPicker(
                  value: _value,
                  onChanged: (v) => setState(() => _handleChanged(v)),
                  onSlide: (v) => setState(() => isSliding = v),
                )
        ],
      ),
    );
  }
}

class _SleepCycleChart extends ConsumerStatefulWidget {
  const _SleepCycleChart();

  @override
  ConsumerState<_SleepCycleChart> createState() => _SleepCycleChartState();
}

class _SleepCycleChartState extends ConsumerState<_SleepCycleChart> {
  late final DateTime _firstDate;

  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _firstDate = DateTimeUtils.mostRecentWeekday(now, 0);
    _dayIndex = now.difference(_firstDate).inDays;
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
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Iterable<SleepRecord> records = getDayRecords(_dayIndex);

    final DateTime? end = records.lastOrNull?.end;
    final List<Point<DateTime, double>> sleepEventType = [];

    Duration interval = const Duration(minutes: 5);
    if (end != null) {
      DateTime start = records.first.start;
      if (end.difference(start).inHours > 11) {
        interval = const Duration(hours: 2);
      } else if (end.difference(start).inHours > 5) {
        interval = const Duration(hours: 1);
      } else if (end.difference(start).inHours > 2) {
        interval = const Duration(minutes: 30);
      } else if (end.difference(start).inMinutes > 59) {
        interval = const Duration(minutes: 15);
      }

      /// Returns sleep events for every record. Only return event per 30 minutes so that the
      /// line chart is not packed with data.
      final Iterable<SleepEvent> sleepEvents =
          records.expand((record) => record.events);
      for (start; true; start = start.add(interval)) {
        if (start.isAfter(end)) break;
        final events = sleepEvents
            .skipWhile((event) => event.time.isBefore(start))
            .takeWhile((event) => !event.time.isAfter(start.add(interval)));

        SleepType type = sleepEvents.any((event) => !start.isBefore(event.time))
            ? SleepType.deepSleep
            : SleepType.awaken;
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

    for (final record in records) {
      final List<SleepEvent> sleepEvents = record.events;
      for (int i = 0; i < sleepEvents.length - 1; i++) {
        final log = sleepEvents[i];
        final nextLog = sleepEvents[i + 1];
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
        final time = ((record.wakeUpAt ?? record.end)
                    .difference(last.time)
                    .inMilliseconds)
                .abs() /
            (60 * 1000);
        if (last.type == SleepType.deepSleep) {
          deepSleepMinutes += time;
        }
      }
    }
    double minutesInBed = records
        .where((record) => record.wakeUpAt != null)
        .fold(
            0.0,
            (previousValue, record) =>
                previousValue +
                record.wakeUpAt!.difference(record.start).inMinutes);

    double sleepMinutes = minutesInBed - awakenMinutes - deepSleepMinutes;
    double asleepMinutes = minutesInBed - awakenMinutes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sleep Cycle',
                  style: Theme.of(context).textTheme.headlineSmall),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: ElevatedButton(
                  onPressed: () => context.pushRoute(const SleepCycleRoute()),
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.5);
                            }
                            return Theme.of(context).colorScheme.tertiary;
                          },
                        ),
                        padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(
                                vertical: Style.spacingXs,
                                horizontal: Style.spacingSm)),
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SvgPicture.asset('assets/icons/chevron-right.svg',
                          color: Theme.of(context).primaryColor,
                          width: 32,
                          height: 32)
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: Style.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(DateTime.daysPerWeek, _buildWeekdayButton),
          ),
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
            getTooltipLabels: (x, y) {
              final int milliSecond =
                  x.toInt() + (earliest?.millisecondsSinceEpoch ?? 0);
              final String time = DateFormat.Hm()
                  .format(DateTime.fromMillisecondsSinceEpoch(milliSecond));
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
          // DEV
          // Text("DEV: Sleep Intensity", style: Theme.of(context).textTheme.headlineSmall),
          // LineChart<int, num>(
          //   data: sleepEvents.map((e) {
          //     return Point(e.time.millisecondsSinceEpoch, e.intensity);
          //   }).toList(),
          //   getSpot: (x, y) {
          //     return Point(x, y);
          //   },
          //   gradientColors: [
          //     Theme.of(context).primaryColor.withOpacity(0.8),
          //     Theme.of(context).primaryColor.withOpacity(0.1),
          //   ],
          //   getYTitles: (value) {
          //     return value.toStringAsFixed(2);
          //   },
          //   getXTitles: (value) {
          //     // value here is the difference of millisecondSinceEpoch between earliest and data.
          //     // Restore and return the millisecondSinceEpoch of data.

          //     return DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
          //   },
          //   minY: 0,
          //   baseLineY: 1,
          //   chartHeight: 203,
          //   minX: earliest?.millisecondsSinceEpoch.toDouble(),
          // ),
          if (records.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(Style.spacingMd,
                  Style.spacingXs, Style.spacingMd, Style.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat.jm().format(records.first.start)} - ${DateFormat.jm().format(records.last.wakeUpAt ?? records.last.end)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Style.grey3),
                        ),
                        Text(
                            '${asleepMinutes ~/ 60}hr ${asleepMinutes.remainder(60).toInt()}min asleep',
                            style: dataTextTheme.bodyMedium)
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sleep Efficiency',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Style.grey3),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        NumFormat.toPercentWithTotal(
                            asleepMinutes, minutesInBed),
                        style: dataTextTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end,
                      )
                    ],
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Style.spacingXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SleepPhaseBlock(
                      color: Style.highlightGold,
                      title: 'Awake',
                      desc: NumFormat.toPercentWithTotal(
                          awakenMinutes, minutesInBed)),
                  SleepPhaseBlock(
                      color: Theme.of(context).primaryColor,
                      title: 'Sleep',
                      desc: NumFormat.toPercentWithTotal(
                          sleepMinutes, minutesInBed)),
                  SleepPhaseBlock(
                      color: Style.highlightPurple,
                      title: 'Deep Sleep',
                      desc: NumFormat.toPercentWithTotal(
                          deepSleepMinutes, minutesInBed)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

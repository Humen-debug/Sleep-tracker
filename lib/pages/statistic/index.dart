import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sleep_tracker/components/charts/bar_chart.dart';
import 'package:sleep_tracker/components/charts/line_chart.dart';
// import 'package:sleep_tracker/components/charts/line_chart.dart';
import 'package:sleep_tracker/components/period_pickers.dart';
import 'package:sleep_tracker/components/sleep_period_tab_bar.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/providers/auth/auth_provider.dart';
import 'package:sleep_tracker/providers/sleep_records_provider.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/date_time.dart';
import 'package:sleep_tracker/utils/num.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _tabRowHeight = 50.0;
const double _appBarHeight = _tabRowHeight + Style.spacingMd * 2;

@RoutePage()
class StatisticPage extends ConsumerStatefulWidget {
  const StatisticPage({super.key});

  @override
  ConsumerState<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends ConsumerState<StatisticPage> {
  late final ButtonStyle? _elevationButtonStyle = Theme.of(context).elevatedButtonTheme.style?.copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return Theme.of(context).colorScheme.background;
          }
          return Theme.of(context).colorScheme.tertiary;
        },
      ),
      foregroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
      side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 2)),
      padding:
          const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
      minimumSize: const MaterialStatePropertyAll(Size(72.0, 32.0)));

  final List<String> _tabs = ['One Week', '6 Weeks', '6 Months'];
  final List<PeriodPickerMode> _pickerModes = [PeriodPickerMode.weeks, PeriodPickerMode.weeks, PeriodPickerMode.months];
  final List<bool> _inRange = [false, true, true];

  int _tabIndex = 0;
  static const int _chartLength = 6;

  /// Initially, set Friday of this week as the last date.
  late final DateTime lastDate;

  /// Initially set half year before the earliest sleepRecord.
  late final DateTime firstDate;

  bool get _isDisplayingFirstDate => !selectedRange.start.isAfter(firstDate);
  bool get _isDisplayingLastDate => !selectedRange.end.isBefore(lastDate);

  late DateTimeRange selectedRange =
      DateTimeRange(start: DateTimeUtils.mostRecentWeekday(DateTime.now(), 0), end: lastDate);

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime first = ref.read(authStateProvider).sleepRecords.lastOrNull?.start ?? now;
    firstDate =
        DateUtils.addMonthsToMonthDate(DateUtils.dateOnly(DateTimeUtils.mostRecentWeekday(first, 0)), -_chartLength);
    lastDate = DateTimeUtils.mostNearestWeekday(now, 6);
  }

  void _handleTabChanged(int index) {
    final DateTime end = selectedRange.end;
    DateTime start;
    setState(() {
      _tabIndex = index;
      if (_tabIndex == 0) {
        start = DateUtils.addDaysToDate(end, -_chartLength);
      } else if (_tabIndex == 1) {
        start = DateUtils.addDaysToDate(end, -(DateTime.daysPerWeek * _chartLength) + 1);
      } else {
        start = DateUtils.addMonthsToMonthDate(end, -_chartLength);
      }
      selectedRange = DateTimeRange(start: start, end: end);
    });
  }

  /// Shifts [selectedRange] to previous intervals based on [_tabIndex]
  void _handlePreviousPeriod() {
    DateTimeRange range;
    if (_tabIndex == 0) {
      // According to the PeriodPickerMode. 0 index refers to the "DAYS"
      // selection, which has constant 7-day per week as range.
      range = DateTimeUtils.shiftDaysToRange(selectedRange, -DateTime.daysPerWeek);
    } else if (_tabIndex == 1) {
      // According to the PeriodPickerMode. 1 index refers to the "WEEKS"
      // selection, which has constant (_chartLength * 7-day per week) as range.
      range = DateTimeUtils.shiftDaysToRange(selectedRange, -(_chartLength * DateTime.daysPerWeek));
    } else {
      range = DateTimeUtils.shiftMonthsToRange(selectedRange, -_chartLength);
    }

    if (range.start.isBefore(firstDate)) {
      return;
    }
    setState(() => selectedRange = range);
  }

  /// Shifts [selectedRange] to next intervals based on [_tabIndex]
  void _handleNextPeriod() {
    DateTimeRange range;
    if (_tabIndex == 0) {
      range = DateTimeUtils.shiftDaysToRange(selectedRange, DateTime.daysPerWeek);
    } else if (_tabIndex == 1) {
      range = DateTimeUtils.shiftDaysToRange(selectedRange, (_chartLength * DateTime.daysPerWeek));
    } else {
      range = DateTimeUtils.shiftMonthsToRange(selectedRange, _chartLength);
    }

    if (range.end.isAfter(lastDate)) {
      return;
    }
    setState(() => selectedRange = range);
  }

  Widget _buildChart(
    BuildContext context, {
    required String title,
    bool hasMore = false,
    required Widget chart,
  }) {
    final moreButton = ElevatedButton(
        onPressed: () {
          // dev. Since there is only one more button among all statistic chart.
          // It is assumed the [onPressed] only handle the [SleepHealth] case.
          context.pushRoute(const SleepHealthRoute());
        },
        style: _elevationButtonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('More'),
            SvgPicture.asset('assets/icons/chevron-right.svg', color: Theme.of(context).primaryColor)
          ],
        ));

    final periodHeader = Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
          onTap: _handlePreviousPeriod,
          child: SvgPicture.asset('assets/icons/chevron-left.svg',
              color: _isDisplayingFirstDate ? Style.grey3 : Style.grey1)),
      PeriodPicker(
        maxWidth: 100,
        mode: _pickerModes[_tabIndex],
        selectedDate: selectedRange.start,
        selectedRange: selectedRange,
        lastDate: lastDate,
        firstDate: firstDate,
        rangeSelected: _inRange[_tabIndex],
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
          onTap: _handleNextPeriod,
          child: SvgPicture.asset('assets/icons/chevron-right.svg',
              color: _isDisplayingLastDate ? Style.grey3 : Style.grey1)),
    ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatisticHeader(title: title, topBarRightWidget: hasMore ? moreButton : periodHeader),
          const SizedBox(height: Style.spacingXl),
          chart,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stores mean sleep efficiency per record.
    List<Point<DateTime, double?>> sleepEfficiencies = [];
    // Stores mean sleep durations per day.
    List<double> meanSleepDurations = [];
    // Stores sleep start time in minutes (since 00:00) per interval.
    List<Point<DateTime, int?>> wentToSleepAt = [];
    // Store average mood per interval.
    List<Point<DateTime, double?>> meanMoods = [];

    DateTime start = DateUtils.dateOnly(selectedRange.start);
    final DateTime end = DateUtils.dateOnly(selectedRange.end);
    int interval;
    if (_tabIndex == 0) {
      //  interval as single day
      interval = 1;
    } else if (_tabIndex == 1) {
      //  interval as single week
      interval = DateTime.daysPerWeek;
    } else {
      interval = DateUtils.getDaysInMonth(start.year, start.month);
    }
    while (!start.isAfter(end)) {
      // update interval if [_tabIndex] == 2
      if (_tabIndex == 2) interval = DateUtils.getDaysInMonth(start.year, start.month);
      final DateTime next = DateUtils.addDaysToDate(start, interval);
      final Iterable<SleepRecord> sleepRecords =
          ref.watch(rangeSleepRecordsProvider(DateTimeRange(start: start, end: next)));

      double totalDuration = 0.0;

      double? meanMood;
      int moodCount = 0;
      final List<Point<DateTime, int?>> wentToSleep = [];
      final List<Point<DateTime, double?>> sleepEfficiency = [];
      for (final record in sleepRecords) {
        final DateTime? wakeUpAt = record.wakeUpAt;
        final DateTime start = record.start;
        totalDuration += (wakeUpAt == null ? 0 : wakeUpAt.difference(start).inMinutes);

        final double? mood = record.sleepQuality;
        meanMood ??= mood;
        if (mood != null) moodCount++;
        if (meanMood != null && mood != null) {
          meanMood = (meanMood * (moodCount - 1) + mood) / moodCount;
        }

        wentToSleep.add(Point(start, start.hour * 60 + start.minute));

        final sleepEvents = record.events;
        double awakenMinutes = 0.0;

        for (int i = 0; i < sleepEvents.length - 1; i++) {
          final log = sleepEvents.elementAt(i);
          final nextLog = sleepEvents.elementAt(i + 1);
          final time = nextLog.time.difference(log.time).inMilliseconds / (60 * 1000);
          // According to our sleep-wake classification algorithm, type is divided into
          // SleepType.awaken and SleepType.deepSleep;
          if (log.type == SleepType.awaken) {
            awakenMinutes += time;
          }
        }

        if (sleepEvents.isNotEmpty && record.wakeUpAt != null) {
          final last = sleepEvents.last;
          final time = (record.wakeUpAt!.difference(last.time).inMilliseconds).abs() / (60 * 1000);
          if (last.type == SleepType.awaken) {
            awakenMinutes += time;
          }
        }
        double minutesInBed = sleepRecords
            .where((record) => record.wakeUpAt != null)
            .fold(0.0, (previousValue, record) => previousValue + record.wakeUpAt!.difference(record.start).inMinutes);

        double asleepMinutes = minutesInBed - awakenMinutes;
        sleepEfficiency.add(Point(start, minutesInBed == 0 ? null : asleepMinutes / minutesInBed));
      }
      final double meanDuration = totalDuration / interval;
      meanSleepDurations.add(meanDuration);
      meanMoods.add(Point(start, meanMood));
      wentToSleepAt.addAll(wentToSleep.isEmpty ? [Point(start, null)] : wentToSleep);
      sleepEfficiencies.addAll(sleepEfficiency.isEmpty ? [Point(start, null)] : sleepEfficiency);
      start = next;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    String getBarDateTitles(double value) {
      // if is integrate
      if (value == value.roundToDouble()) {
        final start = selectedRange.start;
        final int index = value.round();
        int interval;
        DateFormat format;
        if (_tabIndex == 0) {
          interval = 1;
          format = DateFormat.Md();
        } else if (_tabIndex == 1) {
          interval = DateTime.daysPerWeek;
          format = DateFormat.Md();
        } else {
          interval = DateUtils.getDaysInMonth(start.year, start.month);
          format = DateFormat.MMM();
        }
        final dayToAdd = index * interval;
        final date = DateUtils.addDaysToDate(start, dayToAdd);
        return format.format(date);
      }
      return "";
    }

    String getLineDateTitles(double value) {
      // value is in milliSecondsSinceEpoch.
      if (value == value.roundToDouble()) {
        DateFormat format;

        if (_tabIndex == 0) {
          format = DateFormat.Md();
        } else if (_tabIndex == 1) {
          format = DateFormat.Md();
        } else {
          format = DateFormat.MMM();
        }

        return format.format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
      }
      return '';
    }

    List<Widget> charts = [
      _buildChart(context,
          title: 'Sleep Efficiency',
          hasMore: true,
          chart: LineChart(
            data: sleepEfficiencies,
            getSpot: (x, y) {
              // compute dx as index in unit [day]
              final dx = x.millisecondsSinceEpoch;
              return Point(dx, y);
            },
            getYTitles: NumFormat.toPercent,
            getXTitles: getLineDateTitles,
            color: Style.highlightGold,
            showDots: true,
            minX: selectedRange.start.millisecondsSinceEpoch.toDouble(),
            maxX: selectedRange.end.millisecondsSinceEpoch.toDouble(),
            // minY: 0.0,
            intervalX: interval * (24.0 * 3600 * 1000),
          )),
      _buildChart(context,
          title: 'Sleep Duration (avg.)',
          chart: BarChart(
            data: meanSleepDurations,
            gradientColors: [colorScheme.primary, colorScheme.tertiary],
            getYTitles: (value) {
              final double hour = value / 60;
              if (hour == hour.roundToDouble()) {
                return hour.toInt().toString();
              } else {
                return hour.toStringAsFixed(1);
              }
            },
            getXTitles: getBarDateTitles,
          )),
      _buildChart(context,
          title: 'Went To Sleep',
          chart: LineChart<DateTime, int?>(
            data: wentToSleepAt,
            getSpot: (x, y) {
              // compute dx as index in unit [day]
              final dx = x.millisecondsSinceEpoch;
              return Point(dx, y);
            },
            getYTitles: (value) {
              final hour = NumFormat.toNDigits((value / 60).floor());
              final minute = NumFormat.toNDigits(value.remainder(60).round());
              return "$hour:$minute";
            },
            getXTitles: getLineDateTitles,
            color: Style.highlightPurple,
            showDots: true,
            minX: selectedRange.start.millisecondsSinceEpoch.toDouble(),
            maxX: selectedRange.end.millisecondsSinceEpoch.toDouble(),
            maxY: 24 * 60 - 1,
            intervalX: interval * (24.0 * 3600 * 1000),
          )),
      _buildChart(context,
          title: 'Sleep Quality',
          chart: LineChart(
            data: meanMoods,
            getSpot: (x, y) {
              // compute dx as index in unit [day]
              final dx = x.millisecondsSinceEpoch;
              return Point(dx, y);
            },
            getYTitles: NumFormat.toPercent,
            getXTitles: getLineDateTitles,
            color: Style.successColor,
            showDots: true,
            minX: selectedRange.start.millisecondsSinceEpoch.toDouble(),
            maxX: selectedRange.end.millisecondsSinceEpoch.toDouble(),
            minY: 0,
            maxY: 1,
            intervalX: interval * (24.0 * 3600 * 1000),
          ))
    ];
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(_appBarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.75),
            elevation: 0,
            flexibleSpace: Padding(
                padding: const EdgeInsets.all(Style.spacingMd),
                child: SleepPeriodTabBar(
                  labels: _tabs,
                  initialIndex: _tabIndex,
                  onChanged: _handleTabChanged,
                )),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: charts
              .mapIndexed((index, child) =>
                  <Widget>[child, if (index != charts.length - 1) const SizedBox(height: Style.spacingXxl)])
              .expand((child) => child)
              .toList(),
        ));
  }
}

class _StatisticHeader extends StatelessWidget {
  const _StatisticHeader({required this.title, this.topBarRightWidget});
  final String title;
  final Widget? topBarRightWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (topBarRightWidget != null) topBarRightWidget!
      ],
    );
  }
}

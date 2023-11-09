import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/line_chart.dart';
import 'package:sleep_tracker/components/moods/daily_mood.dart';
import 'package:sleep_tracker/components/moods/mood_picker.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/components/sleep_phase_block.dart';
import 'package:sleep_tracker/components/sleep_timer.dart';
import 'package:sleep_tracker/routers/app_router.dart';
import 'package:sleep_tracker/utils/string.dart';
import 'package:sleep_tracker/utils/style.dart';
import 'package:sleep_tracker/utils/theme_data.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // dev use
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(hours: 8));
  bool alarmOn = true;
  // dev use
  final DateTime _now = DateTime.now();
  late final DateTime firstDate = DateUtils.dateOnly(_now.subtract(const Duration(days: 365)).copyWith(day: 1));
  late int monthToGenerate = DateUtils.monthDelta(firstDate, _now) + 1;
  late final List<List<double?>> monthlyMoods = List.generate(monthToGenerate, (index) {
    int currentMonth = _now.month;
    int month = (currentMonth - index > 0) ? currentMonth - index : index % monthToGenerate;
    int year = currentMonth - index <= 0 ? _now.year - 1 : _now.year;
    return List.generate(
      DateUtils.getDaysInMonth(year, month),
      (day) => (index > 0) || day + 1 <= _now.day ? Random().nextDouble() : null,
    );
  }).reversed.toList();

  late final SleepTimerController _sleepTimerCont = SleepTimerController();

  @override
  Widget build(BuildContext context) {
    Widget divider = Padding(
      padding: const EdgeInsets.only(top: Style.spacingXxl, bottom: Style.spacingLg),
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
            Text('Awaken Time',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: Style.spacingSm),
            SleepTimer(controller: _sleepTimerCont),
            const SizedBox(height: Style.spacingSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Style.spacingXl, vertical: Style.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 210),
                    child: ElevatedButton(
                        onPressed: () {
                          context.pushRoute(const EnterBedtimeRoute());
                          // _sleepTimerCont.start(
                          //     startTime: DateTime.now(), endTime: DateTime.now().add(const Duration(minutes: 1)));
                        },
                        child: const Text('Start to Sleep')),
                  ),
                  // Dev
                  // const SizedBox(height: Style.spacingMd),
                  // ConstrainedBox(
                  //   constraints: const BoxConstraints(minWidth: 210),
                  //   child: OutlinedButton(
                  //       onPressed: () {
                  //         _sleepTimerCont.start(startTime: DateTime.now());
                  //       },
                  //       child: const Text('Wake up')),
                  // ),
                  // const SizedBox(height: Style.spacingMd),
                  // ConstrainedBox(
                  //   constraints: const BoxConstraints(minWidth: 210),
                  //   child: OutlinedButton(
                  //       onPressed: () {
                  //         _sleepTimerCont.reset();
                  //       },
                  //       child: const Text('Reset')),
                  // ),
                  const SizedBox(height: Style.spacingMd),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 263, minWidth: 220),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/alarm.svg',
                              color: Theme.of(context).primaryColor,
                              height: 16,
                              width: 16,
                            ),
                            Text('Alarm',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Theme.of(context).primaryColor))
                          ],
                        ),
                        CupertinoSwitch(
                            applyTheme: true, value: alarmOn, onChanged: (value) => setState(() => alarmOn = value))
                      ],
                    ),
                  )
                ],
              ),
            ),
            divider,
            // Mood
            _TodayMoodBoard(
              initialValue: monthlyMoods.last[_now.day - 1],
              onChanged: (value) => setState(() {
                monthlyMoods.last[_now.day - 1] = value;
              }),
            ),
            divider,
            const _SleepCycleChart(),
            divider,
            DailyMood(firstDate: firstDate, monthlyMoods: monthlyMoods),
            divider,
            const SizedBox(height: kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatusBar extends StatelessWidget {
  const _ProfileStatusBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingMd),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Style.grey3,
            maxRadius: 24,
          ),
          const SizedBox(width: Style.spacingXs),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back, user',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
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
  const _TodayMoodBoard({super.key, this.initialValue, this.onChanged});
  final double? initialValue;
  final ValueChanged<double?>? onChanged;

  @override
  State<_TodayMoodBoard> createState() => __TodayMoodBoardState();
}

class __TodayMoodBoardState extends State<_TodayMoodBoard> {
  // dev. It should be fetched from the today's sleeping quality
  /// the sleeping quality, in range of 0 to 1.
  late double? _value = widget.initialValue;

  bool isSliding = false;

  void _handleChanged(double? value) {
    setState(() => _value = value);
    if (widget.onChanged != null) widget.onChanged!(value);
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
        if (!onFocused)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: ElevatedButton(
              onPressed: () => _handleChanged(null),
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Theme.of(context).colorScheme.tertiary.withOpacity(0.5);
                        }
                        return Theme.of(context).colorScheme.tertiary;
                      },
                    ),
                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reset',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.fromLTRB(Style.spacingMd, 0, Style.spacingMd, Style.spacingXs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          !onFocused
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Style.spacingSm),
                    SvgPicture.asset('assets/moods/${mood?.name}.svg', height: 85),
                    const SizedBox(height: Style.spacingXs),
                    Text(
                      mood?.name.capitalize() ?? '',
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  ],
                )
              : MoodPicker(
                  value: _value,
                  onChanged: _handleChanged,
                  onSlide: (v) => setState(() => isSliding = v),
                )
        ],
      ),
    );
  }
}

class _SleepCycleChart extends StatelessWidget {
  const _SleepCycleChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sleep Cycle', style: Theme.of(context).textTheme.headlineSmall),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: ElevatedButton(
                  onPressed: () {},
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Theme.of(context).colorScheme.tertiary.withOpacity(0.5);
                            }
                            return Theme.of(context).colorScheme.tertiary;
                          },
                        ),
                        padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: Style.spacingXs, horizontal: Style.spacingSm)),
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                      SvgPicture.asset('assets/icons/chevron-right.svg',
                          color: Theme.of(context).primaryColor, width: 32, height: 32)
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: Style.spacingLg),
          SizedBox(
            height: 203,
            child: LineChart(
              data: List.generate(6, (index) => Random().nextDouble() * 100),
              gradientColors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.1),
              ],
              getYTitles: (value) => value.round().toString(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Style.spacingMd, Style.spacingXs, Style.spacingMd, Style.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1:24 AM - 9:04 AM',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Style.grey3),
                      ),
                      Text('7hr 23min asleep', style: dataTextTheme.bodyMedium)
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Style.grey3),
                      textAlign: TextAlign.end,
                    ),
                    Text('97%',
                        style: dataTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end)
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
                SleepPhaseBlock(color: Style.highlightGold, title: 'Awake', desc: '3%'),
                SleepPhaseBlock(color: Theme.of(context).primaryColor, title: 'Sleep', desc: '74%'),
                SleepPhaseBlock(color: Style.highlightPurple, title: 'Deep Sleep', desc: '23%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

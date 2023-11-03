import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tracker/components/line_chart.dart';
import 'package:sleep_tracker/components/moods/daily_mood.dart';
import 'package:sleep_tracker/components/moods/mood_board.dart';
import 'package:sleep_tracker/components/sleep_phase_block.dart';
import 'package:sleep_tracker/components/sleep_timer.dart';
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

  late final SleepTimerController _sleepTimerCont = SleepTimerController();

  @override
  Widget build(BuildContext context) {
    Widget divider() => Padding(
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
                          _sleepTimerCont.start(
                              startTime: DateTime.now(), endTime: DateTime.now().add(const Duration(minutes: 1)));
                        },
                        child: const Text('Start to Sleep')),
                  ),
                  // Dev
                  const SizedBox(height: Style.spacingMd),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 210),
                    child: OutlinedButton(
                        onPressed: () {
                          _sleepTimerCont.start(startTime: DateTime.now());
                        },
                        child: const Text('Wake up')),
                  ),
                  const SizedBox(height: Style.spacingMd),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 210),
                    child: OutlinedButton(
                        onPressed: () {
                          _sleepTimerCont.reset();
                        },
                        child: const Text('Reset')),
                  ),
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
            divider(),
            // Mood
            const MoodBoard(),
            divider(),
            const _SleepCycleChart(),
            divider(),
            const DailyMood(),
            divider(),
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
              ElevatedButton(
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
                    const SizedBox(width: Style.spacingXxs),
                  ],
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

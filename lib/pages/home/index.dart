import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileStatusBar(),
            const SizedBox(height: Style.spacingXl),
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
          ],
        ),
      ),
    );
  }
}

class ProfileStatusBar extends StatelessWidget {
  const ProfileStatusBar({super.key});

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

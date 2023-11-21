import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tracker/components/sleep_plan_pie_chart.dart';
import 'package:sleep_tracker/models/sleep_plan.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage()
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final List<SleepPlan> _plans = [
    SleepPlan(
      id: '0',
      name: 'Mono',
      brief: '6-9 hours',
      sleepMinutes: [480],
      desc: 'This is the most common sleeping cycle and consists of one core sleep at night of between 6-9 hours.',
      targets: ['People who work the regular 9-5 or schedules that won’t allow short naps in the middle of the day.'],
    ),
    SleepPlan(
      id: '1',
      name: 'Bi',
      brief: '6 hours + one 20 min nap',
      sleepMinutes: [360, 20],
      desc:
          'It consists of a split sleeping pattern, so around 5-6 hours at night and around 2 hours of sleep at midday.',
      targets: [
        'People living in areas where biphasic sleep is common, for example, the Mediterranean or Latin America.'
      ],
    ),
    SleepPlan(
      id: '2',
      name: 'Everyman',
      brief: '3.5 hours + three 20 min naps',
      sleepMinutes: [3.5 * 60, 20, 20, 20],
      desc:
          'It is the least extreme polyphasic sleep cycle. It consists of 3.5 to 4 hours of sleep and three 20-minute naps spread out across the day.',
      targets: [
        'People who want to use polyphasic sleep to increase their waking hours but aren’t quite ready for the extremities of the Dymaxion or Uberman cycle.'
      ],
    ),
    SleepPlan(
        id: '3',
        name: 'Dynamaxion',
        brief: 'four 30 min naps',
        sleepMinutes: [30, 30, 30, 30],
        desc: 'It has the most time awake in a day, with 22 hours bright-eyed and just 2 hours asleep!',
        targets: [
          'People who don’t require much sleep, or those with the DEC2 gene, also known as short sleepers. This might also be beneficial for those who can fall asleep quickly once they get to bed'
        ]),
    SleepPlan(
        id: '4',
        name: 'Uberman',
        brief: 'six-eight 20 min naps',
        sleepMinutes: [20, 20, 20, 20, 20, 20],
        desc:
            'It is a polyphasic cycle that consists of 6 to 8 equidistant naps across the day, each lasting 20 minutes.',
        targets: [
          'People who can follow a rigid and restrictive polyphasic sleep schedule. ',
          'People who don’t require to be awake for longer than 3.5 hours. That’s because that’s all the waking time you get between naps.'
        ])
  ];

  late final List<List<Sector>> _sleepSectors = _plans.map((plan) {
    final List<Sector> res = [];
    const int dayMinutes = 24 * 60;
    final double meanActive = (dayMinutes - plan.sleepMinutes.sum) / plan.sleepMinutes.length;
    for (final minutes in plan.sleepMinutes) {
      res.add(Sector(color: Style.highlightGold, value: minutes));
      res.add(Sector(color: Theme.of(context).colorScheme.tertiary, value: meanActive));
    }
    return res;
  }).toList();

  int _activeIndex = 1;

  void _onPlanChanged(int index) async {
    if (_activeIndex == index) return;
    bool? confirm = await showDialog(
        context: context,
        builder: (context) {
          final actions = Container(
              alignment: AlignmentDirectional.centerEnd,
              constraints: const BoxConstraints(minHeight: 52),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(onPressed: () => context.popRoute(), child: const Text('CANCEL')),
                  TextButton(
                      onPressed: () => context.popRoute(true),
                      child: const Text('OK', style: TextStyle(color: Style.grey3))),
                ],
              ));
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingSm, horizontal: Style.spacingMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Change Plan?', style: Theme.of(context).textTheme.headlineSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Style.spacingMd),
                    child: Text('''Do you confirm to change to ${_plans[index].name} sleeping pattern?
Once you confirm, your plan record will be reset.''', style: const TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  actions
                ],
              ),
            ),
          );
        });
    if (confirm == true) setState(() => _activeIndex = index);
  }

  List<Widget> _buildHeader(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your current sleeping plan',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Style.spacingLg),
              child: LayoutBuilder(builder: _buildCurrentSleepPlan),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Plan adopted for',
                        style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
                    const SizedBox(height: Style.spacingXxs),
                    Text('10 days', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Plan fulfillment',
                        style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
                    const SizedBox(height: Style.spacingXxs),
                    Text('82%', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sleep quality', style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
                    const SizedBox(height: Style.spacingXxs),
                    Text('Good', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    ];
  }

  Widget _buildCurrentSleepPlan(BuildContext context, BoxConstraints constraints) {
    return SleepPlanPieChart(
      radius: math.min(math.max((constraints.maxWidth - Style.spacingXl * 2) / 2, 95), 120),
      title: _plans[_activeIndex].name,
      desc: _plans[_activeIndex].brief,
      spacing: Style.spacingMd,
      sectors: _sleepSectors[_activeIndex],
    );
  }

  Widget _buildPlans(BuildContext context, int index) {
    final bool isSelected = index == _activeIndex;
    const double radius = 50.0;
    final List<Sector> sectors = _sleepSectors[index];
    final String title = _plans[index].name;
    final String duration = _plans[index].brief;
    final String desc = _plans[index].desc;
    final List<String> targets = _plans[index].targets;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.radiusSm),
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
      ),
      padding: EdgeInsets.all(isSelected ? 3 : 2),
      child: InkWell(
        onTap: () => _onPlanChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Style.spacingMd, horizontal: Style.radiusSm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSelected ? 3 : 4),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: SleepPlanPieChart(sectors: sectors, radius: radius, title: title, desc: duration),
              ),
              const SizedBox(width: Style.spacingSm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w300)),
                    const SizedBox(height: Style.spacingSm),
                    Text('Best suited to',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w300, color: Style.grey3)),
                    const SizedBox(height: Style.spacingMd),
                    ...targets.map(
                      (target) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            alignment: Alignment.center,
                            child: SvgPicture.asset('assets/icons/tick.svg',
                                height: 12, width: 12, color: Style.successColor),
                          ),
                          const SizedBox(width: Style.spacingXxs),
                          Expanded(child: Text(target, style: Theme.of(context).textTheme.bodySmall)),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: _buildHeader,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: Style.spacingXxl, bottom: Style.spacingMd),
              child: Text('Want to try other plan?',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: _buildPlans,
                itemCount: _plans.length,
                separatorBuilder: (_, __) => const SizedBox(height: Style.spacingSm),
                padding: const EdgeInsets.symmetric(horizontal: Style.spacingMd),
                physics: const BouncingScrollPhysics(),
              ),
            ),
            const SizedBox(height: kBottomNavigationBarHeight),
          ],
        ),
      ),
    );
  }
}

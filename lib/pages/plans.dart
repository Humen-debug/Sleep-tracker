import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/components/moods/utils.dart';
import 'package:sleep_tracker/components/sleep_plan_pie_chart.dart';
import 'package:sleep_tracker/models/sleep_plan.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sleep_tracker/providers/sleep_records_provider.dart';
import 'package:sleep_tracker/utils/num.dart';
import 'package:sleep_tracker/utils/string.dart';
import 'package:sleep_tracker/utils/style.dart';

@RoutePage()
class PlansPage extends ConsumerStatefulWidget {
  const PlansPage({super.key});

  @override
  ConsumerState<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends ConsumerState<PlansPage> {
  late final List<List<Sector>> _sleepSectors = plans.map((plan) {
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
                    child: Text('''Do you confirm to change to ${plans[index].name} sleeping pattern?
Once you confirm, your plan record will be reset.''', style: const TextStyle(fontWeight: FontWeight.w300)),
                  ),
                  actions
                ],
              ),
            ),
          );
        });
    if (confirm == true) {
      setState(() => _activeIndex = index);
      SleepPlan plan = plans[_activeIndex];
      User? user = ref.read(authStateProvider).user?.copyWith(sleepPlan: plan.id, sleepPlanUpdatedAt: DateTime.now());
      ref.read(authStateProvider.notifier).setUser(user);
    }
  }

  List<Widget> _buildHeader(BuildContext context, bool innerBoxIsScrolled) {
    User? user = ref.watch(authStateProvider).user;
    // Calculated by total sleep duration and the match of sleep time slots per day.
    final DateTime? planStartedAt = user?.sleepPlanUpdatedAt;
    final DateTime now = DateUtils.dateOnly(DateTime.now());
    final bool planStartsToday = planStartedAt == null || DateUtils.isSameDay(now, planStartedAt);
    final SleepPlan plan = plans.firstWhereOrNull((plan) => plan.id == user?.sleepPlan) ?? plans[0];
    double fulfillment = 0.0;
    double meanMood = 0.0;
    int moodCount = 0;
    int count = 0;
    if (!planStartsToday) {
      for (DateTime start = DateUtils.dateOnly(planStartedAt);
          !start.isAfter(DateTime.now());
          start = DateUtils.addDaysToDate(start, 1)) {
        final records = ref.watch(daySleepRecordsProvider(start)).where((record) => record.wakeUpAt != null);
        if (records.isNotEmpty) count++;

        double minutesInBed = 0.0;

        for (final record in records) {
          minutesInBed += (record.wakeUpAt!.difference(record.start).inMinutes);
          final mood = record.sleepQuality;
          if (mood != null) {
            moodCount++;
            meanMood = (meanMood * (moodCount - 1) + mood) / moodCount;
          }
        }

        double value = math.max(math.min(minutesInBed / plan.sleepMinutes.sum, 1), 0);
        fulfillment = (fulfillment * (count - 1) + value) / count;
      }
    }
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
                    Text('${user?.sleepPlanDays ?? '-'} days',
                        style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Plan fulfillment',
                        style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
                    const SizedBox(height: Style.spacingXxs),
                    Text(!planStartsToday ? NumFormat.toPercent(fulfillment) : '--',
                        style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sleep quality', style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
                    const SizedBox(height: Style.spacingXxs),
                    Text(!planStartsToday ? (valueToMood(meanMood).name).capitalize() : '--',
                        style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
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
      title: plans[_activeIndex].name,
      desc: plans[_activeIndex].brief,
      spacing: Style.spacingMd,
      sectors: _sleepSectors[_activeIndex],
    );
  }

  Widget _buildPlans(BuildContext context, int index) {
    final bool isSelected = index == _activeIndex;
    const double radius = 50.0;
    final List<Sector> sectors = _sleepSectors[index];
    final String title = plans[index].name;
    final String duration = plans[index].brief;
    final String desc = plans[index].desc;
    final List<String> targets = plans[index].targets;

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
                itemCount: plans.length,
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

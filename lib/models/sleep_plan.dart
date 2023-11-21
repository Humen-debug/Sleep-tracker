import 'package:freezed_annotation/freezed_annotation.dart';
part 'sleep_plan.freezed.dart';
part 'sleep_plan.g.dart';

@freezed
class SleepPlan with _$SleepPlan {
  @Assert('sleepMinutes.isNotEmpty', 'sleepMinutes must not be empty.')
  factory SleepPlan({
    required String id,
    required String name,
    @Default('') String brief,
    @Default('') String desc,

    /// [sleepMinutes] determines the sleep intervals in minutes.
    ///
    /// Must not be empty.
    required List<double> sleepMinutes,

    /// [targets]  stores the descriptions of people that the plan is suited to
    @Default([]) List<String> targets,
  }) = _SleepPlan;

  factory SleepPlan.fromJson(Map<String, Object?> json) => _$SleepPlanFromJson(json);
}

/// dummy plans for dev use.
final List<SleepPlan> plans = [
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

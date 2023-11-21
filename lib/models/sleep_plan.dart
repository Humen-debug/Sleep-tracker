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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? password,
    DateTime? birth,
    String? gender,

    ///  [sleepPlan] stores the id of SleepPlan that user is adapting
    String? sleepPlan,

    /// [sleepPlanUpdatedAt]  stores the day/time when user adapts the [sleepPlan]
    ///
    /// It is used to calculate the plan fulfillment and sleep quality during the plan
    /// period in PlanPage.
    DateTime? sleepPlanUpdatedAt,
  }) = _User;
  const User._();

  /// [sleepPlanDays] returns the amount of days that user has adapted the [sleepPlan]
  int get sleepPlanDays => sleepPlanUpdatedAt != null ? DateTime.now().difference(sleepPlanUpdatedAt!).inDays : 0;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_record.freezed.dart';
part 'sleep_record.g.dart';

/// [SleepRecord] contains records of individual events created by the user,
/// including a [start] and [end] date/time, and furthermore a sleep efficiency statistic.
///
/// The [sleepEfficiency] is based on the data results form the event logs for each record
/// and whether or not the records were essentially good (minimal variables) or bad (maximum variables).
///
@freezed
class SleepRecord with _$SleepRecord {
  @Assert('end.isAfter(start)', 'end must be after start.')
  @Assert('sleepEfficiency == null || sleepEfficiency >= 0 && sleepEfficiency <= 1',
      'sleepEfficiency must be in range of 0 to 1.')
  @Assert('sleepQuality == null || sleepQuality >= 0 && sleepQuality <= 1', 'sleepQuality must be in range of 0 to 1.')
  factory SleepRecord({
    required String id,

    /// User input of the bedtime.
    ///
    /// Must not be null.
    required DateTime start,

    /// User input of the estimated time of wake-up.
    ///
    /// Must not be null.
    required DateTime end,

    /// User input of actual wake up time.
    ///
    /// It can be used to calculate the regularity.
    DateTime? wakeUpAt,

    /// Overall % of sleep efficiency. It is based on the data results from
    /// [sleepEfficiency].
    ///
    /// Only accepts 0 - 1.
    double? sleepEfficiency,

    /// Movement activity logs.
    @Default([]) List<SleepEvent> events,

    /// Overall % of sleep quality. It is based on the user input.
    ///
    /// Only accepts 0 - 1.
    double? sleepQuality,
  }) = _SleepRecord;

  factory SleepRecord.fromJson(Map<String, Object?> json) => _$SleepRecordFromJson(json);
}

/// [SleepEvent] contains individual logs, which monitor the movement activity.
@freezed
class SleepEvent with _$SleepEvent {
  const factory SleepEvent({
    String? id,

    /// Intensity of movement event.
    required double intensity,

    /// Movement event log date/time.
    required DateTime time,
  }) = _SleepEvent;
  const SleepEvent._();

  factory SleepEvent.fromJson(Map<String, Object?> json) => _$SleepEventFromJson(json);

  /// 9: None(Awaken), 1: Lowest(Deep sleep) and 3: Highest(Sleep)
  /// Currently threshold to determine the sleep stage is 1.
  SleepType get type => intensity >= sleepIndex0
      ? SleepType.awaken
      : intensity > 1
          ? SleepType.sleep
          : SleepType.deepSleep;
}

enum SleepType { awaken, sleep, deepSleep }

extension SleepTypeExtension on SleepType {
  int get value {
    switch (this) {
      case SleepType.awaken:
        return 9;
      case SleepType.sleep:
        return 3;
      case SleepType.deepSleep:
        return 1;
    }
  }
}

const double sleepIndex0 = math.e;

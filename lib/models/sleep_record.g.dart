// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepRecordImpl _$$SleepRecordImplFromJson(Map<String, dynamic> json) =>
    _$SleepRecordImpl(
      id: json['id'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      wakeUpAt: json['wakeUpAt'] == null
          ? null
          : DateTime.parse(json['wakeUpAt'] as String),
      sleepEfficiency: (json['sleepEfficiency'] as num?)?.toDouble(),
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => SleepEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sleepQuality: (json['sleepQuality'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SleepRecordImplToJson(_$SleepRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'wakeUpAt': instance.wakeUpAt?.toIso8601String(),
      'sleepEfficiency': instance.sleepEfficiency,
      'events': instance.events,
      'sleepQuality': instance.sleepQuality,
    };

_$SleepEventImpl _$$SleepEventImplFromJson(Map<String, dynamic> json) =>
    _$SleepEventImpl(
      id: json['id'] as String?,
      intensity: (json['intensity'] as num).toDouble(),
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$$SleepEventImplToJson(_$SleepEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'time': instance.time.toIso8601String(),
    };

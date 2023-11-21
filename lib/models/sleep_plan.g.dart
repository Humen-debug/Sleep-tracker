// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepPlanImpl _$$SleepPlanImplFromJson(Map<String, dynamic> json) =>
    _$SleepPlanImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      brief: json['brief'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      sleepMinutes: (json['sleepMinutes'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      targets: (json['targets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SleepPlanImplToJson(_$SleepPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brief': instance.brief,
      'desc': instance.desc,
      'sleepMinutes': instance.sleepMinutes,
      'targets': instance.targets,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      birth: json['birth'] == null
          ? null
          : DateTime.parse(json['birth'] as String),
      gender: json['gender'] as String?,
      sleepPlan: json['sleepPlan'] as String?,
      sleepPlanDays: json['sleepPlanDays'] as int? ?? 0,
      sleepPlanUpdatedAt: json['sleepPlanUpdatedAt'] == null
          ? null
          : DateTime.parse(json['sleepPlanUpdatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'birth': instance.birth?.toIso8601String(),
      'gender': instance.gender,
      'sleepPlan': instance.sleepPlan,
      'sleepPlanDays': instance.sleepPlanDays,
      'sleepPlanUpdatedAt': instance.sleepPlanUpdatedAt?.toIso8601String(),
    };

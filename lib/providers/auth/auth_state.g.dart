// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthStateImpl _$$AuthStateImplFromJson(Map<String, dynamic> json) =>
    _$AuthStateImpl(
      token: json['token'] as String? ?? '',
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      sleepRecords: (json['sleepRecords'] as List<dynamic>?)
              ?.map((e) => SleepRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AuthStateImplToJson(_$AuthStateImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'sleepRecords': instance.sleepRecords,
    };

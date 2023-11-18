// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackgroundStateImpl _$$BackgroundStateImplFromJson(
        Map<String, dynamic> json) =>
    _$BackgroundStateImpl(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>).map(
                    (k, e) => MapEntry(DateTime.parse(k), e),
                  ))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BackgroundStateImplToJson(
        _$BackgroundStateImpl instance) =>
    <String, dynamic>{
      'events': instance.events
          .map((e) => e.map((k, e) => MapEntry(k.toIso8601String(), e)))
          .toList(),
    };

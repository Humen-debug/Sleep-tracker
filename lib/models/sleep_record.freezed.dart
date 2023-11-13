// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SleepRecord _$SleepRecordFromJson(Map<String, dynamic> json) {
  return _SleepRecord.fromJson(json);
}

/// @nodoc
mixin _$SleepRecord {
  String get id => throw _privateConstructorUsedError;

  /// User input of the bedtime.
  ///
  /// Must not be null.
  DateTime get start => throw _privateConstructorUsedError;

  /// User input of the estimated time of wake-up.
  ///
  /// Must not be null.
  DateTime get end => throw _privateConstructorUsedError;

  /// User input of actual wake up time.
  ///
  /// It can be used to calculate the regularity.
  DateTime? get wakeUpAt => throw _privateConstructorUsedError;

  /// Overall % of sleep efficiency. It is based on the data results from
  /// [sleepEfficiency].
  ///
  /// Only accepts 0 - 1.
  double? get sleepEfficiency => throw _privateConstructorUsedError;

  /// Movement activity logs.
  List<SleepEvent> get events => throw _privateConstructorUsedError;

  /// Overall % of sleep quality. It is based on the user input.
  ///
  /// Only accepts 0 - 1.
  double? get sleepQuality => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SleepRecordCopyWith<SleepRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepRecordCopyWith<$Res> {
  factory $SleepRecordCopyWith(
          SleepRecord value, $Res Function(SleepRecord) then) =
      _$SleepRecordCopyWithImpl<$Res, SleepRecord>;
  @useResult
  $Res call(
      {String id,
      DateTime start,
      DateTime end,
      DateTime? wakeUpAt,
      double? sleepEfficiency,
      List<SleepEvent> events,
      double? sleepQuality});
}

/// @nodoc
class _$SleepRecordCopyWithImpl<$Res, $Val extends SleepRecord>
    implements $SleepRecordCopyWith<$Res> {
  _$SleepRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? start = null,
    Object? end = null,
    Object? wakeUpAt = freezed,
    Object? sleepEfficiency = freezed,
    Object? events = null,
    Object? sleepQuality = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wakeUpAt: freezed == wakeUpAt
          ? _value.wakeUpAt
          : wakeUpAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sleepEfficiency: freezed == sleepEfficiency
          ? _value.sleepEfficiency
          : sleepEfficiency // ignore: cast_nullable_to_non_nullable
              as double?,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<SleepEvent>,
      sleepQuality: freezed == sleepQuality
          ? _value.sleepQuality
          : sleepQuality // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SleepRecordImplCopyWith<$Res>
    implements $SleepRecordCopyWith<$Res> {
  factory _$$SleepRecordImplCopyWith(
          _$SleepRecordImpl value, $Res Function(_$SleepRecordImpl) then) =
      __$$SleepRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime start,
      DateTime end,
      DateTime? wakeUpAt,
      double? sleepEfficiency,
      List<SleepEvent> events,
      double? sleepQuality});
}

/// @nodoc
class __$$SleepRecordImplCopyWithImpl<$Res>
    extends _$SleepRecordCopyWithImpl<$Res, _$SleepRecordImpl>
    implements _$$SleepRecordImplCopyWith<$Res> {
  __$$SleepRecordImplCopyWithImpl(
      _$SleepRecordImpl _value, $Res Function(_$SleepRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? start = null,
    Object? end = null,
    Object? wakeUpAt = freezed,
    Object? sleepEfficiency = freezed,
    Object? events = null,
    Object? sleepQuality = freezed,
  }) {
    return _then(_$SleepRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wakeUpAt: freezed == wakeUpAt
          ? _value.wakeUpAt
          : wakeUpAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sleepEfficiency: freezed == sleepEfficiency
          ? _value.sleepEfficiency
          : sleepEfficiency // ignore: cast_nullable_to_non_nullable
              as double?,
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<SleepEvent>,
      sleepQuality: freezed == sleepQuality
          ? _value.sleepQuality
          : sleepQuality // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepRecordImpl implements _SleepRecord {
  _$SleepRecordImpl(
      {required this.id,
      required this.start,
      required this.end,
      this.wakeUpAt,
      this.sleepEfficiency,
      final List<SleepEvent> events = const [],
      this.sleepQuality})
      : assert(end.isAfter(start), 'end must be after start.'),
        assert(
            sleepEfficiency == null ||
                sleepEfficiency >= 0 && sleepEfficiency <= 1,
            'sleepEfficiency must be in range of 0 to 1.'),
        assert(sleepQuality == null || sleepQuality >= 0 && sleepQuality <= 1,
            'sleepQuality must be in range of 0 to 1.'),
        _events = events;

  factory _$SleepRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepRecordImplFromJson(json);

  @override
  final String id;

  /// User input of the bedtime.
  ///
  /// Must not be null.
  @override
  final DateTime start;

  /// User input of the estimated time of wake-up.
  ///
  /// Must not be null.
  @override
  final DateTime end;

  /// User input of actual wake up time.
  ///
  /// It can be used to calculate the regularity.
  @override
  final DateTime? wakeUpAt;

  /// Overall % of sleep efficiency. It is based on the data results from
  /// [sleepEfficiency].
  ///
  /// Only accepts 0 - 1.
  @override
  final double? sleepEfficiency;

  /// Movement activity logs.
  final List<SleepEvent> _events;

  /// Movement activity logs.
  @override
  @JsonKey()
  List<SleepEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  /// Overall % of sleep quality. It is based on the user input.
  ///
  /// Only accepts 0 - 1.
  @override
  final double? sleepQuality;

  @override
  String toString() {
    return 'SleepRecord(id: $id, start: $start, end: $end, wakeUpAt: $wakeUpAt, sleepEfficiency: $sleepEfficiency, events: $events, sleepQuality: $sleepQuality)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.wakeUpAt, wakeUpAt) ||
                other.wakeUpAt == wakeUpAt) &&
            (identical(other.sleepEfficiency, sleepEfficiency) ||
                other.sleepEfficiency == sleepEfficiency) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.sleepQuality, sleepQuality) ||
                other.sleepQuality == sleepQuality));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      start,
      end,
      wakeUpAt,
      sleepEfficiency,
      const DeepCollectionEquality().hash(_events),
      sleepQuality);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepRecordImplCopyWith<_$SleepRecordImpl> get copyWith =>
      __$$SleepRecordImplCopyWithImpl<_$SleepRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepRecordImplToJson(
      this,
    );
  }
}

abstract class _SleepRecord implements SleepRecord {
  factory _SleepRecord(
      {required final String id,
      required final DateTime start,
      required final DateTime end,
      final DateTime? wakeUpAt,
      final double? sleepEfficiency,
      final List<SleepEvent> events,
      final double? sleepQuality}) = _$SleepRecordImpl;

  factory _SleepRecord.fromJson(Map<String, dynamic> json) =
      _$SleepRecordImpl.fromJson;

  @override
  String get id;
  @override

  /// User input of the bedtime.
  ///
  /// Must not be null.
  DateTime get start;
  @override

  /// User input of the estimated time of wake-up.
  ///
  /// Must not be null.
  DateTime get end;
  @override

  /// User input of actual wake up time.
  ///
  /// It can be used to calculate the regularity.
  DateTime? get wakeUpAt;
  @override

  /// Overall % of sleep efficiency. It is based on the data results from
  /// [sleepEfficiency].
  ///
  /// Only accepts 0 - 1.
  double? get sleepEfficiency;
  @override

  /// Movement activity logs.
  List<SleepEvent> get events;
  @override

  /// Overall % of sleep quality. It is based on the user input.
  ///
  /// Only accepts 0 - 1.
  double? get sleepQuality;
  @override
  @JsonKey(ignore: true)
  _$$SleepRecordImplCopyWith<_$SleepRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SleepEvent _$SleepEventFromJson(Map<String, dynamic> json) {
  return _SleepEvent.fromJson(json);
}

/// @nodoc
mixin _$SleepEvent {
  String? get id => throw _privateConstructorUsedError;

  /// Intensity of movement event.
  double get intensity => throw _privateConstructorUsedError;

  /// Movement event log date/time.
  DateTime get time => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SleepEventCopyWith<SleepEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepEventCopyWith<$Res> {
  factory $SleepEventCopyWith(
          SleepEvent value, $Res Function(SleepEvent) then) =
      _$SleepEventCopyWithImpl<$Res, SleepEvent>;
  @useResult
  $Res call({String? id, double intensity, DateTime time});
}

/// @nodoc
class _$SleepEventCopyWithImpl<$Res, $Val extends SleepEvent>
    implements $SleepEventCopyWith<$Res> {
  _$SleepEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? intensity = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SleepEventImplCopyWith<$Res>
    implements $SleepEventCopyWith<$Res> {
  factory _$$SleepEventImplCopyWith(
          _$SleepEventImpl value, $Res Function(_$SleepEventImpl) then) =
      __$$SleepEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, double intensity, DateTime time});
}

/// @nodoc
class __$$SleepEventImplCopyWithImpl<$Res>
    extends _$SleepEventCopyWithImpl<$Res, _$SleepEventImpl>
    implements _$$SleepEventImplCopyWith<$Res> {
  __$$SleepEventImplCopyWithImpl(
      _$SleepEventImpl _value, $Res Function(_$SleepEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? intensity = null,
    Object? time = null,
  }) {
    return _then(_$SleepEventImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepEventImpl extends _SleepEvent {
  const _$SleepEventImpl({this.id, required this.intensity, required this.time})
      : super._();

  factory _$SleepEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepEventImplFromJson(json);

  @override
  final String? id;

  /// Intensity of movement event.
  @override
  final double intensity;

  /// Movement event log date/time.
  @override
  final DateTime time;

  @override
  String toString() {
    return 'SleepEvent(id: $id, intensity: $intensity, time: $time)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, intensity, time);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepEventImplCopyWith<_$SleepEventImpl> get copyWith =>
      __$$SleepEventImplCopyWithImpl<_$SleepEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepEventImplToJson(
      this,
    );
  }
}

abstract class _SleepEvent extends SleepEvent {
  const factory _SleepEvent(
      {final String? id,
      required final double intensity,
      required final DateTime time}) = _$SleepEventImpl;
  const _SleepEvent._() : super._();

  factory _SleepEvent.fromJson(Map<String, dynamic> json) =
      _$SleepEventImpl.fromJson;

  @override
  String? get id;
  @override

  /// Intensity of movement event.
  double get intensity;
  @override

  /// Movement event log date/time.
  DateTime get time;
  @override
  @JsonKey(ignore: true)
  _$$SleepEventImplCopyWith<_$SleepEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

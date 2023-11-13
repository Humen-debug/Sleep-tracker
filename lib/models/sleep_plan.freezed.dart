// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SleepPlan _$SleepPlanFromJson(Map<String, dynamic> json) {
  return _SleepPlan.fromJson(json);
}

/// @nodoc
mixin _$SleepPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get desc => throw _privateConstructorUsedError;

  /// [sleepMinutes] determines the sleep intervals in minutes.
  ///
  /// Must not be empty.
  List<double> get sleepMinutes => throw _privateConstructorUsedError;

  /// [targets]  stores the descriptions of people that the plan is suited to
  List<String> get targets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SleepPlanCopyWith<SleepPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepPlanCopyWith<$Res> {
  factory $SleepPlanCopyWith(SleepPlan value, $Res Function(SleepPlan) then) =
      _$SleepPlanCopyWithImpl<$Res, SleepPlan>;
  @useResult
  $Res call(
      {String id,
      String name,
      String desc,
      List<double> sleepMinutes,
      List<String> targets});
}

/// @nodoc
class _$SleepPlanCopyWithImpl<$Res, $Val extends SleepPlan>
    implements $SleepPlanCopyWith<$Res> {
  _$SleepPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? desc = null,
    Object? sleepMinutes = null,
    Object? targets = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      sleepMinutes: null == sleepMinutes
          ? _value.sleepMinutes
          : sleepMinutes // ignore: cast_nullable_to_non_nullable
              as List<double>,
      targets: null == targets
          ? _value.targets
          : targets // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SleepPlanImplCopyWith<$Res>
    implements $SleepPlanCopyWith<$Res> {
  factory _$$SleepPlanImplCopyWith(
          _$SleepPlanImpl value, $Res Function(_$SleepPlanImpl) then) =
      __$$SleepPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String desc,
      List<double> sleepMinutes,
      List<String> targets});
}

/// @nodoc
class __$$SleepPlanImplCopyWithImpl<$Res>
    extends _$SleepPlanCopyWithImpl<$Res, _$SleepPlanImpl>
    implements _$$SleepPlanImplCopyWith<$Res> {
  __$$SleepPlanImplCopyWithImpl(
      _$SleepPlanImpl _value, $Res Function(_$SleepPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? desc = null,
    Object? sleepMinutes = null,
    Object? targets = null,
  }) {
    return _then(_$SleepPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      sleepMinutes: null == sleepMinutes
          ? _value._sleepMinutes
          : sleepMinutes // ignore: cast_nullable_to_non_nullable
              as List<double>,
      targets: null == targets
          ? _value._targets
          : targets // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepPlanImpl implements _SleepPlan {
  _$SleepPlanImpl(
      {required this.id,
      required this.name,
      this.desc = '',
      required final List<double> sleepMinutes,
      final List<String> targets = const []})
      : assert(sleepMinutes.isNotEmpty, 'sleepMinutes must not be empty.'),
        _sleepMinutes = sleepMinutes,
        _targets = targets;

  factory _$SleepPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String desc;

  /// [sleepMinutes] determines the sleep intervals in minutes.
  ///
  /// Must not be empty.
  final List<double> _sleepMinutes;

  /// [sleepMinutes] determines the sleep intervals in minutes.
  ///
  /// Must not be empty.
  @override
  List<double> get sleepMinutes {
    if (_sleepMinutes is EqualUnmodifiableListView) return _sleepMinutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sleepMinutes);
  }

  /// [targets]  stores the descriptions of people that the plan is suited to
  final List<String> _targets;

  /// [targets]  stores the descriptions of people that the plan is suited to
  @override
  @JsonKey()
  List<String> get targets {
    if (_targets is EqualUnmodifiableListView) return _targets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targets);
  }

  @override
  String toString() {
    return 'SleepPlan(id: $id, name: $name, desc: $desc, sleepMinutes: $sleepMinutes, targets: $targets)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            const DeepCollectionEquality()
                .equals(other._sleepMinutes, _sleepMinutes) &&
            const DeepCollectionEquality().equals(other._targets, _targets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      desc,
      const DeepCollectionEquality().hash(_sleepMinutes),
      const DeepCollectionEquality().hash(_targets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepPlanImplCopyWith<_$SleepPlanImpl> get copyWith =>
      __$$SleepPlanImplCopyWithImpl<_$SleepPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepPlanImplToJson(
      this,
    );
  }
}

abstract class _SleepPlan implements SleepPlan {
  factory _SleepPlan(
      {required final String id,
      required final String name,
      final String desc,
      required final List<double> sleepMinutes,
      final List<String> targets}) = _$SleepPlanImpl;

  factory _SleepPlan.fromJson(Map<String, dynamic> json) =
      _$SleepPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get desc;
  @override

  /// [sleepMinutes] determines the sleep intervals in minutes.
  ///
  /// Must not be empty.
  List<double> get sleepMinutes;
  @override

  /// [targets]  stores the descriptions of people that the plan is suited to
  List<String> get targets;
  @override
  @JsonKey(ignore: true)
  _$$SleepPlanImplCopyWith<_$SleepPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

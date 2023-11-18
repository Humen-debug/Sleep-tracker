// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'background_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BackgroundState _$BackgroundStateFromJson(Map<String, dynamic> json) {
  return _BackgroundState.fromJson(json);
}

/// @nodoc
mixin _$BackgroundState {
  List<Map<DateTime, Object?>> get events => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BackgroundStateCopyWith<BackgroundState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackgroundStateCopyWith<$Res> {
  factory $BackgroundStateCopyWith(
          BackgroundState value, $Res Function(BackgroundState) then) =
      _$BackgroundStateCopyWithImpl<$Res, BackgroundState>;
  @useResult
  $Res call({List<Map<DateTime, Object?>> events});
}

/// @nodoc
class _$BackgroundStateCopyWithImpl<$Res, $Val extends BackgroundState>
    implements $BackgroundStateCopyWith<$Res> {
  _$BackgroundStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
  }) {
    return _then(_value.copyWith(
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<Map<DateTime, Object?>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BackgroundStateImplCopyWith<$Res>
    implements $BackgroundStateCopyWith<$Res> {
  factory _$$BackgroundStateImplCopyWith(_$BackgroundStateImpl value,
          $Res Function(_$BackgroundStateImpl) then) =
      __$$BackgroundStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Map<DateTime, Object?>> events});
}

/// @nodoc
class __$$BackgroundStateImplCopyWithImpl<$Res>
    extends _$BackgroundStateCopyWithImpl<$Res, _$BackgroundStateImpl>
    implements _$$BackgroundStateImplCopyWith<$Res> {
  __$$BackgroundStateImplCopyWithImpl(
      _$BackgroundStateImpl _value, $Res Function(_$BackgroundStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
  }) {
    return _then(_$BackgroundStateImpl(
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<Map<DateTime, Object?>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BackgroundStateImpl extends _BackgroundState {
  const _$BackgroundStateImpl(
      {final List<Map<DateTime, Object?>> events = const []})
      : _events = events,
        super._();

  factory _$BackgroundStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackgroundStateImplFromJson(json);

  final List<Map<DateTime, Object?>> _events;
  @override
  @JsonKey()
  List<Map<DateTime, Object?>> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  String toString() {
    return 'BackgroundState(events: $events)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackgroundStateImpl &&
            const DeepCollectionEquality().equals(other._events, _events));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_events));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BackgroundStateImplCopyWith<_$BackgroundStateImpl> get copyWith =>
      __$$BackgroundStateImplCopyWithImpl<_$BackgroundStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackgroundStateImplToJson(
      this,
    );
  }
}

abstract class _BackgroundState extends BackgroundState {
  const factory _BackgroundState({final List<Map<DateTime, Object?>> events}) =
      _$BackgroundStateImpl;
  const _BackgroundState._() : super._();

  factory _BackgroundState.fromJson(Map<String, dynamic> json) =
      _$BackgroundStateImpl.fromJson;

  @override
  List<Map<DateTime, Object?>> get events;
  @override
  @JsonKey(ignore: true)
  _$$BackgroundStateImplCopyWith<_$BackgroundStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AuthState _$AuthStateFromJson(Map<String, dynamic> json) {
  return _AuthState.fromJson(json);
}

/// @nodoc
mixin _$AuthState {
  String get token => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;
  List<SleepRecord> get sleepRecords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call({String token, User? user, List<SleepRecord> sleepRecords});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? user = freezed,
    Object? sleepRecords = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      sleepRecords: null == sleepRecords
          ? _value.sleepRecords
          : sleepRecords // ignore: cast_nullable_to_non_nullable
              as List<SleepRecord>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
          _$AuthStateImpl value, $Res Function(_$AuthStateImpl) then) =
      __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, User? user, List<SleepRecord> sleepRecords});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
      _$AuthStateImpl _value, $Res Function(_$AuthStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? user = freezed,
    Object? sleepRecords = null,
  }) {
    return _then(_$AuthStateImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      sleepRecords: null == sleepRecords
          ? _value._sleepRecords
          : sleepRecords // ignore: cast_nullable_to_non_nullable
              as List<SleepRecord>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl(
      {this.token = '',
      this.user,
      final List<SleepRecord> sleepRecords = const []})
      : _sleepRecords = sleepRecords,
        super._();

  factory _$AuthStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthStateImplFromJson(json);

  @override
  @JsonKey()
  final String token;
  @override
  final User? user;
  final List<SleepRecord> _sleepRecords;
  @override
  @JsonKey()
  List<SleepRecord> get sleepRecords {
    if (_sleepRecords is EqualUnmodifiableListView) return _sleepRecords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sleepRecords);
  }

  @override
  String toString() {
    return 'AuthState(token: $token, user: $user, sleepRecords: $sleepRecords)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other._sleepRecords, _sleepRecords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, token, user,
      const DeepCollectionEquality().hash(_sleepRecords));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthStateImplToJson(
      this,
    );
  }
}

abstract class _AuthState extends AuthState {
  const factory _AuthState(
      {final String token,
      final User? user,
      final List<SleepRecord> sleepRecords}) = _$AuthStateImpl;
  const _AuthState._() : super._();

  factory _AuthState.fromJson(Map<String, dynamic> json) =
      _$AuthStateImpl.fromJson;

  @override
  String get token;
  @override
  User? get user;
  @override
  List<SleepRecord> get sleepRecords;
  @override
  @JsonKey(ignore: true)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

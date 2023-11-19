import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/providers/persistance_state.dart';
import 'package:sleep_tracker/utils/json_secure_sync.dart';

part 'background_state.freezed.dart';
part 'background_state.g.dart';

typedef BackgroundEvents = Map<DateTime, Object?>;

@freezed
class BackgroundState with _$BackgroundState implements PersistentState<BackgroundState> {
  const factory BackgroundState({
    @Default({}) BackgroundEvents events,
  }) = _BackgroundState;
  const BackgroundState._();

  factory BackgroundState.fromJson(Map<String, Object?> json) => _$BackgroundStateFromJson(json);

  static const _localStorageKey = 'backgroundState';
  @override
  Future<bool> localSave() async {
    final value = toJson();
    try {
      return JsonSecureSync.save(key: _localStorageKey, value: value);
    } catch (e, s) {
      AppLogger.I.e('Error saving backgroundState', error: e, stackTrace: s);

      return false;
    }
  }

  @override
  Future<bool> localDelete() async {
    try {
      return await JsonSecureSync.delete(key: _localStorageKey);
    } catch (e, s) {
      AppLogger.I.e('Error deleting backgroundState', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<BackgroundState?> fromStorage() async {
    try {
      final value = await JsonSecureSync.get(key: _localStorageKey);
      if (value == null) {
        return null;
      }
      final data = BackgroundState.fromJson(value);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}

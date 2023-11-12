import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.ref}) : super(const AuthState());
  StateNotifierProviderRef<AuthNotifier, AuthState> ref;

  Future<bool> restoreFromStorage() async {
    try {
      debugPrint('Restoring AuthState from SecureStorage.');
      final s = await state.fromStorage();
      if (s == null) {
        return false;
      }
      debugPrint('AuthState found in SecureStorage');
      debugPrint(s.toString());
      state = s;
      return true;
    } catch (e, s) {
      debugPrintStack(stackTrace: s, label: 'Error restoring AuthState from SecureStorage $e');
      return false;
    }
  }

  Future<bool> syncEverything() async {
    try {
      await Future.wait([]);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<void> init() async {
    await restoreFromStorage();

    if (state.token.isNotEmpty && await syncEverything()) {
      await state.localSave();
    }
  }

  Future<void> setUser(User? user) async {
    state = state.copyWith(user: user);
    await state.localSave();
  }

  Future<List<SleepRecord>> syncSleepRecords() async {
    await state.localSave();
    return [];
  }

  Future<void> createSleepRecord({required DateTimeRange range}) async {
    assert(range.end.isAfter(DateTime.now()), 'range.end ${range.end} must be after now ${DateTime.now()}');
    final String id = const Uuid().v4();
    // todo: create record in graphql server for new ID;
    final record = SleepRecord(id: id, start: range.start, end: range.end);
    state = state.copyWith(sleepRecords: [record, ...state.sleepRecords]);
    await state.localSave();
  }

  /// Update the latest record in list.
  Future<void> updateSleepRecord({DateTimeRange? range, double? sleepQuality, DateTime? wakeUpAt}) async {
    assert(range == null || range.end.isAfter(DateTime.now()),
        'range.end ${range.end} must be after now ${DateTime.now()}');
    if (state.sleepRecords.isNotEmpty) {
      SleepRecord newRecord = state.sleepRecords.first.copyWith(sleepQuality: sleepQuality, wakeUpAt: wakeUpAt);
      if (range != null) newRecord = newRecord.copyWith(start: range.start, end: range.end);

      state = state.copyWith(sleepRecords: [newRecord, ...state.sleepRecords.sublist(1)]);
      await state.localSave();
    }
  }

  // dev
  Future<void> resetSleepRecords() async {
    state = state.copyWith(sleepRecords: []);
    await state.localSave();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref: ref);
});

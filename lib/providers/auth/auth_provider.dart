import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';

Stream<DateTime> getPeriodicStream([Duration interval = const Duration(seconds: 1)]) async* {
  yield* Stream.periodic(interval, (_) {
    return DateTime.now();
  }).asyncMap((event) async => event);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.ref}) : super(const AuthState());
  StateNotifierProviderRef<AuthNotifier, AuthState> ref;
  static const uuid = Uuid();
  StreamSubscription? _secondSubscription;
  StreamSubscription? _accelerometerSubscription;

  Future<bool> restoreFromStorage() async {
    try {
      AppLogger.I.i('Restoring AuthState from SecureStorage.');
      final s = await state.fromStorage();
      if (s == null) {
        return false;
      }
      AppLogger.I.i('AuthState found in SecureStorage');

      state = s;
      return true;
    } catch (e, s) {
      AppLogger.I.e('Error restoring AuthState from SecureStorage', error: e, stackTrace: s);

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

    initSensors();
  }

  @override
  Future<void> dispose() async {
    _secondSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  /// Set up a stream listener to the user's accelerometer event.
  /// If there any event comes and user is sleeping (i.e. [state.sleepStatus] == [SleepStatus.sleeping])
  /// update the current sleep activities.

  void initSensors() {
    AppLogger.I.i('Initiate subscriptions');

    DateTime first = DateTime.now().copyWith(millisecond: 0, microsecond: 0);
    double meanMagnitudeWithinSecond = 0.0;
    int count = 0;
    double sleepIndex = sleepIndex0;
    const int timeConst = 18 * 60 + 30;
    const double k = 0.19;
    // const double filterBase = 0.02;

    _accelerometerSubscription ??= userAccelerometerEvents.listen(
      (event) {
        final DateTime now = DateTime.now();
        count++;
        final double magnitude =
            math.max(math.sqrt(math.pow(event.x, 2) + math.pow(event.y, 2) + math.pow(event.z, 2)) - 1, 0.0);
        final DateTime next = first.add(const Duration(seconds: 1));
        if (!now.isAfter(next)) {
          meanMagnitudeWithinSecond = (meanMagnitudeWithinSecond * (count - 1) + magnitude) / count;
        } else {
          // Store sleep event logs
          if (state.sleepRecords.firstOrNull != null) {
            SleepRecord record = state.sleepRecords.first;
            sleepIndex = math.exp(-1 / timeConst) * sleepIndex + k * meanMagnitudeWithinSecond;
            record = record.copyWith(events: [...record.events, SleepEvent(intensity: sleepIndex, time: now)]);
            state = state.copyWith(sleepRecords: [record, ...state.sleepRecords.sublist(1)]);
            AppLogger.I.i('Update sleep event ($now):$meanMagnitudeWithinSecond, sleepIndex: $sleepIndex');
          }
          first = next;
          count = 0;
          meanMagnitudeWithinSecond = magnitude;
        }
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
    _secondSubscription ??= getPeriodicStream().listen((now) async {
      switch (state.sleepStatus) {
        case SleepStatus.sleeping:
          if (_accelerometerSubscription!.isPaused) {
            // reset
            sleepIndex = sleepIndex0;
            count = 0;
            first = DateTime.now().copyWith(millisecond: 0, microsecond: 0);
            meanMagnitudeWithinSecond = 0.0;
            _accelerometerSubscription!.resume();
          }
          break;
        case SleepStatus.awaken:
        case SleepStatus.goToBed:
          if (!_accelerometerSubscription!.isPaused) _accelerometerSubscription!.pause();
          break;
      }
    });
  }

  // https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8976254/ (Table 1)
  void tackScreenActivity() {}

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
    final String id = uuid.v4();
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
      SleepRecord newRecord = state.sleepRecords.first.copyWith(sleepQuality: sleepQuality);

      if (range != null) newRecord = newRecord.copyWith(start: range.start, end: range.end);
      if (wakeUpAt != null) newRecord = newRecord.copyWith(wakeUpAt: wakeUpAt);

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
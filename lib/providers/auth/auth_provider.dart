import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sleep_tracker/utils/background/background_controller.dart';
import 'package:sleep_tracker/utils/background/background_state.dart';
import 'package:sleep_tracker/utils/demo_user.dart';
import 'package:uuid/uuid.dart';

Stream<DateTime> getPeriodicStream([Duration interval = const Duration(seconds: 1)]) async* {
  yield* Stream.periodic(interval, (_) {
    return DateTime.now();
  }).asyncMap((event) async => event);
}

const int timeConst = 18 * 60 + 30;
const double k = 0.19;

double sleepIndexFormula(double previousSleepIndex, double mean) {
  return math.exp(-1 / timeConst) * previousSleepIndex + k * mean;
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
      await Future.wait([
        syncUser(),
        syncSleepRecords(),
      ]);
    } catch (e, s) {
      AppLogger.I.e('Error Syncing AuthState', error: e, stackTrace: s);
      return false;
    }
    return true;
  }

  Future<void> init() async {
    await restoreFromStorage();
    // TODO: add back the token verification after creating a demo user
    if (await syncEverything()) {
      await state.localSave();
    }
    if (await restoreFromBackground()) {
      await state.localSave();
      // clear background
      AppLogger.I.i('AuthState clear BackgroundState.');
      await BackgroundController.clear();
    }

    initSensors();
  }

  @override
  Future<void> dispose() async {
    _secondSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  /// Restores accelerometer's data collections from background.
  ///
  Future<bool> restoreFromBackground() async {
    try {
      final background = BackgroundController.state;

      // Insert in-between sleep events with background's data collections, based
      // on the latest sleep record only.
      SleepRecord? record = state.sleepRecords.firstOrNull;

      // if there is no record, or the latest record has been already completed
      if (record == null || (record.wakeUpAt != null && record.wakeUpAt!.isBefore(DateTime.now()))) return true;

      DateTime first = record.start;
      double meanMagnitudeWithinSecond = 0.0;
      int count = 0;
      // dev
      int total = 0;
      final newEvents = BackgroundEvents.from(background.events)..removeWhere((key, value) => key.isBefore(first));
      if (newEvents.isEmpty) return true;
      DateTime next = first.add(const Duration(seconds: 1));
      for (final entry in newEvents.entries) {
        final DateTime timestamp = entry.key;
        final double magnitude = entry.value as double;
        count++;
        total++;
        if (!timestamp.isAfter(next)) {
          meanMagnitudeWithinSecond = (meanMagnitudeWithinSecond * (count - 1) + magnitude) / count;
        } else {
          // Insert sleep event per seconds
          final int index = record!.events.indexWhere((event) => !event.time.isBefore(timestamp));
          if (index > 0) {
            double sleepIndex = record.events[index].intensity;
            sleepIndex = sleepIndexFormula(sleepIndex, meanMagnitudeWithinSecond);
            List<SleepEvent> recordEvents = List<SleepEvent>.from(record.events);
            recordEvents.insert(index, SleepEvent(intensity: sleepIndex, time: timestamp));
            record = record.copyWith(events: recordEvents);
            state = state.copyWith(sleepRecords: [record, ...state.sleepRecords.sublist(1)]);
          }
          next = next.add(const Duration(seconds: 1));
          count = 0;
          meanMagnitudeWithinSecond = magnitude;
        }
      }
      AppLogger.I.i(
          'AuthState inserted $total events from BackgroundState between ${newEvents.keys.first} and ${newEvents.keys.last}.');
      return true;
    } catch (e, s) {
      AppLogger.I.e('Error restoring BackgroundState from BackgroundController', error: e, stackTrace: s);
      return false;
    }
  }

  // TODO: Fix low app performance of running acceleromenter on front-end for about 3 hours

  /// Set up a stream listener to the user's accelerometer event.
  /// If there any event comes and user is sleeping (i.e. [state.sleepStatus] == [SleepStatus.sleeping])
  /// update the current sleep activities.
  ///
  /// Sleep-wake algorithm research on https://charm-icebreaker-7a6.notion.site/Sleep-Tracker-Research-c27e9d0bfc6d474395d76bcf9c01f4a0?pvs=4.
  void initSensors() {
    AppLogger.I.i('Initiate subscriptions');

    DateTime first = DateTime.now().copyWith(millisecond: 0, microsecond: 0);
    double meanMagnitudeWithinSecond = 0.0;
    int count = 0;
    double sleepIndex = state.sleepStatus == SleepStatus.sleeping
        ? state.sleepRecords.first.events.lastOrNull?.intensity ?? sleepIndex0
        : sleepIndex0;

    _accelerometerSubscription ??= userAccelerometerEvents.listen(
      (event) async {
        final DateTime now = DateTime.now();
        count++;
        final double magnitude =
            math.max(math.sqrt(math.pow(event.x, 2) + math.pow(event.y, 2) + math.pow(event.z, 2)) - 1, 0.0);
        final DateTime next = first.add(const Duration(seconds: 1));
        if (!now.isAfter(next)) {
          meanMagnitudeWithinSecond = (meanMagnitudeWithinSecond * (count - 1) + magnitude) / count;
        } else {
          // Store sleep event logs per second
          if (state.sleepStatus == SleepStatus.sleeping) {
            SleepRecord record = state.sleepRecords.first;
            sleepIndex = sleepIndexFormula(sleepIndex, meanMagnitudeWithinSecond);
            record = record.copyWith(events: [...record.events, SleepEvent(intensity: sleepIndex, time: now)]);
            state = state.copyWith(sleepRecords: [record, ...state.sleepRecords.sublist(1)]);
            await state.localSave();
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

  Future<User> syncUser() async {
    final me = createUser();
    await setUser(me);
    return me;
  }

  Future<List<SleepRecord>> syncSleepRecords() async {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    final res = createRecords(yesterday.subtract(const Duration(days: 180)), yesterday);
    state = state.copyWith(sleepRecords: res);
    await state.localSave();
    return res;
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

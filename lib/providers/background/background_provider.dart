import 'dart:async';
import 'dart:math' as math;

import 'package:background_fetch/background_fetch.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/providers/background/background_state.dart';

/// Returns a provider to notify background storage
/// when the app is minimized or terminated.
class BackgroundNotifier extends StateNotifier<BackgroundState> {
  BackgroundNotifier() : super(const BackgroundState());
  BackgroundState state = const BackgroundState();

  Future<bool> restoreFromStorage() async {
    try {
      AppLogger.I.i('Restoring BackgroundState from SecureStorage.');
      final s = await state.fromStorage();
      if (s == null) {
        return false;
      }
      AppLogger.I.i('BackgroundState found in SecureStorage');

      state = s;
      return true;
    } catch (e, s) {
      AppLogger.I.e('Error restoring BackgroundState from SecureStorage', error: e, stackTrace: s);

      return false;
    }
  }

  /// Initialize the background_fetch platform service to
  /// retrieve accelerometer's data.
  Future<void> init() async {
    try {
      var status = await BackgroundFetch.configure(
          BackgroundFetchConfig(
              minimumFetchInterval: 15,
              forceAlarmManager: false,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.NONE),
          _onBackgroundFetch,
          _onBackgroundFetchTimeout);
      AppLogger.I.i('Configure BackgroundFetch $status');
    } catch (e, s) {
      AppLogger.I.e('Error configure BackgroundFetch', error: e, stackTrace: s);
    }
  }

  void _onBackgroundFetch(String taskId) async {
    // This is the fetch-event callback.
    AppLogger.I.i("[BackgroundFetch] Event received: $taskId");
    const Duration epoch = Duration(seconds: 30);

    final StreamSubscription accelerometerSubscription = userAccelerometerEvents.listen((event) {
      DateTime timestamp = DateTime.now();

      final double magnitude =
          math.max(math.sqrt(math.pow(event.x, 2) + math.pow(event.y, 2) + math.pow(event.z, 2)) - 1, 0.0);
      state = state.copyWith(events: [
        ...state.events,
        {timestamp: magnitude}
      ]);
    });
    await Future.delayed(epoch, () {
      accelerometerSubscription.cancel();
    });

    await state.localSave();
    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    AppLogger.I.i("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }
}

final backgroundProvider = StateNotifierProvider<BackgroundNotifier, BackgroundState>((ref) => BackgroundNotifier());

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sleep_tracker/components/sleep_timer/utils.dart';
import 'package:sleep_tracker/utils/date_time.dart';

class SleepTimerController extends ChangeNotifier {
  SleepTimerController({
    SleepTimerMode mode = SleepTimerMode.elapsed,
    DateTime? startTime,
    DateTime? endTime,
  })  : _mode = mode,
        _startTime = startTime,
        _endTime = endTime,
        assert(startTime != null ? (endTime?.isAfter(startTime) ?? true) : true);

  bool get isActive => _timer?.isActive ?? false;

  DateTime? _startTime;
  DateTime? get startTime => _startTime;

  DateTime? _endTime;
  DateTime? get endTime => _endTime;

  SleepTimerState get _state => _startTime != null && _endTime != null
      ? SleepTimerState.limited
      : _startTime != null && _endTime == null
          ? SleepTimerState.infinity
          : SleepTimerState.stop;

  Timer? _timer;

  SleepTimerMode _mode;
  bool get isElapsed => _mode == SleepTimerMode.elapsed;
  bool get ableToSwitchMode => _endTime != null;

  /// if there is no end time and the timer starts, let [_totalSeconds] becomes the total seconds per day.
  final int _defaultTotalSeconds = 24 * 3600;

  int get _totalSeconds {
    switch (_state) {
      case SleepTimerState.limited:
        return (_endTime!.millisecondsSinceEpoch ~/ 1000) - (_startTime!.millisecondsSinceEpoch ~/ 1000);
      case SleepTimerState.infinity:
        return _defaultTotalSeconds;
      default:
        return 0;
    }
  }

  /// In Elapsed Mode, progress is calculated by the [elapsedSeconds]/[_totalSeconds].
  /// In Remained Mode, progress is calculated by the [remainedSeconds]/[_totalSeconds].
  double get progress => _totalSeconds == 0
      ? 0
      : (_mode == SleepTimerMode.elapsed ? _elapsed?.inSeconds ?? 0 : _remained?.inSeconds ?? 0) / _totalSeconds;

  bool get showProgress => _state != SleepTimerState.infinity;

  Duration? _elapsed;
  Duration? get elapsed => _elapsed;
  String get elapsedTime => formatDuration(_elapsed);

  Duration? _remained;
  Duration? get remained => _remained;
  String get remainedTime => formatDuration(_remained);

  void start({required DateTime startTime, DateTime? endTime}) {
    _startTime = startTime;
    _endTime = endTime;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final int elapsedSeconds = (now.millisecondsSinceEpoch ~/ 1000) - (startTime.millisecondsSinceEpoch ~/ 1000);
      _elapsed = Duration(seconds: elapsedSeconds);

      if (endTime != null) {
        final int remainedSeconds = (endTime.millisecondsSinceEpoch ~/ 1000) - (now.millisecondsSinceEpoch ~/ 1000);
        _remained = Duration(seconds: remainedSeconds);
        // end the timer if endTime is set and now is after endTime
        if (now.isAfter(endTime)) {
          reset();
        }
      }

      notifyListeners();
    });
  }

  void pause() {
    if (isActive) {
      _timer?.cancel();
      notifyListeners();
    }
  }

  void reset() {
    if (isActive) {
      _timer?.cancel();
      _elapsed = null;
      _remained = null;
      _timer = null;
      _startTime = null;
      _endTime = null;
      _mode = SleepTimerMode.elapsed;
    }
    notifyListeners();
  }

  /// if end time is not null, it means there is remaining time between now and end time.
  /// therefore, [_mode] can be switched to [SleepTimerMode.remained]
  void switchMode() {
    if (!ableToSwitchMode) return;
    if (_mode == SleepTimerMode.elapsed) {
      _mode = SleepTimerMode.remained;
    } else {
      _mode = SleepTimerMode.elapsed;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}

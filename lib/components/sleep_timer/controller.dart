import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sleep_tracker/components/sleep_timer/utils.dart';
import 'package:sleep_tracker/utils/date_time.dart';

class SleepTimerController extends ChangeNotifier {
  SleepTimerController({
    SleepTimerDisplayMode displayMode = SleepTimerDisplayMode.elapsed,
    DateTime? start,
    DateTime? end,
    DateTime? nextStart,
    DateTime? nextEnd,
  })  : _displayMode = displayMode,
        _startTime = start,
        _endTime = end,
        _nextStart = nextStart,
        _nextEnd = nextEnd,
        assert(start == null || (end?.isAfter(start) ?? true), 'startTime $start must be on or before endTime $end.');

  // final WidgetRef ref;

  bool get isActive => _timer?.isActive ?? false;

  DateTime? _startTime;
  DateTime? get startTime => _startTime;

  DateTime? _endTime;
  DateTime? get endTime => _endTime;

  DateTime? _nextStart;
  DateTime? _nextEnd;

  SleepTimerState get _state => _startTime != null && _endTime != null
      ? SleepTimerState.limited
      : _startTime != null && _endTime == null
          ? SleepTimerState.infinity
          : SleepTimerState.stop;

  Timer? _timer;

  SleepTimerDisplayMode _displayMode;
  bool get isElapsed => _displayMode == SleepTimerDisplayMode.elapsed;
  bool get ableToSwitchMode => _endTime != null && _endTime!.isAfter(DateTime.now());

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

  /// In Elapsed Mode, progress is calculated by the [_elapsed.inSeconds]/[_totalSeconds].
  /// In Remained Mode, progress is calculated by the [_remained.inSeconds]/[_totalSeconds].
  double get progress => _totalSeconds == 0
      ? 0
      : (_displayMode == SleepTimerDisplayMode.elapsed ? _elapsed?.inSeconds ?? 0 : _remained?.inSeconds ?? 0) /
          _totalSeconds;

  bool get showProgress => _state != SleepTimerState.infinity;

  Duration? _elapsed;
  Duration? get elapsed => _elapsed;
  String get elapsedTime => formatDuration(_elapsed);

  Duration? _remained;
  Duration? get remained => _remained;
  String get remainedTime => formatDuration(_remained);

  void start({
    required DateTime startTime,
    DateTime? endTime,
    DateTime? nextStart,
    DateTime? nextEnd,
  }) {
    assert(endTime == null || startTime.isBefore(endTime), 'start $startTime must be before end $endTime.');
    assert(!startTime.isAfter(DateTime.now()), 'start $startTime must be before or on now ${DateTime.now()}');
    assert(nextEnd == null || (nextStart != null && (nextStart.isBefore(nextEnd))),
        'nextStart $nextStart must be before nextEnd $nextEnd.');
    reset();
    _startTime = startTime;
    _endTime = endTime;
    _nextStart = nextStart;
    _nextEnd = nextEnd;

    notifyListeners();

    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final int elapsedSeconds = (now.millisecondsSinceEpoch ~/ 1000) - (_startTime!.millisecondsSinceEpoch ~/ 1000);
      _elapsed = Duration(seconds: elapsedSeconds);

      if (_endTime != null) {
        final int remainedSeconds = (_endTime!.millisecondsSinceEpoch ~/ 1000) - (now.millisecondsSinceEpoch ~/ 1000);
        _remained = Duration(seconds: remainedSeconds);

        // End the timer if endTime is set and now is after endTime
        if (now.isAfter(_endTime!)) {
          /// If user has an upcoming start, restart the timer
          ///  with [_nextStart] and [_nextEnd].
          if (_nextStart != null) {
            print('restart timer: start($_nextStart) - end($_nextEnd)');
            start(startTime: _nextStart!, endTime: _nextEnd);
            _nextStart = null;
            _nextEnd = null;
          }
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
      _nextStart = null;
      _nextEnd = null;
      _displayMode = SleepTimerDisplayMode.elapsed;
      notifyListeners();
    }
  }

  /// if end time is not null, it means there is remaining time between now and end time.
  /// therefore, [_displayMode] can be switched to [SleepTimerDisplayMode.remained]
  void switchMode() {
    if (!ableToSwitchMode) return;
    if (_displayMode == SleepTimerDisplayMode.elapsed) {
      _displayMode = SleepTimerDisplayMode.remained;
    } else {
      _displayMode = SleepTimerDisplayMode.elapsed;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}

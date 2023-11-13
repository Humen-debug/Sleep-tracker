import 'package:flutter/material.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/providers/persistance_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/models/user.dart';
import 'package:sleep_tracker/utils/json_secure_sync.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

@freezed
class AuthState with _$AuthState implements PersistentState<AuthState> {
  const factory AuthState({
    @Default('') String token,
    User? user,
    @Default([]) List<SleepRecord> sleepRecords,
  }) = _AuthState;
  const AuthState._();

  factory AuthState.fromJson(Map<String, Object?> json) => _$AuthStateFromJson(json);

  bool get isLoggedIn => token.isNotEmpty && user != null;

  SleepStatus get sleepStatus {
    if (sleepRecords.isEmpty) return SleepStatus.awaken;
    final SleepRecord latest = sleepRecords.first;
    final DateTime now = DateTime.now();
    // If the latest sleep record hasn't started yet.
    if (latest.start.isAfter(now)) {
      return SleepStatus.goToBed;
    } else if (latest.wakeUpAt == null && latest.start.isBefore(now)) {
      return SleepStatus.sleeping;
    }

    return SleepStatus.awaken;
  }

  List<List<double?>> get monthlyMoods {
    if (sleepRecords.isEmpty) return [];

    Map<DateTime, double?> dailyAvgMood = {};

    int count = 1;
    // Assume the sleepRecords is sorted in descending order.
    // Reverse the sleepRecords, so that the monthlyMoods is in acceding order.
    for (int i = sleepRecords.length - 1; i >= 0; i--) {
      final record = sleepRecords[i];
      // Depends the mood value by sleep end time.
      final date = DateUtils.dateOnly(record.wakeUpAt ?? record.end);
      final double? value = record.sleepQuality;
      if (value != null) count++;
      if (dailyAvgMood.containsKey(date)) {
        dailyAvgMood.update(date, (avg) {
          if (avg == null && value == null) {
            return null;
          } else if (avg == null && value != null) {
            return value;
          } else {
            return (avg! + (value ?? 0)) / count;
          }
        });
      } else {
        count = 1;
        dailyAvgMood[date] = value;
      }
    }

    final DateTime start = DateUtils.dateOnly(sleepRecords.last.start).copyWith(day: 1);
    DateTime end = DateUtils.dateOnly(sleepRecords.first.end);
    end = end.copyWith(month: end.month + 1, day: 0);
    int monthToGenerate = DateUtils.monthDelta(start, end) + 1;
    final List<List<double?>> result = List.generate(monthToGenerate, (monthsToAdd) {
      final month = DateUtils.addMonthsToMonthDate(start, monthsToAdd);
      final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
      return List.generate(daysInMonth, (index) {
        final date = DateUtils.addDaysToDate(month, index);
        return dailyAvgMood[date];
      });
    });

    return result;
  }

  static const _localStorageKey = 'authState';
  @override
  Future<bool> localSave() async {
    final value = toJson();
    try {
      return JsonSecureSync.save(key: _localStorageKey, value: value);
    } catch (e, s) {
      AppLogger.I.e('Error saving authState', error: e, stackTrace: s);

      return false;
    }
  }

  @override
  Future<bool> localDelete() async {
    try {
      return await JsonSecureSync.delete(key: _localStorageKey);
    } catch (e, s) {
      AppLogger.I.e('Error deleting authState', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<AuthState?> fromStorage() async {
    try {
      final value = await JsonSecureSync.get(key: _localStorageKey);
      if (value == null) {
        return null;
      }
      final data = AuthState.fromJson(value);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}

enum SleepStatus { awaken, goToBed, sleeping }

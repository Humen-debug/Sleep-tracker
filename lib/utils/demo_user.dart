import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sleep_tracker/logger/logger.dart';
import 'package:sleep_tracker/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sleep_tracker/models/sleep_plan.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/models/user.dart';

const uuid = Uuid();

/// Returns a demo user who has already used this app for a month or longer.
///
User createUser() {
  const sleepPlanDays = 10;
  return User(
    id: uuid.v4(),
    name: 'Jennifer',
    email: 'jennifer@email.com',
    password: '12345678',
    sleepPlan: '1',
    sleepPlanDays: sleepPlanDays,
    sleepPlanUpdatedAt: DateTime.now().subtract(const Duration(days: sleepPlanDays)),
  );
}

/// Returns list of sleep record
List<SleepRecord> createRecords(DateTime start, DateTime end, [SleepPlan? plan]) {
  final now = DateTime.now();
  end = end.isAfter(now) ? now : end;
  assert(start.isBefore(end), 'start $start must be before end $end.');

  final List<SleepRecord> res = [];
  // Set a default planning
  plan ??= plans[1];
  while (!start.isAfter(end)) {
    final next = start.add(const Duration(days: 1));

    // For showing null data someday.
    bool hasData = math.Random().nextDouble() > 0.08;

    if (!hasData) {
      start = next;
      continue;
    }

    final List<SleepRecord> dayRes = [];

    for (int i = 0; i < plan.sleepMinutes.length; i++) {
      int minutes = math.Random().nextInt(24 * 60 - 1);
      // add minutes based on plan.sleepMinutes
      DateTime timestamp = DateUtils.dateOnly(start).add(Duration(minutes: minutes));
      if (dayRes.isNotEmpty) {
        final last = dayRes.last;
        while (timestamp.isBefore(last.wakeUpAt ?? last.end)) {
          timestamp = (last.wakeUpAt ?? last.end).add(Duration(minutes: minutes));
        }
        if (!timestamp.isBefore(next)) {
          break;
        }
      }

      final int sleepMinutes = (plan.sleepMinutes[i]).toInt();
      final int actualMinutes = (sleepMinutes * ((math.Random().nextInt(100) + 50) / 100)).toInt();
      final wakeUpAt = timestamp.add(Duration(minutes: actualMinutes));

      AppLogger.I.i('Creating records from $timestamp to $wakeUpAt with duration ${wakeUpAt.difference(timestamp)}');

      final List<SleepEvent> logs = [];
      double sleepIndex = sleepIndex0;

      // Ideally, the backgroundFetch stores 30 seconds accelerometer's data per 15 minutes.
      for (DateTime epoch = timestamp; epoch.isBefore(wakeUpAt); epoch = epoch.add(const Duration(minutes: 15))) {
        for (int second = 0; second < 30; second++) {
          double meanMagnitudeWithinSecond =
              math.Random().nextDouble() * math.pow(10, math.Random().nextDouble() >= 0.2 ? -4 : -1);
          sleepIndex = sleepIndexFormula(sleepIndex, meanMagnitudeWithinSecond);
          final time = epoch.add(Duration(seconds: i));
          logs.add(SleepEvent(intensity: sleepIndex, time: time));
        }
      }

      final record = SleepRecord(
        id: uuid.v4(),
        start: timestamp,
        wakeUpAt: wakeUpAt,
        end: timestamp.add(Duration(minutes: sleepMinutes.toInt())),
        sleepQuality: math.Random().nextDouble(),
        events: logs,
      );

      dayRes.add(record);
    }
    res.addAll(dayRes);

    start = next;
  }

  return res.reversed.toList();
}

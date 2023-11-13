import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleep_tracker/models/sleep_record.dart';
import 'package:sleep_tracker/providers/auth/auth_provider.dart';

final daySleepRecordsProvider = Provider.family<Iterable<SleepRecord>, DateTime>((ref, date) {
  return ref
      .watch(authStateProvider)
      .sleepRecords
      .skipWhile((record) => !DateUtils.isSameDay(record.start, date))
      .takeWhile((record) => DateUtils.isSameDay(record.start, date))
      .toList()
      .reversed;
});

final rangeSleepRecordsProvider = Provider.family<Iterable<SleepRecord>, DateTimeRange>((ref, range) {
  final r = DateUtils.datesOnly(range);

  return ref
      .watch(authStateProvider)
      .sleepRecords
      .skipWhile((record) => record.start.isAfter(r.end))
      .takeWhile((record) => !DateUtils.dateOnly(record.start).isBefore(r.start))
      .toList()
      .reversed;
});

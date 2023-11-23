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
  Iterable<SleepRecord> res =
      ref.watch(authStateProvider).sleepRecords.skipWhile((record) => r.end.isBefore(DateUtils.dateOnly(record.start)));

  res = res.takeWhile((record) => !DateUtils.dateOnly(record.start).isBefore(r.start));

  return res.toList().reversed;
});

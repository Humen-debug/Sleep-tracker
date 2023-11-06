import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDuration(Duration? duration) {
  if (duration == null) return "--:--:--";
  return "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}

abstract final class DateTimeUtils {
  static int weekBetween(DateTime from, DateTime to) {
    from = DateUtils.dateOnly(from);
    to = DateUtils.dateOnly(to);
    return (to.difference(from).inDays / DateTime.daysPerWeek).ceil();
  }

  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year.
  /// Changed the iOS date format of wiki from Monday to Sunday as the start of week
  static int numOfWeeks(int year) {
    final DateTime dec28 = DateTime(year, 12, 28);
    final int weekday = sundayBasedWeekday(dec28);

    /// Returns day of year from [dec28]
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - weekday + 10) / DateTime.daysPerWeek).floor();
  }

  /// Calculates number of weeks for a given date as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year.
  /// Changed the iOS date format of wiki from Monday to Sunday as the start of week
  ///
  /// Returns 1-based week number.
  /// If the result of woy is 0, return the last week of previous year.
  static int weekNumbers(DateTime date) {
    /// Returns day of year from [date]
    final int dayOfYear = int.parse(DateFormat("D").format(date));
    final int weekday = sundayBasedWeekday(date);
    int woy = ((dayOfYear - weekday + 10) / DateTime.daysPerWeek).floor();

    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  /// Computes the offset from the first day of the week that the first day of
  /// the [month] falls on.
  ///
  /// Details from [DateUtils].
  static int firstDayOffset(int year, int month) {
    // 0-based day of week for the month and year, with 0 representing Monday.
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0-based start of week, with 0 representing Sunday.
    // firstDayOfWeekIndex recomputed ti be Monday-based, in order to compare with weekdayFromMonday.
    const int firstDayOfWeekIndex = (0 - 1) % 7;

    // Number of days between fist day of week appearing on the calendar, and the
    // day corresponding to the first of the month.
    return (weekdayFromMonday - firstDayOfWeekIndex) % DateTime.daysPerWeek;
  }

  /// Computes the offset from the last day of the week that the last day of
  /// the [month] falls on.
  ///
  static int lastDayOffset(int year, int month) {
    // 0-based day of week for the month and year, with 0 representing Monday.
    final int weekday = DateTime(year, month + 1, 0).weekday;

    return 6 - weekday;
  }

  /// Returns true if two [DateTime] objects have the same year and week number,
  /// or are both null.
  static bool isSameWeek(DateTime? dateA, DateTime? dateB) {
    if (dateA != null && dateB != null) {
      if (dateA.year != dateB.year) return false;

      return weekNumbers(dateA) == weekNumbers(dateB);
    } else {
      return true;
    }
  }

  /// Returns weekday of [date] in [sunday]..[saturday]
  static int sundayBasedWeekday(DateTime date) {
    return date.weekday % DateTime.daysPerWeek;
  }

  /// The [weekday] is 0 for Sunday, 1 for Monday, etc. up to 7 for Sunday.
  static DateTime mostRecentWeekday(DateTime date, int weekday) {
    return DateTime(date.year, date.month, date.day - (date.weekday - weekday) % 7);
  }
}

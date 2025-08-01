// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

part of '../custom_extensions.dart';

enum DateGroupKeys implements LocaleEnum {
  today("Today"),
  yesterday("Yesterday"),
  recentlyRead("Recently Read");

  const DateGroupKeys(this.value);

  @override
  final String value;

  static DateGroupKeys? fromValue(String value) {
    return DateGroupKeys.values.where((key) => key.value == value).firstOrNull;
  }

  @override
  String toLocale(BuildContext context) {
    switch (this) {
      case today:
        return context.l10n.today;
      case yesterday:
        return context.l10n.yesterday;
      case recentlyRead:
        return context.l10n.recentlyRead;
    }
  }
}

extension DateTimeExtensions on DateTime {
  String get toDateString => DateFormat.yMMMd().format(this);
  String get toMonthYearString => DateFormat.yMMM().format(this);
  String get toDayMonthString => DateFormat.MMMd().format(this);
  String get toDayString => DateFormat.E().format(this);
  String get toMonthString => DateFormat.MMM().format(this);
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) =>
      DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );

// /////////////////////////////////////////////////////////////////////////////

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
      );

  DateTimeRange get sameDayRange => DateTimeRange(
        start: startOfDay,
        end: endOfDay,
      );

  bool isSameDay(DateTime date) =>
      day == date.day && month == date.month && year == date.year;

// /////////////////////////////////////////////////////////////////////////////

  DateTime get firstDayOfWeek => subtract(
        Duration(days: (weekday - 1)),
      ).startOfDay;

  DateTime get lastDayOfWeek => add(
        Duration(days: 7 - weekday),
      ).endOfDay;

  DateTimeRange get sameWeekRange => DateTimeRange(
        start: firstDayOfWeek,
        end: lastDayOfWeek,
      );

// /////////////////////////////////////////////////////////////////////////////

  DateTime get firstDayOfMonth => DateTime(year, month);

  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0).endOfDay;

  DateTimeRange get sameMonthRange => DateTimeRange(
        start: firstDayOfMonth,
        end: lastDayOfMonth,
      );

// /////////////////////////////////////////////////////////////////////////////

  DateTime get firstDayOfFinYear => DateTime(
        month >= 4 ? year : year - 1,
        4,
      );

  DateTime get lastDayOfFinYear => DateTime(
        month >= 4 ? year + 1 : year,
        3,
        31,
      ).endOfDay;

  DateTimeRange get sameFinYearRange => DateTimeRange(
        start: firstDayOfFinYear,
        end: lastDayOfFinYear,
      );

// /////////////////////////////////////////////////////////////////////////////

  static DateTime max(DateTime a, DateTime b) => a.compareTo(b) > 0 ? a : b;

  String convertToDaysAgo(BuildContext context) {
    Duration diff = DateTime.now().difference(this);

    if (diff.inDays < 1) {
      return context.l10n.today;
    } else if (diff.inDays < 2) {
      return context.l10n.yesterday;
    } else if (diff.inDays < 10) {
      return context.l10n.daysAgo(diff.inDays);
    } else {
      return DateFormat.yMMMd(context.currentLocale.toLanguageTag())
          .format(this);
    }
  }

  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// Get a formatted date string for grouping purposes
  String dateGroupString(BuildContext context) {
    if (isToday) return context.l10n.today;
    if (isYesterday) return context.l10n.yesterday;

    final now = DateTime.now();
    final difference = now.difference(this).inDays;

    if (difference < 0) {
      // Future date (shouldn't happen but handle gracefully)
      return DateGroupKeys.recentlyRead.toLocale(context);
    } else if (difference < 7) {
      // Show day of week for the past week
      return toDayString;
    } else {
      // For older items, show the specific date
      return toDateString;
    }
  }

  /// Get the number of days between this date and now
  int get daysSinceNow => DateTime.now().difference(this).inDays;

  /// Check if this date is within the past week (excluding today and yesterday)
  bool get isWithinPastWeek {
    final days = daysSinceNow;
    return days >= 2 && days < 7;
  }

  /// Get a simple key for grouping without needing context
  /// This provides non-localized keys that can be used for data grouping
  String get dateGroupKey {
    if (isToday) return DateGroupKeys.today.value;
    if (isYesterday) return DateGroupKeys.yesterday.value;

    if (daysSinceNow < 0) {
      return DateGroupKeys.recentlyRead.value;
    } else if (isWithinPastWeek) {
      // Use weekday number for grouping, will be localized in UI
      return 'week_$weekday';
    } else {
      // Use date string for older items
      return toDateString;
    }
  }
}

extension TimeOfDayE on TimeOfDay {
  String _addLeadingZeroIfNeeded(int value) {
    if (value < 10) {
      return '0$value';
    }
    return value.toString();
  }

  get hhmm {
    return "${_addLeadingZeroIfNeeded(hour)}:${_addLeadingZeroIfNeeded(minute)}";
  }
}

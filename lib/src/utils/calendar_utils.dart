import '../models/calendar_date.dart';
import '../models/calendar_enums.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarUtils {
  /// Resolves the effective first day of week as a Dart weekday value
  /// (`DateTime.monday` == 1 ... `DateTime.sunday` == 7).
  ///
  /// When [startingDayOfWeek] is provided it takes precedence. Otherwise the
  /// locale convention is used via intl's `FIRSTDAYOFWEEK` (0 == Monday ...
  /// 6 == Sunday), which resolves to Sunday for locales like `ko`/`en_US` and
  /// Monday for `en_GB`/`fr`. Falls back to the default locale when [locale]
  /// is null.
  static int resolveFirstDayOfWeek(
    StartingDayOfWeek? startingDayOfWeek, [
    String? locale,
  ]) {
    if (startingDayOfWeek != null) {
      return startingDayOfWeek.index + 1;
    }
    if (locale != null) {
      initializeDateFormatting(locale);
    }
    return DateFormat.EEEE(locale).dateSymbols.FIRSTDAYOFWEEK + 1;
  }

  /// Builds the 42-cell (6x7) grid for [date]'s month.
  ///
  /// [firstDayOfWeek] is a Dart weekday value (`DateTime.monday` == 1 ...
  /// `DateTime.sunday` == 7) and determines which weekday occupies the first
  /// column. Defaults to Monday to preserve the previous grid layout.
  static List<CalendarDate> getDaysInMonth(
    DateTime date, {
    int firstDayOfWeek = DateTime.monday,
  }) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    final daysInMonth = lastDayOfMonth.day;

    final days = <CalendarDate>[];

    // Number of trailing days from the previous month needed so that the first
    // column lines up with [firstDayOfWeek]. Dart's `%` returns a non-negative
    // result for a positive divisor, so this is always in the range 0..6.
    final leadingDays = (firstDayOfMonth.weekday - firstDayOfWeek) % 7;

    // Fill in days from the previous month to complete the first week
    for (var i = 0; i < leadingDays; i++) {
      final previousMonthDay = firstDayOfMonth.subtract(
        Duration(days: leadingDays - i),
      );
      days.add(CalendarDate(date: previousMonthDay));
    }

    // Add all days of the current month
    for (var i = 1; i <= daysInMonth; i++) {
      final currentDate = DateTime(date.year, date.month, i);
      days.add(CalendarDate(date: currentDate, isToday: _isToday(currentDate)));
    }

    // Fill in days from the next month to complete the calendar grid
    final remainingDays = 42 - days.length; // 6 rows * 7 days
    for (var i = 1; i <= remainingDays; i++) {
      final nextMonthDay = lastDayOfMonth.add(Duration(days: i));
      days.add(CalendarDate(date: nextMonthDay));
    }

    return days;
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String getMonthName(DateTime date, [String? locale]) {
    if (locale != null) {
      initializeDateFormatting(locale);
    }
    return DateFormat.yMMMM(locale).format(date);
  }

  /// Returns the 7 narrow weekday labels ordered so the list starts at
  /// [firstDayOfWeek] (a Dart weekday value, `DateTime.monday` == 1 ...
  /// `DateTime.sunday` == 7).
  ///
  /// Defaults to Sunday so a bare `getWeekdayNames(locale)` call keeps the
  /// intl-native Sunday-first order.
  static List<String> getWeekdayNames([
    String? locale,
    int firstDayOfWeek = DateTime.sunday,
  ]) {
    if (locale != null) {
      initializeDateFormatting(locale);
    }
    // `names` is indexed Sunday..Saturday (0 == Sunday). Rotate it so the first
    // entry matches [firstDayOfWeek]. Sunday(7) maps to index 0, Monday(1) to
    // index 1, ... Saturday(6) to index 6.
    final names = DateFormat.EEEE(locale).dateSymbols.STANDALONENARROWWEEKDAYS;
    final startIndex = firstDayOfWeek % 7;
    return List.generate(7, (i) => names[(startIndex + i) % 7]);
  }
}

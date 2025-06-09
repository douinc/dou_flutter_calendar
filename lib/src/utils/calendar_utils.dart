import '../models/calendar_date.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarUtils {
  static List<CalendarDate> getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final days = <CalendarDate>[];

    // Fill in days from the previous month to complete the first week
    for (var i = 1; i < firstWeekday; i++) {
      final previousMonthDay = firstDayOfMonth.subtract(
        Duration(days: firstWeekday - i),
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

  static List<String> getWeekdayNames([String? locale]) {
    if (locale != null) {
      initializeDateFormatting(locale);
    }
    return DateFormat.EEEE(locale).dateSymbols.STANDALONENARROWWEEKDAYS;
  }
}

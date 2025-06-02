import '../models/calendar_date.dart';

class CalendarUtils {
  static List<CalendarDate> getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final days = <CalendarDate>[];

    // Add days from previous month
    for (var i = 1; i < firstWeekday; i++) {
      final previousMonthDay = firstDayOfMonth.subtract(
        Duration(days: firstWeekday - i),
      );
      days.add(CalendarDate(date: previousMonthDay, isDisabled: true));
    }

    // Add days of current month
    for (var i = 1; i <= daysInMonth; i++) {
      final currentDate = DateTime(date.year, date.month, i);
      days.add(CalendarDate(date: currentDate, isToday: _isToday(currentDate)));
    }

    // Add days from next month
    final remainingDays = 42 - days.length; // 6 rows * 7 days
    for (var i = 1; i <= remainingDays; i++) {
      final nextMonthDay = lastDayOfMonth.add(Duration(days: i));
      days.add(CalendarDate(date: nextMonthDay, isDisabled: true));
    }

    return days;
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String getMonthName(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }

  static List<String> getWeekdayNames() {
    return ['일', '월', '화', '수', '목', '금', '토'];
  }
}

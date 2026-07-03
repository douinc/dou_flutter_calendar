import 'package:flutter_test/flutter_test.dart';
import 'package:dou_flutter_calendar/src/utils/calendar_utils.dart';
import 'package:dou_flutter_calendar/src/models/calendar_enums.dart';

void main() {
  group('CalendarUtils', () {
    test('getDaysInMonth returns correct number of days', () {
      final days = CalendarUtils.getDaysInMonth(DateTime(2024, 3, 1));
      expect(days.length, 42); // 6 weeks * 7 days
    });

    test('getDaysInMonth includes previous month days', () {
      final days = CalendarUtils.getDaysInMonth(DateTime(2024, 3, 1));
      final firstDay = days.first;
      expect(firstDay.date.month, 2); // February
    });

    test('getDaysInMonth includes next month days', () {
      final days = CalendarUtils.getDaysInMonth(DateTime(2024, 3, 1));
      final lastDay = days.last;
      expect(lastDay.date.month, 4); // April
    });

    test('getDaysInMonth marks today correctly', () {
      final today = DateTime.now();
      final days = CalendarUtils.getDaysInMonth(today);
      final todayIndex = days.indexWhere(
        (day) =>
            day.date.year == today.year &&
            day.date.month == today.month &&
            day.date.day == today.day,
      );
      expect(todayIndex, isNot(-1));
      expect(days[todayIndex].isToday, true);
    });

    test('getMonthName returns correct month name in English', () {
      final monthName = CalendarUtils.getMonthName(DateTime(2024, 3, 1), 'en');
      expect(monthName, 'March 2024');
    });

    test('getMonthName returns correct month name in Korean', () {
      final monthName = CalendarUtils.getMonthName(DateTime(2024, 3, 1), 'ko');
      expect(monthName, '2024년 3월');
    });

    test('getWeekdayNames returns correct weekday names in English', () {
      final weekdays = CalendarUtils.getWeekdayNames('en');
      expect(weekdays.length, 7);
      expect(weekdays[0], 'S'); // Sunday
      expect(weekdays[1], 'M'); // Monday
      expect(weekdays[2], 'T'); // Tuesday
      expect(weekdays[3], 'W'); // Wednesday
      expect(weekdays[4], 'T'); // Thursday
      expect(weekdays[5], 'F'); // Friday
      expect(weekdays[6], 'S'); // Saturday
    });

    test('getWeekdayNames returns correct weekday names in Korean', () {
      final weekdays = CalendarUtils.getWeekdayNames('ko');
      expect(weekdays.length, 7);
      expect(weekdays[0], '일'); // Sunday
      expect(weekdays[1], '월'); // Monday
      expect(weekdays[2], '화'); // Tuesday
      expect(weekdays[3], '수'); // Wednesday
      expect(weekdays[4], '목'); // Thursday
      expect(weekdays[5], '금'); // Friday
      expect(weekdays[6], '토'); // Saturday
    });

    group('firstDayOfWeek', () {
      test('getDaysInMonth defaults to a Monday-first grid', () {
        final days = CalendarUtils.getDaysInMonth(DateTime(2024, 3, 1));
        // March 1, 2024 is a Friday, so the grid starts on the preceding Monday.
        expect(days.first.date, DateTime(2024, 2, 26));
        expect(days.first.date.weekday, DateTime.monday);
      });

      test('getDaysInMonth honours a Sunday-first grid', () {
        final days = CalendarUtils.getDaysInMonth(
          DateTime(2024, 3, 1),
          firstDayOfWeek: DateTime.sunday,
        );
        expect(days.length, 42);
        expect(days.first.date, DateTime(2024, 2, 25));
        expect(days.first.date.weekday, DateTime.sunday);
      });

      test('getDaysInMonth honours a Saturday-first grid', () {
        final days = CalendarUtils.getDaysInMonth(
          DateTime(2024, 3, 1),
          firstDayOfWeek: DateTime.saturday,
        );
        expect(days.first.date.weekday, DateTime.saturday);
      });

      test('getWeekdayNames rotates to a Monday-first order (en)', () {
        final weekdays = CalendarUtils.getWeekdayNames('en', DateTime.monday);
        expect(weekdays, ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
      });

      test('getWeekdayNames rotates to a Monday-first order (ko)', () {
        final weekdays = CalendarUtils.getWeekdayNames('ko', DateTime.monday);
        expect(weekdays, ['월', '화', '수', '목', '금', '토', '일']);
      });

      test('resolveFirstDayOfWeek maps an explicit enum to a Dart weekday', () {
        expect(
          CalendarUtils.resolveFirstDayOfWeek(StartingDayOfWeek.monday),
          DateTime.monday,
        );
        expect(
          CalendarUtils.resolveFirstDayOfWeek(StartingDayOfWeek.sunday),
          DateTime.sunday,
        );
        expect(
          CalendarUtils.resolveFirstDayOfWeek(StartingDayOfWeek.saturday),
          DateTime.saturday,
        );
      });

      test('resolveFirstDayOfWeek follows locale convention when null', () {
        // Korea, the US and Japan conventionally start the week on Sunday.
        expect(CalendarUtils.resolveFirstDayOfWeek(null, 'ko'), DateTime.sunday);
        expect(
          CalendarUtils.resolveFirstDayOfWeek(null, 'en_US'),
          DateTime.sunday,
        );
        // The UK and France start the week on Monday.
        expect(
          CalendarUtils.resolveFirstDayOfWeek(null, 'en_GB'),
          DateTime.monday,
        );
        expect(CalendarUtils.resolveFirstDayOfWeek(null, 'fr'), DateTime.monday);
      });

      test('resolveFirstDayOfWeek prefers explicit value over locale', () {
        // Even for a Sunday-first locale, an explicit Monday wins.
        expect(
          CalendarUtils.resolveFirstDayOfWeek(StartingDayOfWeek.monday, 'ko'),
          DateTime.monday,
        );
      });
    });
  });
}

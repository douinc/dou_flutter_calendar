import 'package:dou_flutter_calendar/dou_flutter_calendar.dart';
import 'package:dou_flutter_calendar/src/models/calendar_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridCalendarController', () {
    late GridCalendarController controller;

    setUp(() {
      controller = GridCalendarController(initialDate: DateTime(2024, 3, 15));
    });

    test('initialDate sets correctly', () {
      expect(controller.currentDate, DateTime(2024, 3, 15));
    });

    test('selectDate updates currentDate and notifies listeners', () {
      final newDate = DateTime(2024, 3, 20);
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.selectDate(newDate);

      expect(controller.currentDate, newDate);
      expect(controller.lastChangeType, CalendarChangeType.selection);
      expect(notified, isTrue);
    });

    test('navigateToDate updates currentDate and notifies listeners', () {
      final newDate = DateTime(2024, 3, 20);
      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.navigateToDate(newDate);

      expect(controller.currentDate, newDate);
      expect(controller.lastChangeType, CalendarChangeType.navigation);
      expect(notified, isTrue);
    });

    test('nextMonth navigates to the next month', () {
      controller.nextMonth();
      expect(controller.currentDate, DateTime(2024, 4, 15));
    });

    test('previousMonth navigates to the previous month', () {
      controller.previousMonth();
      expect(controller.currentDate, DateTime(2024, 2, 15));
    });

    test('nextDay selects the next day', () {
      controller.nextDay();
      expect(controller.currentDate, DateTime(2024, 3, 16));
    });

    test('previousDay selects the previous day', () {
      controller.previousDay();
      expect(controller.currentDate, DateTime(2024, 3, 14));
    });

    test('goToToday selects today', () {
      controller.goToToday();
      final now = DateTime.now();
      expect(controller.currentDate.year, now.year);
      expect(controller.currentDate.month, now.month);
      expect(controller.currentDate.day, now.day);
    });

    test('goToDate selects the specified date', () {
      controller.goToDate(2025, 1, 1);
      expect(controller.currentDate, DateTime(2025, 1, 1));
    });
  });
}
